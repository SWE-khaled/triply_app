import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_parsing.dart';
import '../models/chat_profile.dart';
import '../models/report.dart';
import '../remote/firestore_service.dart';
import 'chat_repository.dart';

/// The Firestore implementation of [ChatRepository].
///
/// It follows the deployed `chats` / `messages` / `typing` / `reports`
/// rules:
/// - the document id is the D25 canonical id;
/// - role fields and `participants` stay role-ordered;
/// - the first message is created atomically with the chat;
/// - every send is one batch: message, 120-character preview, timestamp
///   and the recipient's `+1` unread counter;
/// - only the caller's own read marker and profile entry are written.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({
    FirestoreService? firestore,
    this.auth,
    DateTime Function()? clock,
  }) : _firestore = firestore ?? FirestoreService(),
       _clock = clock ?? DateTime.now;

  static const String chatsCollection = 'chats';
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String messagesCollection = 'messages';
  static const String typingCollection = 'typing';

  /// How long a typing marker stays "recent".
  static const Duration typingWindow = Duration(seconds: 5);

  final FirestoreService _firestore;

  /// The auth instance to use. Null means the default one.
  final FirebaseAuth? auth;

  final DateTime Function() _clock;

  late final ChatTypingThrottle _typingThrottle = ChatTypingThrottle(
    clock: _clock,
  );

  FirebaseFirestore get _db => _firestore.instance;

  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection(chatsCollection);

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection(reportsCollection);

  CollectionReference<Map<String, dynamic>> _messagesOf(String chatId) =>
      _chats.doc(chatId).collection(messagesCollection);

  CollectionReference<Map<String, dynamic>> _typingOf(String chatId) =>
      _chats.doc(chatId).collection(typingCollection);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  String _requireUid() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      throw const ChatNotAuthenticatedException();
    }
    return uid;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ChatException {
      rethrow;
    } catch (error) {
      throw ChatErrors.map(error);
    }
  }

  @override
  Future<Chat> openOrCreateChat({
    required String guideId,
    required String guideName,
    required String guideAvatar,
    String? firstMessage,
  }) {
    return _guard(() async {
      final uid = _requireUid();
      if (guideId.isEmpty || guideId == uid) {
        throw const ChatValidationException('Choose a guide to chat with.');
      }

      final mySnapshot = await _db.collection(usersCollection).doc(uid).get();
      final myData = mySnapshot.data() ?? const <String, dynamic>{};
      if (myData['role'] != 'tourist') {
        throw const ChatPermissionException('Only tourists can start a chat.');
      }

      final chatId = ChatIds.canonical(uid, guideId);
      final chatRef = _chats.doc(chatId);
      final first = firstMessage == null || firstMessage.trim().isEmpty
          ? null
          : ChatText.validateMessage(firstMessage);

      final myProfile = ChatProfile(
        displayName: _firstNonEmpty(<Object?>[
          myData['displayName'],
          myData['fullName'],
        ]),
        avatarUrl: _firstNonEmpty(<Object?>[
          myData['avatarUrl'],
          myData['photoUrl'],
        ]),
      );
      final guideProfile = ChatProfile(
        displayName: guideName,
        avatarUrl: guideAvatar,
      );

      final created = await _createChat(
        chatId: chatId,
        uid: uid,
        guideId: guideId,
        myProfile: myProfile,
        guideProfile: guideProfile,
        firstMessage: first,
      );

      // The chat existed already, but this call carries the first
      // message the user typed: send it through the normal batch.
      if (!created && first != null) {
        await sendMessage(chatId: chatId, text: first);
      }

      final snapshot = await chatRef.get();
      return Chat.fromDocument(snapshot.data(), chatId);
    });
  }

  /// Writes the chat and, when supplied, its first message in one atomic
  /// batch.
  ///
  /// Returns `false` when the batch was denied, which is what happens
  /// when the chat already exists: a full-document `set` is then an
  /// update, and the deployed update rule accepts only a send, a read
  /// marker or the caller's own profile entry — the `createdAt` in this
  /// payload always makes it a denial. A missing chat cannot be probed
  /// with `chatRef.get()` instead, because the `chats` read rule reads
  /// `resource.data` and denies a missing document; that is the same
  /// reason `guideVerifications` allows `resource == null` explicitly.
  /// The caller therefore sends through the chat instead, so a real
  /// permission denial surfaces from that write and a chat created by a
  /// concurrent request still receives the message.
  Future<bool> _createChat({
    required String chatId,
    required String uid,
    required String guideId,
    required ChatProfile myProfile,
    required ChatProfile guideProfile,
    required String? firstMessage,
  }) async {
    try {
      final batch = _db.batch();
      batch.set(_chats.doc(chatId), <String, dynamic>{
        'touristId': uid,
        'guideId': guideId,
        'participants': <String>[uid, guideId],
        'profiles': <String, dynamic>{
          uid: myProfile.toMap(),
          guideId: guideProfile.toMap(),
        },
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount': <String, dynamic>{
          uid: 0,
          guideId: firstMessage == null ? 0 : 1,
        },
        if (firstMessage != null) ...<String, dynamic>{
          'lastMessage': <String, dynamic>{
            'text': ChatText.preview(firstMessage),
            'senderId': uid,
            'createdAt': FieldValue.serverTimestamp(),
          },
          'lastMessageAt': FieldValue.serverTimestamp(),
        },
      });
      if (firstMessage != null) {
        batch.set(_messagesOf(chatId).doc(), <String, dynamic>{
          'senderId': uid,
          'text': firstMessage,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      return true;
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
      return false;
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String text,
  }) {
    return _guard(() async {
      final uid = _requireUid();
      final value = ChatText.validateMessage(text);

      final chatRef = _chats.doc(chatId);
      final chatSnapshot = await chatRef.get();
      if (!chatSnapshot.exists) {
        throw const ChatException('This chat does not exist yet.');
      }
      final chat = Chat.fromDocument(chatSnapshot.data(), chatId);
      final other = chat.otherUserId(uid);
      if (other.isEmpty) {
        throw const ChatException('This chat has no other participant.');
      }

      final messageRef = _messagesOf(chatId).doc();
      final batch = _db.batch();
      batch.set(messageRef, <String, dynamic>{
        'senderId': uid,
        'text': value,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(chatRef, <String, dynamic>{
        'lastMessage': <String, dynamic>{
          'text': ChatText.preview(value),
          'senderId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        },
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount.$other': FieldValue.increment(1),
      });
      await batch.commit();

      final created = await messageRef.get();
      return ChatMessage.fromDocument(created.data(), messageRef.id);
    });
  }

  @override
  Stream<List<Chat>> watchChats(String userId) {
    if (userId.isEmpty) {
      return Stream<List<Chat>>.value(const <Chat>[]);
    }
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Chat.fromDocument(doc.data(), doc.id))
              .toList(growable: false),
        );
  }

  @override
  Stream<Chat?> watchChat(String chatId) {
    return _chats.doc(chatId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Chat.fromDocument(snapshot.data(), snapshot.id);
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 30}) {
    return _messagesOf(chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromDocument(doc.data(), doc.id))
              .toList(growable: false),
        );
  }

  @override
  Future<List<ChatMessage>> loadMoreMessages({
    required String chatId,
    required DateTime before,
    int limit = 30,
  }) {
    return _guard(() async {
      final snapshot = await _messagesOf(chatId)
          .orderBy('createdAt', descending: true)
          .startAfter(<Object?>[Timestamp.fromDate(before)])
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ChatMessage.fromDocument(doc.data(), doc.id))
          .toList(growable: false);
    });
  }

  @override
  Future<void> markRead(String chatId) {
    return _guard(() async {
      final uid = _requireUid();
      await _chats.doc(chatId).update(<String, dynamic>{
        'lastReadAt.$uid': FieldValue.serverTimestamp(),
        'unreadCount.$uid': 0,
      });
    });
  }

  @override
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    return _guard(() async {
      final uid = _requireUid();
      final value = ChatText.validateMessage(text);
      final messageRef = _messagesOf(chatId).doc(messageId);
      final snapshot = await messageRef.get();
      if (!snapshot.exists) {
        throw const ChatException('This message no longer exists.');
      }
      final message = ChatMessage.fromDocument(snapshot.data(), messageId);
      if (message.senderId != uid) {
        throw const ChatValidationException(
          'You can only edit your own messages.',
        );
      }
      if (!message.canModify(uid, now: _clock())) {
        throw const ChatValidationException(
          'Messages can only be edited within 24 hours.',
        );
      }
      await messageRef.update(<String, dynamic>{
        'text': value,
        'editedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) {
    return _guard(() async {
      final uid = _requireUid();
      final messageRef = _messagesOf(chatId).doc(messageId);
      final snapshot = await messageRef.get();
      if (!snapshot.exists) return;
      final message = ChatMessage.fromDocument(snapshot.data(), messageId);
      if (message.senderId != uid) {
        throw const ChatValidationException(
          'You can only delete your own messages.',
        );
      }
      if (!message.canModify(uid, now: _clock())) {
        throw const ChatValidationException(
          'Messages can only be deleted within 24 hours.',
        );
      }
      await messageRef.delete();
    });
  }

  @override
  Future<bool> setTyping(String chatId) {
    return _guard(() async {
      final uid = _requireUid();
      if (!_typingThrottle.shouldSend(_clock())) return false;
      await _typingOf(chatId).doc(uid).set(<String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  @override
  Stream<Set<String>> watchTyping(String chatId) {
    late final StreamController<Set<String>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
    Timer? timer;
    Map<String, DateTime> latest = const <String, DateTime>{};

    void emit() {
      if (controller.isClosed) return;
      final now = _clock();
      controller.add(<String>{
        for (final entry in latest.entries)
          if (now.difference(entry.value) <= typingWindow) entry.key,
      });
    }

    controller = StreamController<Set<String>>(
      onListen: () {
        subscription = _typingOf(chatId).snapshots().listen(
          (snapshot) {
            latest = <String, DateTime>{
              for (final doc in snapshot.docs)
                doc.id:
                    chatDateTime(doc.data()['updatedAt']) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
            };
            emit();
          },
          onError: (Object error, StackTrace stack) {
            if (!controller.isClosed) {
              controller.addError(ChatErrors.map(error), stack);
            }
          },
        );
        timer = Timer.periodic(const Duration(seconds: 1), (_) => emit());
      },
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> reportMessage({
    required String chatId,
    required ChatMessage message,
    required String reasonCode,
    String note = '',
  }) {
    return _guard(() async {
      final uid = _requireUid();
      if (!Report.isReasonCode(reasonCode)) {
        throw const ChatValidationException('Choose a report reason.');
      }
      final noteValue = ChatText.validateNote(note);

      final messageRef = _messagesOf(chatId).doc(message.id);
      final messageSnapshot = await messageRef.get();
      if (!messageSnapshot.exists) {
        throw const ChatException('This message no longer exists.');
      }
      final messageData = messageSnapshot.data() ?? const <String, dynamic>{};
      final rawCreatedAt = messageData['createdAt'];
      if (rawCreatedAt is! Timestamp) {
        throw const ChatException('This message cannot be reported yet.');
      }

      final chatSnapshot = await _chats.doc(chatId).get();
      if (!chatSnapshot.exists) {
        throw const ChatException('This chat no longer exists.');
      }
      final chat = Chat.fromDocument(chatSnapshot.data(), chatId);
      final other = chat.otherUserId(uid);
      final realSenderId = chatString(messageData['senderId']);
      if (realSenderId != other) {
        throw const ChatValidationException(
          'You can only report the other participant\'s message.',
        );
      }

      final report = Report(
        id: Report.idFor(uid, message.id),
        reporterId: uid,
        reportedUserId: other,
        chatId: chatId,
        messageId: message.id,
        text: chatString(messageData['text']),
        messageCreatedAt: rawCreatedAt.toDate(),
        reasonCode: reasonCode,
        note: noteValue,
        status: 'open',
      );
      final payload = report.toMap();
      // Copy the exact server Timestamp, not a re-created one: the rule
      // compares the two values byte for byte.
      payload['messageCreatedAt'] = rawCreatedAt;
      payload['createdAt'] = FieldValue.serverTimestamp();
      await _reports.doc(report.id).set(payload);
    });
  }

  @override
  Future<void> updateMyProfile({
    required String chatId,
    String? displayName,
    String? avatarUrl,
  }) {
    return _guard(() async {
      final uid = _requireUid();
      final userSnapshot = await _db.collection(usersCollection).doc(uid).get();
      final userData = userSnapshot.data() ?? const <String, dynamic>{};

      final profile = ChatProfile(
        displayName: displayName ?? _pickName(userData),
        avatarUrl: avatarUrl ?? _pickAvatar(userData),
      );
      await _chats.doc(chatId).update(<String, dynamic>{
        'profiles.$uid': profile.toMap(),
      });
    });
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = chatString(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _pickName(Map<String, dynamic> data) =>
      _firstNonEmpty(<Object?>[data['displayName'], data['fullName']]);

  static String _pickAvatar(Map<String, dynamic> data) =>
      _firstNonEmpty(<Object?>[data['avatarUrl'], data['photoUrl']]);
}

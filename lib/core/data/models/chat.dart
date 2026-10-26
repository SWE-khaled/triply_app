import 'chat_parsing.dart';
import 'chat_profile.dart';

/// Builds the canonical chat document id.
///
/// D25: the two participant uids are sorted lexicographically and joined
/// with `_`. The role fields (`touristId`/`guideId`) and `participants`
/// stay role-ordered; only the document id is canonical, so the same
/// pair can never end up with two chats.
class ChatIds {
  const ChatIds._();

  static String canonical(String a, String b) =>
      a.compareTo(b) <= 0 ? '${a}_$b' : '${b}_$a';
}

/// The preview stored on the parent chat document.
class ChatLastMessage {
  final String text;
  final String senderId;
  final DateTime? createdAt;

  const ChatLastMessage({this.text = '', this.senderId = '', this.createdAt});

  factory ChatLastMessage.fromMap(Object? data) {
    final map = chatMap(data);
    return ChatLastMessage(
      text: chatString(map['text']),
      senderId: chatString(map['senderId']),
      createdAt: chatDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    if (createdAt != null) 'createdAt': chatTimestamp(createdAt),
  };
}

/// One private chat between a tourist and a guide.
///
/// Field names and shapes match the deployed `chats/{chatId}` rules.
class Chat {
  final String id;
  final String touristId;
  final String guideId;

  /// Role-ordered: `[touristId, guideId]`.
  final List<String> participants;

  /// `uid -> {displayName, avatarUrl}`.
  final Map<String, ChatProfile> profiles;

  final ChatLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final Map<String, DateTime> lastReadAt;
  final DateTime? createdAt;

  const Chat({
    required this.id,
    this.touristId = '',
    this.guideId = '',
    this.participants = const [],
    this.profiles = const {},
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = const {},
    this.lastReadAt = const {},
    this.createdAt,
  });

  /// Reads a chat document, tolerating every missing field.
  factory Chat.fromDocument(Map<String, dynamic>? data, String id) {
    final map = chatMap(data);
    final touristId = chatString(map['touristId']);
    final guideId = chatString(map['guideId']);

    final rawParticipants = map['participants'];
    final participants = rawParticipants is List
        ? rawParticipants.whereType<String>().toList(growable: false)
        : <String>[
            if (touristId.isNotEmpty) touristId,
            if (guideId.isNotEmpty) guideId,
          ];

    final profiles = <String, ChatProfile>{
      for (final entry in chatMap(map['profiles']).entries)
        entry.key: ChatProfile.fromMap(entry.value),
    };
    final unreadCount = <String, int>{
      for (final entry in chatMap(map['unreadCount']).entries)
        entry.key: chatInt(entry.value),
    };
    final lastReadAt = <String, DateTime>{
      for (final entry in chatMap(map['lastReadAt']).entries)
        if (chatDateTime(entry.value) != null)
          entry.key: chatDateTime(entry.value)!,
    };

    final rawLastMessage = map['lastMessage'];
    final lastMessage = rawLastMessage is Map
        ? ChatLastMessage.fromMap(rawLastMessage)
        : null;

    return Chat(
      id: id,
      touristId: touristId,
      guideId: guideId,
      participants: participants,
      profiles: profiles,
      lastMessage: lastMessage,
      lastMessageAt: chatDateTime(map['lastMessageAt']),
      unreadCount: unreadCount,
      lastReadAt: lastReadAt,
      createdAt: chatDateTime(map['createdAt']),
    );
  }

  /// The participant that is not [uid]; falls back to [uid] when the
  /// document is malformed.
  String otherUserId(String uid) {
    if (uid == touristId) return guideId;
    if (uid == guideId) return touristId;
    return touristId.isNotEmpty ? touristId : guideId;
  }

  ChatProfile profileOf(String uid) => profiles[uid] ?? const ChatProfile();

  int unreadFor(String uid) => unreadCount[uid] ?? 0;

  DateTime? lastReadOf(String uid) => lastReadAt[uid];

  Chat copyWith({
    List<String>? participants,
    Map<String, ChatProfile>? profiles,
    ChatLastMessage? lastMessage,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
    Map<String, DateTime>? lastReadAt,
  }) {
    return Chat(
      id: id,
      touristId: touristId,
      guideId: guideId,
      participants: participants ?? this.participants,
      profiles: profiles ?? this.profiles,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'touristId': touristId,
    'guideId': guideId,
    'participants': participants,
    'profiles': profiles.map((uid, profile) => MapEntry(uid, profile.toMap())),
    if (lastMessage != null) 'lastMessage': lastMessage!.toMap(),
    if (lastMessageAt != null) 'lastMessageAt': chatTimestamp(lastMessageAt),
    'unreadCount': unreadCount,
    if (lastReadAt.isNotEmpty)
      'lastReadAt': lastReadAt.map(
        (uid, at) => MapEntry(uid, chatTimestamp(at)),
      ),
    if (createdAt != null) 'createdAt': chatTimestamp(createdAt),
  };
}

/// A convenience view over a chat's preview.
extension ChatPreview on Chat {
  String get previewText => lastMessage?.text ?? '';
}

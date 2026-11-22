import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/data/remote/firestore_service.dart';
import '../model/contact_message_model.dart';

/// Identity copied from the authenticated session and trusted user document.
class ContactIdentity {
  const ContactIdentity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;

  /// Stored role value for `contact_messages`: `tourist` or `tourGuide`.
  final String role;
}

/// Shared repository for tourist/guide submission and admin support review.
///
/// Firebase instances are resolved lazily, so this class can be constructed
/// in plain unit tests without initialising Firebase.
class ContactMessagesRepository {
  ContactMessagesRepository({FirestoreService? store, FirebaseAuth? auth})
    : _storeOverride = store,
      _authOverride = auth;

  final FirestoreService? _storeOverride;
  final FirebaseAuth? _authOverride;

  FirestoreService get _store => _storeOverride ?? FirestoreService();
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  /// Reads the sender identity from trusted sources only.
  ///
  /// The role comes from `users/{uid}.role`, never from UI input. The app's
  /// internal `guide` role is mapped to the requested `tourGuide` value.
  Future<ContactIdentity> currentIdentity() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to contact support.');
    }

    final profile = await _store.readDoc('users', user.uid);

    // Rules compare the written copies with the RAW trusted values, so the
    // repository must not trim them here. A whitespace-padded role fails
    // the switch below with a clear StateError instead of being silently
    // normalised into a value the rules would reject.
    final trustedRole = _rawText(profile?['role']);
    final storedRole = switch (trustedRole) {
      'tourist' => 'tourist',
      'guide' => 'tourGuide',
      _ => throw StateError('Your account role could not be verified.'),
    };

    final authEmail = user.email;
    final email = authEmail != null && authEmail.isNotEmpty
        ? authEmail
        : _rawText(profile?['email']);
    final name = _firstNonEmptyRaw(profile, const <String>[
      'name',
      'fullName',
      'displayName',
    ]);

    return ContactIdentity(
      uid: user.uid,
      name: name,
      email: email,
      role: storedRole,
    );
  }

  /// Creates a new support message with server-generated timestamps.
  Future<void> submit({
    required String email,
    required String message,
    required String type,
  }) async {
    if (!ContactMessageModel.types.contains(type)) {
      throw ArgumentError.value(type, 'type', 'Unsupported message type.');
    }

    final identity = await currentIdentity();
    final reference = _store.collection(ContactMessageModel.collection).doc();
    final model = ContactMessageModel(
      id: reference.id,
      userId: identity.uid,
      userName: identity.name,
      userEmail: identity.email.isNotEmpty ? identity.email : email.trim(),
      userRole: identity.role,
      message: message.trim(),
      type: type,
      status: 'pending',
    );

    await reference.set(<String, dynamic>{
      ...model.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live list used by the admin Support Center.
  Stream<List<ContactMessageModel>> watchAll() {
    return _store
        .collection(ContactMessageModel.collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContactMessageModel.fromDocument(doc.data(), doc.id))
              .toList(growable: false),
        );
  }

  /// Admin-only status change. Role checks are also enforced in rules.
  Future<void> updateStatus({
    required String messageId,
    required String status,
  }) async {
    if (!ContactMessageModel.statuses.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported status.');
    }
    await _store
        .collection(ContactMessageModel.collection)
        .doc(messageId)
        .update(<String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns trusted field values exactly as stored/issued. Security rules
  /// compare against these raw values, so trimming here would cause a valid
  /// submission to be denied.
  static String _rawText(Object? value) => value is String ? value : '';

  static String _firstNonEmptyRaw(
    Map<String, dynamic>? data,
    List<String> keys,
  ) {
    if (data == null) return '';
    for (final key in keys) {
      final value = _rawText(data[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}

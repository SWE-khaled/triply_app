import 'package:cloud_firestore/cloud_firestore.dart';

/// A message sent from a tourist or tour-guide profile to the administration.
///
/// The document is stored in `contact_messages`. Identity fields are copied
/// from the authenticated session and the trusted `users/{uid}` document;
/// Firestore rules verify those copies, so the client cannot forge a sender.
class ContactMessageModel {
  static const String collection = 'contact_messages';

  static const List<String> types = <String>[
    'complaint',
    'inquiry',
    'general',
  ];

  static const List<String> statuses = <String>[
    'pending',
    'inProgress',
    'resolved',
  ];

  static const List<String> userRoles = <String>['tourist', 'tourGuide'];

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final String message;
  final String type;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContactMessageModel({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.userEmail = '',
    this.userRole = '',
    this.message = '',
    this.type = 'general',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  /// Reads a contact document, tolerating missing or pending server fields.
  factory ContactMessageModel.fromDocument(
    Map<String, dynamic>? data,
    String id,
  ) {
    final map = data ?? <String, dynamic>{};

    String text(Object? value) => value is String ? value : '';

    DateTime? date(Object? value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    final storedId = text(map['id']);
    final storedType = text(map['type']);
    final storedStatus = text(map['status']);
    final storedRole = text(map['userRole']);

    return ContactMessageModel(
      id: storedId.isEmpty ? id : storedId,
      userId: text(map['userId']),
      userName: text(map['userName']),
      userEmail: text(map['userEmail']),
      userRole: storedRole,
      message: text(map['message']),
      type: types.contains(storedType) ? storedType : 'general',
      status: statuses.contains(storedStatus) ? storedStatus : 'pending',
      createdAt: date(map['createdAt']),
      updatedAt: date(map['updatedAt']),
    );
  }

  /// Data written for a new message. Timestamps are injected by the
  /// repository as `FieldValue.serverTimestamp()` so the server is the
  /// authority for both values.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'userRole': userRole,
    'message': message,
    'type': type,
    'status': status,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
  };
}

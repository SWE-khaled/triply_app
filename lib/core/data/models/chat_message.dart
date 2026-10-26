import 'chat_parsing.dart';

/// One text message of a chat.
///
/// `createdAt` is written with `FieldValue.serverTimestamp()`, so it can
/// be null for the short time between the local write and the server
/// acknowledgement.
class ChatMessage {
  static const Duration editWindow = Duration(hours: 24);

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final DateTime? editedAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.editedAt,
  });

  /// Reads a message document, tolerating every missing field.
  factory ChatMessage.fromDocument(Map<String, dynamic>? data, String id) {
    final map = chatMap(data);
    return ChatMessage(
      id: id,
      senderId: chatString(map['senderId']),
      text: chatString(map['text']),
      createdAt: chatDateTime(map['createdAt']),
      editedAt: chatDateTime(map['editedAt']),
    );
  }

  bool get isEdited => editedAt != null;

  /// True when [uid] may still edit or delete this message.
  ///
  /// The deployed rules enforce the same 24-hour window; the UI uses
  /// this only to hide the buttons.
  bool canModify(String uid, {DateTime? now}) {
    final created = createdAt;
    if (senderId != uid || created == null) return false;
    return (now ?? DateTime.now()).difference(created) < editWindow;
  }

  ChatMessage copyWith({String? text, DateTime? editedAt}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text ?? this.text,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    if (createdAt != null) 'createdAt': chatTimestamp(createdAt),
    if (editedAt != null) 'editedAt': chatTimestamp(editedAt),
  };
}

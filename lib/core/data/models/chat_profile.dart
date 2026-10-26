import 'chat_parsing.dart';

/// The display data a participant copied into the chat document.
///
/// Users documents are readable only by their owner, so the tourist
/// copies both participants' name and avatar into `profiles.<uid>` when
/// the chat is created. Rules allow only these two fields.
class ChatProfile {
  final String displayName;
  final String avatarUrl;

  const ChatProfile({this.displayName = '', this.avatarUrl = ''});

  /// Reads one `profiles.<uid>` entry, tolerating a missing or malformed
  /// entry.
  factory ChatProfile.fromMap(Object? data) {
    final map = chatMap(data);
    return ChatProfile(
      displayName: chatString(map['displayName']),
      avatarUrl: chatString(map['avatarUrl']),
    );
  }

  /// Reads a standalone profile document (used by the tests and by
  /// callers that already hold the map).
  factory ChatProfile.fromDocument(Map<String, dynamic>? data) =>
      ChatProfile.fromMap(data);

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };

  ChatProfile copyWith({String? displayName, String? avatarUrl}) {
    return ChatProfile(
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

import 'chat_parsing.dart';

/// A report of one chat message.
///
/// The report copies the message's text, sender and creation time, and
/// the deployed rules compare those copies with the real message, so
/// the evidence cannot be forged. The document id is deterministic:
/// `{reporterId}_{messageId}`.
class Report {
  /// The fixed reason codes accepted by the rules.
  static const List<String> reasonCodes = <String>[
    'spam',
    'harassment',
    'inappropriate_content',
    'other',
  ];

  final String id;
  final String reporterId;
  final String reportedUserId;
  final String chatId;
  final String messageId;
  final String text;
  final DateTime? messageCreatedAt;
  final String reasonCode;
  final String note;
  final String status;
  final String? reviewerId;
  final String? reviewNote;
  final DateTime? createdAt;

  const Report({
    required this.id,
    this.reporterId = '',
    this.reportedUserId = '',
    this.chatId = '',
    this.messageId = '',
    this.text = '',
    this.messageCreatedAt,
    this.reasonCode = '',
    this.note = '',
    this.status = '',
    this.reviewerId,
    this.reviewNote,
    this.createdAt,
  });

  /// Builds the deterministic id required by the rules.
  static String idFor(String reporterId, String messageId) =>
      '${reporterId}_$messageId';

  static bool isReasonCode(String code) => reasonCodes.contains(code);

  /// Reads a report document, tolerating every missing field.
  factory Report.fromDocument(Map<String, dynamic>? data, String id) {
    final map = chatMap(data);
    return Report(
      id: id,
      reporterId: chatString(map['reporterId']),
      reportedUserId: chatString(map['reportedUserId']),
      chatId: chatString(map['chatId']),
      messageId: chatString(map['messageId']),
      text: chatString(map['text']),
      messageCreatedAt: chatDateTime(map['messageCreatedAt']),
      reasonCode: chatString(map['reasonCode']),
      note: chatString(map['note']),
      status: chatString(map['status']),
      reviewerId: map['reviewerId'] is String
          ? map['reviewerId'] as String
          : null,
      reviewNote: map['reviewNote'] is String
          ? map['reviewNote'] as String
          : null,
      createdAt: chatDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'reporterId': reporterId,
    'reportedUserId': reportedUserId,
    'chatId': chatId,
    'messageId': messageId,
    'text': text,
    if (messageCreatedAt != null)
      'messageCreatedAt': chatTimestamp(messageCreatedAt),
    'reasonCode': reasonCode,
    'note': note,
    'status': status,
    if (reviewerId != null) 'reviewerId': reviewerId,
    if (reviewNote != null) 'reviewNote': reviewNote,
    if (createdAt != null) 'createdAt': chatTimestamp(createdAt),
  };
}

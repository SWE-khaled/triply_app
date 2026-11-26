class BookingRequest {
  final String id;
  final String guestName;
  final String tourTitle;
  final String detailLabel;
  final String avatarUrl;
  final bool isPrivate;

  const BookingRequest({
    required this.id,
    required this.guestName,
    required this.tourTitle,
    required this.detailLabel,
    required this.avatarUrl,
    required this.isPrivate,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] as String,
      guestName: json['guest_name'] as String? ?? '',
      tourTitle: json['tour_title'] as String? ?? '',
      detailLabel: json['detail_label'] as String? ?? '',
      avatarUrl: _firstNonEmptyString([
        json['avatar_url'],
        json['avatarUrl'],
        json['photoUrl'],
        json['photoURL'],
        json['guestAvatarUrl'],
      ]),
      isPrivate: json['is_private'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'tour_title': tourTitle,
      'detail_label': detailLabel,
      'avatar_url': avatarUrl,
      'is_private': isPrivate,
    };
  }
}

String _firstNonEmptyString(Iterable<Object?> values) {
  for (final value in values) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

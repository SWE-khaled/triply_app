class BookingDetails {
  final String id;
  final String guestName;
  final String country;
  final int travelerCount;
  final String avatarUrl;
  final bool isPrivate;
  final String tourTitle;
  final String datetimeLabel;
  final String location;
  final String bookingCode;
  final String priceLabel;

  const BookingDetails({
    required this.id,
    required this.guestName,
    required this.country,
    required this.travelerCount,
    required this.avatarUrl,
    required this.isPrivate,
    required this.tourTitle,
    required this.datetimeLabel,
    required this.location,
    required this.bookingCode,
    required this.priceLabel,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'] as String,
      guestName: json['guest_name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      travelerCount: (json['traveler_count'] as num? ?? 1).toInt(),
      avatarUrl: json['avatar_url'] as String? ?? '',
      isPrivate: json['is_private'] as bool? ?? true,
      tourTitle: json['tour_title'] as String? ?? '',
      datetimeLabel: json['datetime_label'] as String? ?? '',
      location: json['location'] as String? ?? '',
      bookingCode: json['booking_code'] as String? ?? '',
      priceLabel: json['price_label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'country': country,
      'traveler_count': travelerCount,
      'avatar_url': avatarUrl,
      'is_private': isPrivate,
      'tour_title': tourTitle,
      'datetime_label': datetimeLabel,
      'location': location,
      'booking_code': bookingCode,
      'price_label': priceLabel,
    };
  }

  String get travelerLabel =>
      '$travelerCount ${travelerCount == 1 ? 'traveler' : 'travelers'}';
}

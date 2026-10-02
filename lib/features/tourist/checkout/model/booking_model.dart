
class CheckoutBookingSummary {
  final String guideId;
  final String guideName;
  final String guideSpecialty;
  final String guideAvatarUrl;
  final String dateLabel;
  final String timeSlot;
  final String durationLabel;
  final int travelers;
  final String meetingPoint;
  final double pricePerHour;
  final String currency;
  final double serviceFee;
  final double total;

  const CheckoutBookingSummary({
    required this.guideId,
    required this.guideName,
    required this.guideSpecialty,
    required this.guideAvatarUrl,
    required this.dateLabel,
    required this.timeSlot,
    required this.durationLabel,
    required this.travelers,
    required this.meetingPoint,
    required this.pricePerHour,
    required this.currency,
    required this.serviceFee,
    required this.total,
  });


  factory CheckoutBookingSummary.figmaExample() {
    return const CheckoutBookingSummary(
      guideId: 'g1',
      guideName: 'Omar El-Rashidy',
      guideSpecialty: 'Ancient Egypt & Archaeology',
      guideAvatarUrl: '',
      dateLabel: '2026-09-25',
      timeSlot: '7:00 AM',
      durationLabel: '6 hours',
      travelers: 2,
      meetingPoint: 'Hotel Lobby',
      pricePerHour: 85,
      currency: 'EGP',
      serviceFee: 51,
      total: 1071,
    );
  }

  factory CheckoutBookingSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutBookingSummary(
      guideId: json['guide_id'] as String? ?? '',
      guideName: json['guide_name'] as String? ?? '',
      guideSpecialty: json['guide_specialty'] as String? ?? '',
      guideAvatarUrl: json['guide_avatar_url'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      timeSlot: json['time_slot'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      travelers: (json['travelers'] as num? ?? 1).toInt(),
      meetingPoint: json['meeting_point'] as String? ?? '',
      pricePerHour: (json['price_per_hour'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      serviceFee: (json['service_fee'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guide_id': guideId,
      'guide_name': guideName,
      'guide_specialty': guideSpecialty,
      'guide_avatar_url': guideAvatarUrl,
      'date_label': dateLabel,
      'time_slot': timeSlot,
      'duration_label': durationLabel,
      'travelers': travelers,
      'meeting_point': meetingPoint,
      'price_per_hour': pricePerHour,
      'currency': currency,
      'service_fee': serviceFee,
      'total': total,
    };
  }

  String get travelersLabel =>
      '$travelers${travelers == 1 ? 'person' : 'people'}';
}


class PaymobBillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String country;
  final String city;
  final String street;
  final String building;
  final String apartment;
  final String floor;
  final String postalCode;
  final String state;

  const PaymobBillingData({
    required this.firstName,
    required this.lastName,
    this.email = 'guest@triply.app',
    this.phoneNumber = '+201000000000',
    required this.country,
    this.city = 'Cairo',
    required this.street,
    this.building = '8028',
    this.apartment = '801',
    this.floor = '4',
    this.postalCode = '11511',
    this.state = 'Cairo',
  });


  Map<String, dynamic> toJson() {
    return {
      'apartment': _or(apartment, '801'),
      'email': _or(email, 'guest@triply.app'),
      'floor': _or(floor, '4'),
      'first_name': _or(firstName, 'Guest'),
      'street': _or(street, 'El-Tahrir Street'),
      'building': _or(building, '8028'),
      'phone_number': _or(phoneNumber, '+201000000000'),
      'shipping_method': 'PKG',
      'postal_code': _or(postalCode, '11511'),
      'city': _or(city, 'Cairo'),
      'country': _or(country, 'EG'),
      'last_name': _or(lastName, 'User'),
      'state': _or(state, 'Cairo'),
    };
  }


  static String _or(String value, String fallback) {
    final v = value.trim();
    return v.isEmpty ? fallback : v;
  }
}
/// The public profile of a tour guide.
///
/// The guide writes it under its own uid, and the admin approves it. The
/// tourists browse the approved ones — the id is the uid, so the trips of
/// a guide are found by the very same key the trip documents carry.
class PublicGuide {
  final String id;

  final String name;
  final String specialty;
  final String avatarUrl;
  final String coverUrl;
  final String location;
  final String about;
  final List<String> languages;
  final double rating;
  final int reviewCount;

  /// The guide's hourly rate in EGP.
  final double pricePerHour;

  final String currency;

  /// Whether the admin approved the guide.
  final bool isApproved;

  const PublicGuide({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.coverUrl,
    required this.location,
    required this.about,
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.currency,
    required this.isApproved,
  });

  /// Reads a guide document, tolerating every missing field.
  factory PublicGuide.fromDocument(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'name': '',
      'specialty': '',
      'avatarUrl': '',
      'coverUrl': '',
      'location': '',
      'about': '',
      'languages': const <String>[],
      'rating': 0,
      'reviewCount': 0,
      'pricePerHour': 0,
      'currency': '\$',
      'isApproved': false,
      ...?data,
    };
    merged['id'] = id;
    return PublicGuide(
      id: id,
      name: (merged['name'] as String?) ?? '',
      specialty: (merged['specialty'] as String?) ?? '',
      avatarUrl: (merged['avatarUrl'] as String?) ?? '',
      coverUrl: (merged['coverUrl'] as String?) ?? '',
      location: (merged['location'] as String?) ?? '',
      about: (merged['about'] as String?) ?? '',
      languages: _strings(merged['languages']),
      rating: ((merged['rating'] as num?) ?? 0).toDouble(),
      reviewCount: ((merged['reviewCount'] as num?) ?? 0).toInt(),
      pricePerHour: ((merged['pricePerHour'] as num?) ?? 0).toDouble(),
      currency: (merged['currency'] as String?) ?? '\$',
      isApproved: (merged['isApproved'] as bool?) ?? false,
    );
  }

  static List<String> _strings(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}

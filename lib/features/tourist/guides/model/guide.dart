/// Represents a tour guide shown in GuidesList (and later Profile/Chat/Booking).
/// UI must consume this Model, never raw Maps or API JSON directly.
class Guide {
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
  final double pricePerHour;
  final String currency; // e.g. "\$" — locked display rule for list
  final bool isVerified;

  const Guide({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    this.coverUrl = '',
    this.location = '',
    this.about = '',
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.currency,
    this.isVerified = true,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      about: json['about'] as String? ?? '',
      languages: (json['languages'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      reviewCount: (json['review_count'] as num? ?? 0).toInt(),
      pricePerHour: (json['price_per_hour'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? '\$',
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'location': location,
      'about': about,
      'languages': languages,
      'rating': rating,
      'review_count': reviewCount,
      'price_per_hour': pricePerHour,
      'currency': currency,
      'is_verified': isVerified,
    };
  }
}

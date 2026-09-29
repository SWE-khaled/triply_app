class Guide {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewsCount;
  final double pricePerHour;
  final String avatarUrl;
  final bool verified;

  Guide({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerHour,
    required this.avatarUrl,
    this.verified = true,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      avatarUrl: json['avatar_url'] as String,
      verified: json['verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviews_count': reviewsCount,
      'price_per_hour': pricePerHour,
      'avatar_url': avatarUrl,
      'verified': verified,
    };
  }
}

class Guide {
  final String id;
  final String name;
  final String specialty;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final double pricePerHour;

  const Guide({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      reviewCount: (json['review_count'] as num? ?? 0).toInt(),
      pricePerHour: (json['price_per_hour'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatar_url': avatarUrl,
      'rating': rating,
      'review_count': reviewCount,
      'price_per_hour': pricePerHour,
    };
  }
}

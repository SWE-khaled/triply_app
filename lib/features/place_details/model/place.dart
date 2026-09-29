class Place {
  final String id;
  final String name;
  final String city;
  final String category;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final String shortDescription;
  final String about;
  final List<String> highlights;
  final String imageUrl;
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    this.type = 'place',
    this.address = '',
    this.latitude = 0,
    this.longitude = 0,
    required this.rating,
    required this.reviewsCount,
    required this.shortDescription,
    required this.about,
    required this.highlights,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      category: json['category'] as String,
      type: json['type'] as String? ?? 'place',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      shortDescription: json['short_description'] as String,
      about: json['about'] as String,
      highlights: List<String>.from(json['highlights'] as List),
      imageUrl: json['image_url'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'category': category,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviews_count': reviewsCount,
      'short_description': shortDescription,
      'about': about,
      'highlights': highlights,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }
}

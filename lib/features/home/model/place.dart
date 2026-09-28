class Place {
  final String id;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final bool isFavorite;

  const Place({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'Egypt',
      imageUrl: json['image_url'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }

  Place copyWith({bool? isFavorite}) {
    return Place(
      id: id,
      name: name,
      city: city,
      country: country,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

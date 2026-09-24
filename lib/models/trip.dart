class Trip {
  final String id;
  final String title;
  final String imageUrl;
  final String duration;
  final String location;
  final double price;

  const Trip({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.location,
    required this.price,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      location: json['location'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'duration': duration,
      'location': location,
      'price': price,
    };
  }
}

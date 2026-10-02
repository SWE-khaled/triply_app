class Trip {
  final String id;
  final String placeId;
  final String title;
  final String dateTime;
  final String guideName;
  final int peopleCount;
  final double price;
  final String currency;
  final String imageUrl;

  Trip({
    required this.id,
    required this.placeId,
    required this.title,
    required this.dateTime,
    required this.guideName,
    required this.peopleCount,
    required this.price,
    required this.currency,
    required this.imageUrl,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      title: json['title'] as String,
      dateTime: json['date_time'] as String,
      guideName: json['guide_name'] as String,
      peopleCount: json['people_count'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'title': title,
      'date_time': dateTime,
      'guide_name': guideName,
      'people_count': peopleCount,
      'price': price,
      'currency': currency,
      'image_url': imageUrl,
    };
  }
}

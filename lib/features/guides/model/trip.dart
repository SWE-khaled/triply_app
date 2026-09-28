/// Trip offered by a guide (shown on GuideProfileScreen).
/// UI consumes this Model, never raw Maps.
class Trip {
  final String id;
  final String guideId;
  final String title;
  final String imageUrl;
  final String dateLabel; // e.g. "Oct 22, 2026" — Figma shows label as-is
  final String durationLabel; // e.g. "5 hours"
  final double price;
  final String currency; // e.g. "EGP"

  const Trip({
    required this.id,
    required this.guideId,
    required this.title,
    required this.imageUrl,
    required this.dateLabel,
    required this.durationLabel,
    required this.price,
    required this.currency,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      guideId: json['guide_id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guide_id': guideId,
      'title': title,
      'image_url': imageUrl,
      'date_label': dateLabel,
      'duration_label': durationLabel,
      'price': price,
      'currency': currency,
    };
  }
}

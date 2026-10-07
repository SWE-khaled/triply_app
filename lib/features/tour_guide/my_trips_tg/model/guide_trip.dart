enum GuideTripStatus { active, pending, rejected, completed, cancelled }

class GuideTrip {
  final String id;
  final String title;
  final String location;
  final String scheduleLabel;
  final double priceEgp;
  final String imageUrl;
  final GuideTripStatus status;

  /// Guide contact number for this trip (entered in Add/Edit Trip).
  final String phone;

  /// Rejected-state extras (null for all other statuses).
  final String? duration;
  final String? rejectionReason;

  const GuideTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.scheduleLabel,
    required this.priceEgp,
    required this.imageUrl,
    required this.status,
    this.phone = '',
    this.duration,
    this.rejectionReason,
  });

  factory GuideTrip.fromJson(Map<String, dynamic> json) {
    return GuideTrip(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      scheduleLabel: json['scheduleLabel'] as String,
      priceEgp: (json['priceEgp'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      status: GuideTripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GuideTripStatus.active,
      ),
      phone: json['phone'] as String? ?? '',
      duration: json['duration'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'scheduleLabel': scheduleLabel,
      'priceEgp': priceEgp,
      'imageUrl': imageUrl,
      'status': status.name,
      'phone': phone,
      'duration': duration,
      'rejectionReason': rejectionReason,
    };
  }
}

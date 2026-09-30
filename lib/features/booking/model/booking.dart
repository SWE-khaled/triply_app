
class Booking {
  final String id;
  final String guideId;
  final String dateLabel;
  final String timeSlot;
  final String durationLabel;
  final int durationHours;
  final int travelers;
  final String meetingPoint;
  final String notes;
  final double pricePerHour;
  final double serviceFee;
  final double total;

  const Booking({
    required this.id,
    required this.guideId,
    required this.dateLabel,
    required this.timeSlot,
    required this.durationLabel,
    required this.durationHours,
    required this.travelers,
    required this.meetingPoint,
    required this.notes,
    required this.pricePerHour,
    required this.serviceFee,
    required this.total,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? '',
      guideId: json['guide_id'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      timeSlot: json['time_slot'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      durationHours: (json['duration_hours'] as num? ?? 0).toInt(),
      travelers: (json['travelers'] as num? ?? 1).toInt(),
      meetingPoint: json['meeting_point'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      pricePerHour: (json['price_per_hour'] as num? ?? 0).toDouble(),
      serviceFee: (json['service_fee'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guide_id': guideId,
      'date_label': dateLabel,
      'time_slot': timeSlot,
      'duration_label': durationLabel,
      'duration_hours': durationHours,
      'travelers': travelers,
      'meeting_point': meetingPoint,
      'notes': notes,
      'price_per_hour': pricePerHour,
      'service_fee': serviceFee,
      'total': total,
    };
  }
}

class Booking {
  final String tripId;
  final int seats;
  final String specialRequests;
  final double unitPrice;
  final double serviceFee;
  final double total;

  const Booking({
    required this.tripId,
    required this.seats,
    required this.specialRequests,
    required this.unitPrice,
    required this.serviceFee,
    required this.total,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      tripId: json['tripId'] as String,
      seats: json['seats'] as int,
      specialRequests: (json['specialRequests'] ?? '') as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'seats': seats,
      'specialRequests': specialRequests,
      'unitPrice': unitPrice,
      'serviceFee': serviceFee,
      'total': total,
    };
  }
}

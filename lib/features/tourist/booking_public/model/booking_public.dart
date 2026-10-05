class BookingPublic {
  final String tripId;
  final int seats;
  final String specialRequests;
  final double unitPrice;
  final double serviceFee;
  final double total;

  /// Admin-approval status. New bookings always start as 'pending'.
  final String status;

  const BookingPublic({
    required this.tripId,
    required this.seats,
    required this.specialRequests,
    required this.unitPrice,
    required this.serviceFee,
    required this.total,
    this.status = 'pending',
  });

  factory BookingPublic.fromJson(Map<String, dynamic> json) {
    return BookingPublic(
      tripId: json['tripId'] as String,
      seats: json['seats'] as int,
      specialRequests: (json['specialRequests'] ?? '') as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: (json['status'] ?? 'pending') as String,
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
      'status': status,
    };
  }
}

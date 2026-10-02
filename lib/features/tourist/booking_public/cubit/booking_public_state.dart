class BookingPublicState {
  final int seats;
  final String specialRequests;

  /// Seats left for this trip (= capacity - peopleCount), min 1.
  final int maxSpots;

  const BookingPublicState({
    required this.seats,
    required this.specialRequests,
    required this.maxSpots,
  });

  BookingPublicState copyWith({int? seats, String? specialRequests, int? maxSpots}) {
    return BookingPublicState(
      seats: seats ?? this.seats,
      specialRequests: specialRequests ?? this.specialRequests,
      maxSpots: maxSpots ?? this.maxSpots,
    );
  }
}

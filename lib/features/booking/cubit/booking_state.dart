class BookingState {
  final int seats;
  final String specialRequests;

  /// Seats left for this trip (= capacity - peopleCount), min 1.
  final int maxSpots;

  const BookingState({
    required this.seats,
    required this.specialRequests,
    required this.maxSpots,
  });

  BookingState copyWith({int? seats, String? specialRequests, int? maxSpots}) {
    return BookingState(
      seats: seats ?? this.seats,
      specialRequests: specialRequests ?? this.specialRequests,
      maxSpots: maxSpots ?? this.maxSpots,
    );
  }
}

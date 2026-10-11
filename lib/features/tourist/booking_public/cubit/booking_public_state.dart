class BookingPublicState {
  final int seats;
  final String specialRequests;

  /// Seats left for this trip (= capacity - peopleCount), min 1.
  final int maxSpots;

  /// True while a `createBooking` submission is in flight. The Confirm
  /// button is disabled then, so duplicate taps cannot create a second
  /// booking (the in-flight request owns the idempotency key).
  final bool isSubmitting;

  const BookingPublicState({
    required this.seats,
    required this.specialRequests,
    required this.maxSpots,
    this.isSubmitting = false,
  });

  BookingPublicState copyWith({
    int? seats,
    String? specialRequests,
    int? maxSpots,
    bool? isSubmitting,
  }) {
    return BookingPublicState(
      seats: seats ?? this.seats,
      specialRequests: specialRequests ?? this.specialRequests,
      maxSpots: maxSpots ?? this.maxSpots,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

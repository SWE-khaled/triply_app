class BookingPublicState {
  final int seats;
  final String specialRequests;

  /// Seats left for this trip (= capacity - peopleCount), min 1.
  final int maxSpots;

  /// `'card'` or `'wallet'`, chosen by the tourist before paying.
  final String paymentMethod;

  const BookingPublicState({
    required this.seats,
    required this.specialRequests,
    required this.maxSpots,
    this.paymentMethod = 'card',
  });

  BookingPublicState copyWith({
    int? seats,
    String? specialRequests,
    int? maxSpots,
    String? paymentMethod,
  }) {
    return BookingPublicState(
      seats: seats ?? this.seats,
      specialRequests: specialRequests ?? this.specialRequests,
      maxSpots: maxSpots ?? this.maxSpots,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

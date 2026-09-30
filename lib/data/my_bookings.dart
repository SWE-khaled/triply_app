/// Session-only record of confirmed bookings (mock phase, no backend).
/// TripsCubit-style consumers read this; BookingCubit writes it.
/// Later: replaced by API orders — Views/Cubits keep the same calls.
class MyBookings {
  MyBookings._();

  static final Map<String, int> _seatsByTrip = <String, int>{};

  static void record(String tripId, int seats) {
    _seatsByTrip[tripId] = seats;
  }

  static bool isBooked(String tripId) => _seatsByTrip.containsKey(tripId);

  static Set<String> get bookedIds => Set.unmodifiable(_seatsByTrip.keys);

  static int seatsFor(String tripId) => _seatsByTrip[tripId] ?? 0;
}

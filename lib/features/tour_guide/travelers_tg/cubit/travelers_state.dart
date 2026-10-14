import '../model/traveler.dart';

class TravelersState {
  final List<Traveler> travelers;
  final bool isLoading;
  final String? error;

  const TravelersState({
    required this.travelers,
    this.isLoading = false,
    this.error,
  });

  TravelersState copyWith({
    List<Traveler>? travelers,
    bool? isLoading,
    String? error,
  }) {
    return TravelersState(
      travelers: travelers ?? this.travelers,
      isLoading: isLoading ?? this.isLoading,
      // Null clears a previous error; pass the current error to preserve.
      error: error,
    );
  }
}

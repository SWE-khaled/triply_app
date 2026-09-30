import '../model/trip_details.dart';

class TripDetailsState {
  final TripDetails? details;
  final int selectedTab;
  final bool isFavorite;

  const TripDetailsState({
    required this.details,
    required this.selectedTab,
    required this.isFavorite,
  });

  TripDetailsState copyWith({
    TripDetails? details,
    int? selectedTab,
    bool? isFavorite,
  }) {
    return TripDetailsState(
      details: details ?? this.details,
      selectedTab: selectedTab ?? this.selectedTab,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

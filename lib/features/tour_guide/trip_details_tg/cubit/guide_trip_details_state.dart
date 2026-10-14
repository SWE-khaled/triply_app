import '../model/guide_trip_details.dart';

class GuideTripDetailsState {
  final GuideTripDetails? details;
  final int selectedTab;
  final String? error;

  const GuideTripDetailsState({
    required this.details,
    required this.selectedTab,
    this.error,
  });

  GuideTripDetailsState copyWith({
    GuideTripDetails? details,
    int? selectedTab,
    String? error,
  }) {
    return GuideTripDetailsState(
      details: details ?? this.details,
      selectedTab: selectedTab ?? this.selectedTab,
      error: error,
    );
  }
}

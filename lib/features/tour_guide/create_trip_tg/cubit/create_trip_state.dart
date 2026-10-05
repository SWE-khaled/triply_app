import '../model/guide_trip_draft.dart';

/// Dynamic rows + picked cover path. Static fields live in the
/// cubit's controllers. Cover stays a local file path (mock phase:
/// picked from gallery, previewed, never uploaded — no backend yet).
class CreateTripState {
  final List<HighlightDraft> highlights;
  final List<ItineraryStopDraft> itinerary;
  final String? coverImagePath;

  const CreateTripState({
    required this.highlights,
    required this.itinerary,
    required this.coverImagePath,
  });

  factory CreateTripState.initial() {
    return const CreateTripState(
      highlights: [HighlightDraft(id: 'h0', text: '')],
      itinerary: [ItineraryStopDraft(id: 's0', time: '', activity: '')],
      coverImagePath: null,
    );
  }

  CreateTripState copyWith({
    List<HighlightDraft>? highlights,
    List<ItineraryStopDraft>? itinerary,
    String? coverImagePath,
    bool clearCover = false,
  }) {
    return CreateTripState(
      highlights: highlights ?? this.highlights,
      itinerary: itinerary ?? this.itinerary,
      coverImagePath: clearCover ? null : coverImagePath ?? this.coverImagePath,
    );
  }
}

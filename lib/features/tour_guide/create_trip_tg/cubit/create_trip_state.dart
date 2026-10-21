part of 'create_trip_cubit.dart';

@immutable
sealed class CreateTripState {
  /// The highlight rows of the form.
  final List<HighlightDraft> highlights;

  /// The itinerary rows of the form.
  final List<ItineraryStopDraft> itinerary;

  /// The cover of the trip.
  ///
  /// Either the local path of a freshly picked file, or the URL of the
  /// cover the trip already has — so editing a trip shows its current
  /// image instead of an empty box.
  final String? cover;

  const CreateTripState({
    required this.highlights,
    required this.itinerary,
    required this.cover,
  });
}

/// The form is pristine — nothing typed yet.
final class CreateTripInitial extends CreateTripState {
  const CreateTripInitial()
    : super(highlights: const [], itinerary: const [], cover: null);
}

/// The trip is being sent to Firestore.
final class CreateTripLoading extends CreateTripState {
  const CreateTripLoading({
    required super.highlights,
    required super.itinerary,
    required super.cover,
  });
}

/// The form content — ready to submit.
final class CreateTripSuccess extends CreateTripState {
  const CreateTripSuccess({
    required super.highlights,
    required super.itinerary,
    required super.cover,
  });
}

/// The trip could not be submitted.
final class CreateTripError extends CreateTripState {
  final String error;

  const CreateTripError({
    required super.highlights,
    required super.itinerary,
    required super.cover,
    required this.error,
  });
}

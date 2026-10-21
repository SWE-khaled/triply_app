import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/repositories/public_trips_repository.dart';
import '../../../../core/data/trip_details_source.dart';
import '../../trips/models/trip.dart';
import 'trip_details_state.dart';

/// Owns details loading, tab selection and favorite state.
/// Favorites are session-only (mock phase); the API phase persists them.
class TripDetailsCubit extends Cubit<TripDetailsState> {
  static final Set<String> _favoriteIds = <String>{};
  final TripDetailsSource _source;
  final PublicTripsRepository _repository;

  TripDetailsCubit({
    TripDetailsSource? source,
    PublicTripsRepository? repository,
  }) : _source = source ?? const TripDetailsSource(),
       _repository = repository ?? PublicTripsRepository(),
       super(
         const TripDetailsState(
           details: null,
           selectedTab: 0,
           isFavorite: false,
         ),
       );

  /// Loads the trip from Firestore.
  ///
  /// The bundled dataset is the fallback for when the read fails, and it
  /// keeps the trip's own card fields so a trip never shows another
  /// trip's content.
  Future<void> loadTrip(Trip trip) async {
    emit(state.copyWith(isFavorite: _favoriteIds.contains(trip.id)));

    final remote = await _repository.fetchTripDetails(trip.id);
    final details =
        remote ??
        _source.getByTripId(
          trip.id,
          title: trip.title,
          imageUrl: trip.imageUrl,
          priceEgp: trip.priceEgp,
          guideName: trip.guideName,
        );

    emit(
      state.copyWith(
        details: details,
        isFavorite: _favoriteIds.contains(trip.id),
      ),
    );
  }

  void selectTab(int index) => emit(state.copyWith(selectedTab: index));

  /// Toggles favorite, returns the new state for the View's toast.
  bool toggleFavorite(String tripId) {
    final nowFavorite = !_favoriteIds.contains(tripId);
    if (nowFavorite) {
      _favoriteIds.add(tripId);
    } else {
      _favoriteIds.remove(tripId);
    }
    emit(state.copyWith(isFavorite: nowFavorite));
    return nowFavorite;
  }
}

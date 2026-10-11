import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import '../../../../core/data/trip_details_source.dart';
import '../../trips/models/trip.dart';
import '../model/trip_details.dart';
import 'trip_details_state.dart';

/// Owns details loading, tab selection and favorite state.
/// Favorites are session-only (mock phase); the API phase persists them.
///
/// Remote details load by real trip id; the local baseline is an honest
/// shell for unknown ids (never another trip's content). Missing docs and
/// errors keep the baseline with an explicit notice in the View.
///
/// Kill-switch: [useRemote] gates every remote call in the View. Phase 1
/// (trip details) is activated; flipping back to `false` is instant rollback.
class TripDetailsCubit extends Cubit<TripDetailsState> {
  static const bool useRemote = true;

  static final Set<String> _favoriteIds = <String>{};
  final TripDetailsSource _source;
  final TripsRepository _repository;

  TripDetailsCubit({TripDetailsSource? source, TripsRepository? repository})
    : _source = source ?? const TripDetailsSource(),
      _repository = repository ?? TripsRepository(),
      super(
        const TripDetailsState(
          details: null,
          selectedTab: 0,
          isFavorite: false,
        ),
      );

  void loadTrip(Trip trip) {
    emit(
      state.copyWith(
        details: _source.getByTripId(
          trip.id,
          title: trip.title,
          imageUrl: trip.imageUrl,
          priceEgp: trip.priceEgp,
          guideName: trip.guideName,
        ),
        isFavorite: _favoriteIds.contains(trip.id),
      ),
    );
  }

  void selectTab(int index) => emit(state.copyWith(selectedTab: index));

  /// Best-effort remote details refresh. Returns true when Firestore
  /// details replaced the mock ones; false keeps them (missing doc,
  /// permission, network) — callers must surface this, never present
  /// mock details as a successful Firestore read.
  Future<bool> loadRemote(String tripId) async {
    try {
      final result = await _repository.tripDetails(tripId);
      if (result is FirestoreOk<TripDetails>) {
        emit(state.copyWith(details: result.data));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: TripDetailsCubit.loadRemote failed: $e');
      return false;
    }
    debugPrint('Triply: TripDetailsCubit.loadRemote kept mock details.');
    return false;
  }

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

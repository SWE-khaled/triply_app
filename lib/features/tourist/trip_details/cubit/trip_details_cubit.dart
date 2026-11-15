import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/auth/data/auth_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/data/trip_details_source.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../trips/models/trip.dart';
import '../model/trip_details.dart';

part 'trip_details_state.dart';

/// Owns details loading, tab selection and favorite state.
/// Favorites are session-only (mock phase); the API phase persists them.
class TripDetailsCubit extends Cubit<TripDetailsState>
    with SafeEmitMixin<TripDetailsState> {
  TripDetailsCubit({
    TripDetailsSource? source,
    PublicTripsRepository? repository,
  }) : _source = source ?? const TripDetailsSource(),
       _repository = repository ?? PublicTripsRepository(),
       super(const TripDetailsInitial());

  static final Set<String> _favoriteIds = <String>{};
  final Map<String, TripDetailsSuccess> _loadedTrips = {};
  final Map<String, Future<String?>> _guidePhoneRequests = {};

  final TripDetailsSource _source;
  final PublicTripsRepository _repository;

  /// The tab of the details that is open.
  int _selectedTab = 0;
  String? _loadingTripId;

  Future<String?> guidePhone(String guideId) {
    if (guideId.isEmpty) return Future<String?>.value(null);
    return _guidePhoneRequests.putIfAbsent(
      guideId,
      () => AuthRepository().getUserPhone(guideId),
    );
  }

  /// Loads the trip from Firestore.
  ///
  /// The bundled dataset is the fallback for when the read fails, and it
  /// keeps the trip's own card fields so a trip never shows another
  /// trip's content.
  Future<void> loadTrip(Trip trip) async {
    final cached = _loadedTrips[trip.id];
    if (cached != null) {
      _selectedTab = cached.selectedTab;
      safeEmit(
        TripDetailsSuccess(
          details: cached.details,
          selectedTab: cached.selectedTab,
          isFavorite: _favoriteIds.contains(trip.id),
        ),
      );
      return;
    }
    if (_loadingTripId == trip.id) return;
    _loadingTripId = trip.id;
    safeEmit(const TripDetailsLoading());
    try {
      final remote = await _repository.fetchTrip(trip.id, rethrowOnError: true);
      final details = remote != null
          ? TripDetails.fromPublicTrip(remote)
          : _source.getByTripId(
              trip.id,
              title: trip.title,
              imageUrl: trip.imageUrl,
              priceEgp: trip.priceEgp,
              guideName: trip.guideName,
            );
      final success = TripDetailsSuccess(
        details: details,
        selectedTab: _selectedTab,
        isFavorite: _favoriteIds.contains(trip.id),
      );
      _loadedTrips[trip.id] = success;
      safeEmit(success);
    } catch (error) {
      safeEmit(TripDetailsError(error: pageLoadErrorMessage(error)));
    } finally {
      _loadingTripId = null;
    }
  }

  void selectTab(int index) {
    _selectedTab = index;
    final current = state;
    if (current is! TripDetailsSuccess) return;
    final updated = TripDetailsSuccess(
      details: current.details,
      selectedTab: index,
      isFavorite: current.isFavorite,
    );
    safeEmit(updated);
    _loadedTrips[current.details.id] = updated;
  }

  /// Toggles favorite, returns the new state for the View's toast.
  bool toggleFavorite(String tripId) {
    final nowFavorite = !_favoriteIds.contains(tripId);
    if (nowFavorite) {
      _favoriteIds.add(tripId);
    } else {
      _favoriteIds.remove(tripId);
    }
    final current = state;
    if (current is TripDetailsSuccess) {
      final updated = TripDetailsSuccess(
        details: current.details,
        selectedTab: current.selectedTab,
        isFavorite: nowFavorite,
      );
      safeEmit(updated);
      _loadedTrips[updated.details.id] = updated;
    }
    return nowFavorite;
  }
}

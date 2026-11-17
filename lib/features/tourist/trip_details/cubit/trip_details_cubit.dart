import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final Map<String, TripDetails> _detailsCache = {};
  final Map<String, int> _tabByTrip = {};

  final TripDetailsSource _source;
  final PublicTripsRepository _repository;

  /// Authoritative data for the currently open details page.
  TripDetails? _openDetails;

  /// The tab of the details that is open.
  int _selectedTab = 0;
  String? _loadingTripId;

  /// Loads the trip from Firestore.
  ///
  /// The bundled dataset is the fallback for when the read fails, and it
  /// keeps the trip's own card fields so a trip never shows another
  /// trip's content.
  Future<void> loadTrip(Trip trip) async {
    final cachedDetails = _detailsCache[trip.id];
    if (cachedDetails != null) {
      final details = cachedDetails.withGuideFallback(
        guideId: trip.guideId,
        guideAvatarUrl: trip.guideAvatarUrl,
      );
      _detailsCache[trip.id] = details;
      _openDetails = details;
      _selectedTab = _tabByTrip[trip.id] ?? 0;
      safeEmit(
        TripDetailsSuccess(
          details: details,
          selectedTab: _selectedTab,
          isFavorite: _favoriteIds.contains(trip.id),
        ),
      );
      return;
    }
    if (_loadingTripId == trip.id) return;
    _loadingTripId = trip.id;
    // A new trip may show the details skeleton, but a retry of a failed
    // trip keeps its error view instead of restarting the shimmer.
    if (state is! TripDetailsError) safeEmit(const TripDetailsLoading());
    try {
      final remote = await _repository.fetchTrip(trip.id);
      final details = remote != null
          ? TripDetails.fromPublicTrip(
              remote,
              fallbackGuideId: trip.guideId,
              fallbackGuideAvatarUrl: trip.guideAvatarUrl,
            )
          : _source.getByTripId(
              trip.id,
              title: trip.title,
              imageUrl: trip.imageUrl,
              priceEgp: trip.priceEgp,
              guideName: trip.guideName,
              guideId: trip.guideId,
              guideAvatarUrl: trip.guideAvatarUrl,
            );
      _detailsCache[trip.id] = details;
      _tabByTrip[trip.id] = _selectedTab;
      _openDetails = details;
      safeEmit(
        TripDetailsSuccess(
          details: details,
          selectedTab: _selectedTab,
          isFavorite: _favoriteIds.contains(trip.id),
        ),
      );
    } catch (error) {
      safeEmit(TripDetailsError(error: pageLoadErrorMessage(error)));
    } finally {
      _loadingTripId = null;
    }
  }

  void selectTab(int index) {
    _selectedTab = index;
    final details = _openDetails;
    if (details == null) return;
    _tabByTrip[details.id] = index;
    safeEmit(
      TripDetailsSuccess(
        details: details,
        selectedTab: index,
        isFavorite: _favoriteIds.contains(details.id),
      ),
    );
  }

  /// Toggles favorite, returns the new state for the View's toast.
  bool toggleFavorite(String tripId) {
    final nowFavorite = !_favoriteIds.contains(tripId);
    if (nowFavorite) {
      _favoriteIds.add(tripId);
    } else {
      _favoriteIds.remove(tripId);
    }
    final details = _openDetails;
    if (details != null) {
      safeEmit(
        TripDetailsSuccess(
          details: details,
          selectedTab: _selectedTab,
          isFavorite: _favoriteIds.contains(details.id),
        ),
      );
    }
    return nowFavorite;
  }
}

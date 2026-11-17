import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../trips/models/trip.dart' as trips_model;
import '../data/place_resolver.dart';
import '../data/place_trip_mapper.dart';
import '../model/trip.dart';
import 'place_trips_state.dart';

/// Owns the approved trips of one place. The bundled mock trips rescue the
/// offline case; a successful empty answer stays empty.
class PlaceTripsCubit extends Cubit<PlaceTripsState>
    with SafeEmitMixin<PlaceTripsState> {
  PlaceTripsCubit({
    required this.resolver,
    PublicTripsRepository? repository,
    PlaceTripMapper? mapper,
  }) : _repository = repository ?? PublicTripsRepository(),
       _mapper = mapper ?? PlaceTripMapper(),
       super(const PlaceTripsInitial()) {
    load();
  }

  final PlaceResolver resolver;
  final PublicTripsRepository _repository;
  final PlaceTripMapper _mapper;

  Future<void> load() async {
    safeEmit(const PlaceTripsLoading());
    try {
      final place = await resolver.resolve();
      final remote = await _repository.fetchApprovedTrips();
      final trips = remote == null
          ? _mapper.mockCardsForPlace(place.id)
          : _mapper.cardsForPlace(remote, place);
      if (isClosed) return;
      safeEmit(PlaceTripsSuccess(trips: trips));
    } catch (error) {
      if (isClosed) return;
      safeEmit(PlaceTripsError(error: '$error'));
    }
  }

  void retry() => load();

  /// Opens a place trip in Trip Details / Public Booking.
  trips_model.Trip publicTripFor(Trip trip) => _mapper.publicTripFor(trip);
}

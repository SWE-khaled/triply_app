import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_raw.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../model/trip.dart';
import 'home_trips_state.dart';

/// Loads only the "Popular Trips" section of Home.
class HomeTripsCubit extends Cubit<HomeTripsState>
    with SafeEmitMixin<HomeTripsState> {
  HomeTripsCubit({PublicTripsRepository? tripsRepository})
    : _tripsRepository = tripsRepository ?? PublicTripsRepository(),
      super(const HomeTripsInitial());

  final PublicTripsRepository _tripsRepository;

  bool _isLoading = false;
  bool _hasLoaded = false;

  /// Reads approved trips, keeping the same `rethrowOnError` branch, mock
  /// fallback, mapping and session guard as the old aggregate Home load.
  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    if (state is HomeTripsInitial) {
      safeEmit(const HomeTripsLoading());
    }
    try {
      final remote = await _tripsRepository.fetchApprovedTrips(
        rethrowOnError: true,
      );
      final trips = (remote ?? _mockTrips())
          .map(Trip.fromPublicTrip)
          .toList(growable: false);
      _hasLoaded = true;
      safeEmit(HomeTripsSuccess(trips: trips));
    } catch (error) {
      safeEmit(HomeTripsError(message: pageLoadErrorMessage(error)));
    } finally {
      _isLoading = false;
    }
  }

  /// The bundled trips, used when Firestore cannot be reached.
  List<PublicTrip> _mockTrips() => mockTripsRaw
      .map(
        (e) => PublicTrip(
          id: e['id'] as String,
          guideId: '',
          title: e['title'] as String,
          location: (e['location'] as String?) ?? '',
          dateLabel: '',
          durationLabel: (e['duration'] as String?) ?? '',
          imageUrl: (e['image_url'] as String?) ?? '',
          guideName: '',
          tag: 'historical',
          priceEgp: ((e['price'] as num?) ?? 0).toDouble(),
          capacity: 12,
          bookedSeats: 0,
        ),
      )
      .toList();
}

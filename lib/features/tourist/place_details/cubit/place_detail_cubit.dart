import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart' as guides_src;
import 'package:triply/core/data/mock/tourist/mock_guides1.dart';
import 'package:triply/core/data/mock/tourist/mock_place_trips.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/data/mock/tourist/mock_stories.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../map/model/place.dart';
import '../../trips/models/trip.dart' as trips_model;
import '../model/guide.dart';
import '../model/story.dart';
import '../model/trip.dart';

part 'place_detail_state.dart';

/// The place screen: the place itself, its guides, its trips and stories.
///
/// The trips come from Firestore — the approved ones. A trip document
/// stores the location as free text, so the place is matched by its name
/// and its city; when nothing matches, every approved trip is offered —
/// an empty screen would be worse.
class PlaceDetailCubit extends Cubit<PlaceDetailState>
    with SafeEmitMixin<PlaceDetailState> {
  PlaceDetailCubit({required this.placeId, PublicTripsRepository? repository})
    : _repository = repository ?? PublicTripsRepository(),
      super(const PlaceDetailInitial()) {
    load();
  }

  final String placeId;
  final PublicTripsRepository _repository;

  Place? _place;
  List<Guide> _guides = const [];
  List<Trip> _trips = const [];
  List<Story> _stories = const [];
  int _selectedTabIndex = 0;

  Place get place => _place ?? _mockPlace();
  List<Guide> get guides => _guides;
  List<Trip> get trips => _trips;
  List<Story> get stories => _stories;
  int get selectedTabIndex => _selectedTabIndex;

  /// Reads the place and everything it shows.
  Future<void> load() async {
    safeEmit(const PlaceDetailLoading());
    try {
      _place = _mockPlace();
      _guides = mockGuides1.map((e) => Guide.fromJson(e)).toList();
      _stories = mockStories
          .where((e) => e['place_id'] == place.id)
          .map((e) => Story.fromJson(e))
          .toList();

      final remote = await _repository.fetchApprovedTrips();
      _trips = remote == null
          ? _mockTrips()
          : _tripsOfPlace(remote).map(_toCard).toList();

      safeEmit(
        PlaceDetailSuccess(
          place: place,
          guides: _guides,
          trips: _trips,
          stories: _stories,
          selectedTabIndex: _selectedTabIndex,
        ),
      );
    } catch (e) {
      safeEmit(PlaceDetailError(error: e.toString()));
    }
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    final current = state;
    if (current is! PlaceDetailSuccess) return;
    safeEmit(
      PlaceDetailSuccess(
        place: current.place,
        guides: current.guides,
        trips: current.trips,
        stories: current.stories,
        selectedTabIndex: index,
      ),
    );
  }

  void toggleFavorite() {
    final current = _place;
    if (current == null) return;
    current.isFavorite = !current.isFavorite;
    final state = this.state;
    if (state is! PlaceDetailSuccess) return;
    safeEmit(
      PlaceDetailSuccess(
        place: current,
        guides: state.guides,
        trips: state.trips,
        stories: state.stories,
        selectedTabIndex: state.selectedTabIndex,
      ),
    );
  }

  /// Resolves a place guide to the Guide Profile id by matching the existing
  /// guide name against the Local Guides list (same source as See All).
  String guideProfileIdFor(Guide guide) {
    for (final g in guides_src.mockGuides) {
      if (g.name == guide.name) return g.id;
    }
    return guides_src.mockGuides.first.id;
  }

  /// Resolves a place trip to the existing public-trip model so it can open
  /// Trip Details / Public Booking.
  ///
  /// The bundled trip is looked up by its id only — a Firestore trip must
  /// never fall back to another trip of the dataset.
  trips_model.Trip publicTripFor(Trip trip) {
    for (final e in mockTripsJson) {
      if (e['id'] == trip.id) {
        return trips_model.Trip.fromJson(e);
      }
    }
    return trips_model.Trip(
      id: trip.id,
      title: trip.title,
      dateLabel: trip.dateTime,
      guideName: trip.guideName,
      peopleCount: trip.peopleCount,
      priceEgp: trip.price,
      imageUrl: trip.imageUrl,
      status: trips_model.TripStatus.upcoming,
      category: 'historical',
      capacity: 12,
    );
  }

  /// The approved trips of this place.
  List<PublicTrip> _tripsOfPlace(List<PublicTrip> trips) {
    final current = place;
    final needles = [
      current.name.trim().toLowerCase(),
      current.city.trim().toLowerCase(),
    ].where((e) => e.isNotEmpty).toList();
    final matching = trips.where((trip) {
      final location = trip.location.toLowerCase();
      return needles.any(
        (needle) => location.contains(needle) || needle.contains(location),
      );
    }).toList();
    return matching.isEmpty ? trips : matching;
  }

  /// The card of a trip, in the shape the place screen shows.
  Trip _toCard(PublicTrip trip) {
    return Trip(
      id: trip.id,
      placeId: place.id,
      title: trip.title,
      dateTime: trip.dateLabel,
      guideName: trip.guideName,
      peopleCount: trip.bookedSeats,
      price: trip.priceEgp,
      currency: 'EGP',
      imageUrl: trip.imageUrl,
    );
  }

  /// The bundled place — the places are still the bundled dataset.
  Place _mockPlace() {
    final placeJson = mockPlaces.firstWhere(
      (e) => e['id'] == placeId,
      orElse: () => mockPlaces.first,
    );
    return Place.fromJson(placeJson);
  }

  /// The bundled trips, used when Firestore cannot be reached.
  List<Trip> _mockTrips() => mockPlaceTrips
      .where((e) => e['place_id'] == place.id)
      .map((e) => Trip.fromJson(e))
      .toList();
}

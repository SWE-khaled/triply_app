import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart' as guides_src;
import 'package:triply/core/data/mock/tourist/mock_guides1.dart';
import 'package:triply/core/data/mock/tourist/mock_place_trips.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/data/mock/tourist/mock_stories.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
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
/// The place doc comes from Firestore (`places/{placeId}`, the same
/// catalog the map reads, with the bundled mock as offline fallback).
/// The guides come from Firestore (the approved profiles of `guides`,
/// filtered by the guide's profile location) — same fallback chain.
/// The trips come from Firestore — the approved ones, and only those
/// whose location matches the place's Firestore `name`. The bundled
/// mock trips rescue the offline case with their own place_id match.
class PlaceDetailCubit extends Cubit<PlaceDetailState>
    with SafeEmitMixin<PlaceDetailState> {
  PlaceDetailCubit({
    required this.placeId,
    PublicTripsRepository? repository,
    PublicGuidesRepository? guidesRepository,
  }) : _repository = repository ?? PublicTripsRepository(),
       _guidesRepository = guidesRepository ?? PublicGuidesRepository(),
       super(const PlaceDetailInitial()) {
    load();
  }

  final String placeId;
  final PublicTripsRepository _repository;
  final PublicGuidesRepository _guidesRepository;

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
    safeEmit(const PlaceDetailLoadingState());
    try {
      _place = await _fetchPlace() ?? _mockPlace();

      // Firestore guides (approved only), filtered to this place's
      // location; the bundled mock rescues the screen offline.
      final remoteGuides = await _guidesRepository.fetchApprovedGuides();
      _guides = remoteGuides == null
          ? mockGuides1.map((e) => Guide.fromJson(e)).toList()
          : _guidesOfPlace(remoteGuides).map(_toGuide).toList();
      _stories = mockStories
          .where((e) => e['place_id'] == place.id)
          .map((e) => Story.fromJson(e))
          .toList();

      final remote = await _repository.fetchApprovedTrips();
      _trips = remote == null
          ? _mockTrips()
          : _tripsOfPlace(remote).map(_toCard).toList();

      safeEmit(
        PlaceDetailSuccessState(
          place: place,
          guides: _guides,
          trips: _trips,
          stories: _stories,
          selectedTabIndex: _selectedTabIndex,
        ),
      );
    } catch (e) {
      safeEmit(PlaceDetailErrorState(error: e.toString()));
    }
  }

  /// Manual re-entry after [PlaceDetailErrorState].
  void retry() => load();

  void selectTab(int index) {
    _selectedTabIndex = index;
    final current = state;
    if (current is! PlaceDetailSuccessState) return;
    safeEmit(
      PlaceDetailSuccessState(
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
    if (state is! PlaceDetailSuccessState) return;
    safeEmit(
      PlaceDetailSuccessState(
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

  /// The approved guides whose profile location matches this place's
  /// city (or name) as stored in Firestore — the two are free text, so
  /// the match follows the trips' tolerance (`_tripsOfPlace`): substring
  /// in either direction. Strict on purpose: a guide with an empty or
  /// unrelated location is never shown for this place, and when nothing
  /// matches the tabs are simply empty — the mall-fallback behavior
  /// ("show everything") was removed by request.
  List<PublicGuide> _guidesOfPlace(List<PublicGuide> guides) {
    final current = place;
    final needles = [
      current.city.trim().toLowerCase(),
      current.name.trim().toLowerCase(),
    ].where((e) => e.isNotEmpty).toList();
    return guides.where((guide) {
      final location = guide.location.trim().toLowerCase();
      if (location.isEmpty) return false;
      return needles.any(
        (needle) => location.contains(needle) || needle.contains(location),
      );
    }).toList();
  }

  /// The card of a guide, in the shape the place screen shows. The id is
  /// the guide's auth uid (the Firestore document id), not the mock id.
  Guide _toGuide(PublicGuide guide) {
    return Guide(
      id: guide.id,
      name: guide.name,
      specialty: guide.specialty,
      rating: guide.rating,
      reviewsCount: guide.reviewCount,
      pricePerHour: guide.pricePerHour,
      avatarUrl: guide.avatarUrl,
      // The query only returns approved guides.
      verified: guide.isApproved,
    );
  }

  /// The approved trips of this place: shown only when the trip's
  /// location (free text in the Firestore trip document) matches the
  /// place's Firestore `name` — a substring in either direction, the
  /// same tolerance the guides use. Strict on purpose, like the guides:
  /// a trip unrelated to the place is never shown beside it, trips
  /// without a location never match, and when nothing matches the tabs
  /// are simply empty (the earlier "show everything" fallback is gone
  /// by request).
  List<PublicTrip> _tripsOfPlace(List<PublicTrip> trips) {
    final name = place.name.trim().toLowerCase();
    if (name.isEmpty) return const <PublicTrip>[];
    return trips.where((trip) {
      final location = trip.location.trim().toLowerCase();
      if (location.isEmpty) return false;
      return location.contains(name) || name.contains(location);
    }).toList();
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

  /// The place document of Firestore `places/{placeId}` — the document
  /// ids match the uploaded catalog (doc id == the 'id' field), so the
  /// lookup is exact. Null when offline / denied / unknown id, and the
  /// bundled mock rescues the screen (same fallback chain as the map).
  Future<Place?> _fetchPlace() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .get();
      if (!doc.exists) return null;
      return Place.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// The bundled place — used when Firestore cannot be reached.
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

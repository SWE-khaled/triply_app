import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/places_repository.dart';
import 'package:triply/data/firestore/repositories/trips_repository.dart';
import '../../../../core/data/mock/tourist/mock_guides.dart' as guides_src;
import '../../../../core/data/mock/tourist/mock_guides1.dart';
import '../../../../core/data/mock/tourist/mock_places.dart';
import '../../../../core/data/mock/tourist/mock_stories.dart';
import '../../../../core/data/mock/tourist/mock_place_trips.dart';
import '../../../../core/data/mock/tourist/mock_trips_public.dart';
import '../model/guide.dart';
import '../../map/model/place.dart';
import '../model/story.dart';
import '../model/trip.dart';
import '../../trips/models/trip.dart' as trips_model;
import 'place_detail_state.dart';

class PlaceDetailCubit extends Cubit<PlaceDetailState> {
  final String placeId;
  final PlacesRepository _places;
  final TripsRepository _trips;

  /// Kill-switch: gates every remote call in the View. Stays `false` until
  /// the backend is deployed AND the emulator suite passes.
  static const bool useRemote = false;

  /// Trips-tab kill-switch (Phase 1): approved `trips/` for this place are
  /// primary; the mock tab list is the explicit offline baseline. Scoped to
  /// the Trips tab only — the header/guides/stories paths stay on mocks
  /// behind [useRemote].
  static const bool useRemoteTrips = true;

  PlaceDetailCubit({
    required this.placeId,
    PlacesRepository? places,
    TripsRepository? trips,
  }) : _places = places ?? PlacesRepository(),
       _trips = trips ?? TripsRepository(),
       super(_load(placeId));

  static PlaceDetailState _load(String placeId) {
    final placeJson = mockPlaces.firstWhere(
      (e) => e['id'] == placeId,
      orElse: () => mockPlaces.first,
    );
    final place = Place.fromJson(placeJson);
    return PlaceDetailState(
      place: place,
      guides: mockGuides1.map((e) => Guide.fromJson(e)).toList(),
      trips: mockPlaceTrips
          .where((e) => e['place_id'] == place.id)
          .map((e) => Trip.fromJson(e))
          .toList(),
      stories: mockStories
          .where((e) => e['place_id'] == place.id)
          .map((e) => Story.fromJson(e))
          .toList(),
    );
  }

  Place get place => state.place;
  List<Guide> get guides => state.guides;
  List<Trip> get trips => state.trips;
  List<Story> get stories => state.stories;
  int get selectedTabIndex => state.selectedTabIndex;

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
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
  /// Trip Details / Public Booking. Prefers the matching mock public trip
  /// (same id or title); otherwise maps fields with the model's defaults.
  trips_model.Trip publicTripFor(Trip trip) {
    for (final e in mockTripsJson) {
      if (e['id'] == trip.id || e['title'] == trip.title) {
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

  void toggleFavorite() {
    place.isFavorite = !place.isFavorite;
    emit(state.copyWith());
  }

  /// Best-effort remote trips-tab refresh via the existing
  /// `trips where placeId + approvalStatus == approved` query. Replaces the
  /// tab list on success (real ids flow to Trip Details); keeps the mock
  /// list on empty/failure and returns false — callers must surface this,
  /// never present the mock tab as live data.
  Future<bool> loadRemoteTrips() async {
    try {
      final result = await _trips.tripsByPlace(placeId);
      if (result is FirestoreOk<List<Trip>>) {
        emit(state.copyWith(trips: result.data));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: PlaceDetailCubit.loadRemoteTrips failed: $e');
      return false;
    }
    debugPrint('Triply: PlaceDetailCubit.loadRemoteTrips kept mock trips.');
    return false;
  }

  /// Best-effort remote header refresh. Only the header [place] is replaced;
  /// guides/trips/stories tabs stay on mocks. Returns true on success, false
  /// (mock kept) on missing doc, permission, or network failure — callers
  /// must surface this, never present the mock header as live data.
  Future<bool> loadRemotePlace() async {
    try {
      final result = await _places.byId(placeId);
      if (result is FirestoreOk<Place>) {
        final remote = result.data;
        remote.isFavorite = state.place.isFavorite;
        emit(state.copyWith(place: remote));
        return true;
      }
    } catch (e) {
      debugPrint('Triply: PlaceDetailCubit.loadRemotePlace failed: $e');
      return false;
    }
    debugPrint('Triply: PlaceDetailCubit.loadRemotePlace kept mock place.');
    return false;
  }
}

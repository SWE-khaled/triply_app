import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart' as guides_src;
import 'package:triply/core/data/mock/tourist/mock_palces_raw.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_raw.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/data/repositories/tourist_notifications_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../notifications/model/notification_item.dart';
import '../model/guide.dart';
import '../model/place.dart';
import '../model/trip.dart';

part 'home_state.dart';

/// The home screen: the places, the local guides and the trending trips.
///
/// The trips and the guides come from Firestore — the approved ones — and
/// the mock dataset is the fallback for when the read fails (offline).
class HomeCubit extends Cubit<HomeState> with SafeEmitMixin<HomeState> {
  HomeCubit({
    PublicTripsRepository? tripsRepository,
    PublicGuidesRepository? guidesRepository,
    TouristNotificationsRepository? notificationsRepository,
  }) : _tripsRepository = tripsRepository ?? PublicTripsRepository(),
       _guidesRepository = guidesRepository ?? PublicGuidesRepository(),
       _notificationsRepository =
           notificationsRepository ?? TouristNotificationsRepository(),
       super(const HomeInitial()) {
    _notificationsSubscription = _notificationsRepository
        .watchNotifications()
        .listen(
          _onNotifications,
          // A stream that is refused (the user signed out, the rules
          // changed) must not become an unhandled exception.
          onError: (Object error) =>
              safeEmit(HomeError(error: error.toString())),
        );
    load();
  }

  final PublicTripsRepository _tripsRepository;
  final PublicGuidesRepository _guidesRepository;
  final TouristNotificationsRepository _notificationsRepository;

  StreamSubscription<List<NotificationItem>>? _notificationsSubscription;

  List<Place> _places = const [];
  List<Guide> _guides = const [];
  List<Trip> _trips = const [];
  int _bottomNavIndex = 0;

  /// How many notifications the tourist did not read yet.
  int _unreadNotifications = 0;

  List<Place> get places => _places;
  List<Guide> get guides => _guides;
  List<Trip> get trips => _trips;
  int get bottomNavIndex => _bottomNavIndex;

  /// How many notifications the tourist did not read yet.
  int get unreadNotifications => _unreadNotifications;

  /// A new notification arrived — the badge on the bell follows.
  void _onNotifications(List<NotificationItem> items) {
    final count = items.where((e) => !e.isRead).length;
    if (count == _unreadNotifications) return;
    _unreadNotifications = count;
    _emitSuccess();
  }

  /// Reads the places, the guides and the trips.
  Future<void> load() async {
    safeEmit(const HomeLoading());
    try {
      _places = _mockPlaces();

      final remoteGuides = await _guidesRepository.fetchApprovedGuides();
      _guides = (remoteGuides ?? _mockPublicGuides())
          .map(Guide.fromPublicGuide)
          .take(2)
          .toList();

      final remote = await _tripsRepository.fetchApprovedTrips();
      _trips = (remote ?? _mockTrips()).map(Trip.fromPublicTrip).toList();

      safeEmit(
        HomeSuccess(
          places: _places,
          guides: _guides,
          trips: _trips,
          bottomNavIndex: _bottomNavIndex,
          unreadNotifications: _unreadNotifications,
        ),
      );
    } catch (e) {
      safeEmit(HomeError(error: e.toString()));
    }
  }

  /// Emits the current data again — the badge follows the notifications.
  void _emitSuccess() {
    final current = state;
    if (current is! HomeSuccess) return;
    safeEmit(
      HomeSuccess(
        places: current.places,
        guides: current.guides,
        trips: current.trips,
        bottomNavIndex: current.bottomNavIndex,
        unreadNotifications: _unreadNotifications,
      ),
    );
  }

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    _emitSuccess();
  }

  void toggleFavorite(String placeId) {
    _places = _places
        .map((p) => p.id == placeId ? p.copyWith(isFavorite: !p.isFavorite) : p)
        .toList();
    _emitSuccess();
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }

  /// The bundled places, used when Firestore cannot be reached.
  List<Place> _mockPlaces() {
    // Reuse the Map places list (single source of truth) for the 3 cards,
    // keeping the legacy card images (nicer look) as display-only override.
    // Ids still resolve in PlaceDetails.
    const homePlaceIds = ['giza_pyramids', 'khan_el_khalili', 'philae_temple'];
    final byId = {for (final e in mockPlaces) e['id'] as String: e};
    final legacyImages = [
      for (final e in mockPlacesRaw) e['image_url'] as String,
    ];
    var places = [
      for (var i = 0; i < homePlaceIds.length; i++)
        if (byId.containsKey(homePlaceIds[i]))
          _withDisplayImage(
            Place.fromJson(byId[homePlaceIds[i]]!),
            legacyImages[i % legacyImages.length],
          ),
    ];
    if (places.isEmpty) {
      places = mockPlaces.take(3).map(Place.fromJson).toList();
    }
    return places;
  }

  /// The bundled guides, used when Firestore cannot be reached.
  List<PublicGuide> _mockPublicGuides() => guides_src.mockGuides
      .map(
        (g) => PublicGuide(
          id: g.id,
          name: g.name,
          specialty: g.specialty,
          avatarUrl: g.avatarUrl,
          coverUrl: g.coverUrl,
          location: g.location,
          about: g.about,
          languages: g.languages,
          rating: g.rating,
          reviewCount: g.reviewCount,
          pricePerHour: g.pricePerHour,
          currency: g.currency,
          isApproved: g.isVerified,
        ),
      )
      .toList();

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

  /// Display-only image override: navigation still uses [place.id].
  Place _withDisplayImage(Place place, String imageUrl) {
    return Place(
      id: place.id,
      name: place.name,
      city: place.city,
      country: place.country,
      imageUrl: imageUrl,
      isFavorite: place.isFavorite,
    );
  }
}

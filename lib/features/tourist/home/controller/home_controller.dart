import 'package:flutter/foundation.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_guides.dart' as guides_src;
import 'package:admin_dashboard/core/data/mock/tourist/mock_palces_raw.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_places.dart';
import '../model/place.dart';
import '../model/guide.dart';
import '../model/trip.dart';
import '../../../../core/data/mock/tourist/mock_trips_raw.dart';







class HomeController extends ChangeNotifier {
  List<Place> places = [];
  List<Guide> guides = [];
  List<Trip> trips = [];
  int bottomNavIndex = 0;

  HomeController() {
    loadMock();
  }

  void loadMock() {
    // Reuse the Map places list (single source of truth) for the 3 cards,
    // keeping the legacy card images (nicer look) as display-only override.
    // Ids still resolve in PlaceDetails.
    const homePlaceIds = ['giza_pyramids', 'khan_el_khalili', 'philae_temple'];
    final byId = {for (final e in mockPlaces) e['id'] as String: e};
    final legacyImages = [
      for (final e in mockPlacesRaw) e['image_url'] as String,
    ];
    places = [
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
    // Same Local Guides source as See All, but Home shows only 2.
    guides = guides_src.mockGuides
        .take(2)
        .map((g) => Guide(
              id: g.id,
              name: g.name,
              specialty: g.specialty,
              avatarUrl: g.avatarUrl,
              rating: g.rating,
              reviewCount: g.reviewCount,
              pricePerHour: g.pricePerHour,
            ))
        .toList();
    trips = mockTripsRaw.map(Trip.fromJson).toList();
  }

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

  void toggleFavorite(String placeId) {
    places = places
        .map((p) => p.id == placeId
            ? p.copyWith(isFavorite: !p.isFavorite)
            : p)
        .toList();
    notifyListeners();
  }

  void setBottomNavIndex(int index) {
    bottomNavIndex = index;
    notifyListeners();
  }
}


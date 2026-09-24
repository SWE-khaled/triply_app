import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../models/guide.dart';
import '../models/trip.dart';
import '../data/mock/mock_places.dart';
import '../data/mock/mock_guides.dart';
import '../data/mock/mock_trips.dart';

class HomeController extends ChangeNotifier {
  List<Place> places = [];
  List<Guide> guides = [];
  List<Trip> trips = [];
  int bottomNavIndex = 0;

  HomeController() {
    loadMock();
  }

  void loadMock() {
    places = mockPlacesRaw.map(Place.fromJson).toList();
    guides = mockGuidesRaw.map(Guide.fromJson).toList();
    trips = mockTripsRaw.map(Trip.fromJson).toList();
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

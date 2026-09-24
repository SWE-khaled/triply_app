import '../../data/mock/mock_trips.dart';
import '../../models/trip.dart';

/// Simple feature-focused controller. No ChangeNotifier: the View holds
/// the selected tab with setState and queries this controller.
class TripsController {
  final List<Trip> _allTrips =
      mockTripsJson.map((e) => Trip.fromJson(e)).toList();

  List<Trip> getTripsByStatus(TripStatus status) {
    return _allTrips.where((t) => t.status == status).toList();
  }

  List<Trip> get allTrips => List.unmodifiable(_allTrips);
}

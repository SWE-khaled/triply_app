
import '../../features/tour_guide/my_trips_tg/model/guide_trip.dart';

/// Session-only created + edited trips (mock phase, no backend).
/// GuideTripsCubit merges these over the static mock list.
/// Later: replaced by API — cubits keep the same calls.
class GuideTripsStore {
  GuideTripsStore._();

  static final List<GuideTrip> _created = <GuideTrip>[];
  static final Map<String, GuideTrip> _updated = <String, GuideTrip>{};

  static void add(GuideTrip trip) {
    _created.insert(0, trip);
  }

  static void update(GuideTrip trip) {
    final index = _created.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _created[index] = trip;
    } else {
      _updated[trip.id] = trip;
    }
  }

  static List<GuideTrip> get created => List.unmodifiable(_created);

  /// Applies session edits over a base list (matched by id).
  static List<GuideTrip> applyUpdates(List<GuideTrip> base) {
    if (_updated.isEmpty) return base;
    return base.map((t) => _updated[t.id] ?? t).toList();
  }
}

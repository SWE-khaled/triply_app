
import 'package:flutter/foundation.dart';

import '../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import 'mock/tourguide/mock_guide_trips.dart';

/// Session-only created + edited trips (mock phase, no backend).
/// GuideTripsCubit merges these over the static mock list.
/// Later: replaced by API — cubits keep the same calls.
class GuideTripsStore {
  GuideTripsStore._();

  static final List<GuideTrip> _created = <GuideTrip>[];
  static final Map<String, GuideTrip> _updated = <String, GuideTrip>{};
  static final List<VoidCallback> _listeners = <VoidCallback>[];

  /// Screens that must rebuild when trips change (e.g. Dashboard stats)
  /// subscribe here; the store itself stays a plain static holder.
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notify() {
    for (final listener in List<VoidCallback>.of(_listeners)) {
      listener();
    }
  }

  /// Every trip the guide owns: session-created first, then static mock
  /// with session edits applied. Same merge GuideTripsCubit uses.
  static List<GuideTrip> allTrips() => applyUpdates([
    ..._created,
    ...mockGuideTripsJson.map((e) => GuideTrip.fromJson(e)),
  ]);

  static void add(GuideTrip trip) {
    _created.insert(0, trip);
    _notify();
  }

  static void update(GuideTrip trip) {
    final index = _created.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _created[index] = trip;
    } else {
      _updated[trip.id] = trip;
    }
    _notify();
  }

  static List<GuideTrip> get created => List.unmodifiable(_created);

  /// Applies session edits over a base list (matched by id).
  static List<GuideTrip> applyUpdates(List<GuideTrip> base) {
    if (_updated.isEmpty) return base;
    return base.map((t) => _updated[t.id] ?? t).toList();
  }
}

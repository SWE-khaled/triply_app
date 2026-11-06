part of 'trips_cubit.dart';

/// The state of the Trips tab.
@immutable
sealed class TripsState {
  const TripsState();
}

/// Nothing has been requested yet.
final class TripsInitial extends TripsState {
  const TripsInitial();
}

/// The trip list is being loaded for the first time.
final class TripsLoading extends TripsState {
  const TripsLoading();
}

/// The trip stream failed.
final class TripsError extends TripsState {
  final String message;

  const TripsError(this.message);
}

/// The live trip list, with the current search applied.
final class TripsSuccess extends TripsState {
  final List<TripRowData> trips;
  final String query;
  final bool busy;

  const TripsSuccess({required this.trips, this.query = '', this.busy = false});

  List<TripRowData> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return trips;
    return trips.where((trip) {
      return trip.title.toLowerCase().contains(q) ||
          trip.guide.toLowerCase().contains(q) ||
          trip.date.toLowerCase().contains(q) ||
          trip.status.toLowerCase().contains(q);
    }).toList();
  }

  TripsSuccess copyWith({List<TripRowData>? trips, String? query, bool? busy}) {
    return TripsSuccess(
      trips: trips ?? this.trips,
      query: query ?? this.query,
      busy: busy ?? this.busy,
    );
  }
}

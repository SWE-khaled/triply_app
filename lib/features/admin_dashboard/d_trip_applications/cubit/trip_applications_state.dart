part of 'trip_applications_cubit.dart';

/// The state of the Trip Applications tab.
@immutable
sealed class TripApplicationsState {
  const TripApplicationsState();
}

/// Nothing has been requested yet.
final class TripApplicationsInitial extends TripApplicationsState {
  const TripApplicationsInitial();
}

/// The applications are being loaded for the first time.
final class TripApplicationsLoading extends TripApplicationsState {
  const TripApplicationsLoading();
}

/// The trips stream failed.
final class TripApplicationsError extends TripApplicationsState {
  final String message;

  const TripApplicationsError(this.message);
}

/// The live applications, with the current search applied.
final class TripApplicationsSuccess extends TripApplicationsState {
  final List<AdminTripApplication> applications;
  final String query;
  final bool busy;

  const TripApplicationsSuccess({
    required this.applications,
    this.query = '',
    this.busy = false,
  });

  List<AdminTripApplication> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return applications;
    return applications.where((application) {
      return application.tripTitle.toLowerCase().contains(q) ||
          application.guide.toLowerCase().contains(q) ||
          application.location.toLowerCase().contains(q) ||
          application.status.toLowerCase().contains(q) ||
          application.type.toLowerCase().contains(q);
    }).toList();
  }

  TripApplicationsSuccess copyWith({
    List<AdminTripApplication>? applications,
    String? query,
    bool? busy,
  }) {
    return TripApplicationsSuccess(
      applications: applications ?? this.applications,
      query: query ?? this.query,
      busy: busy ?? this.busy,
    );
  }
}

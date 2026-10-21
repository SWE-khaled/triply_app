part of 'guide_trip_details_cubit.dart';

@immutable
sealed class GuideTripDetailsState {
  const GuideTripDetailsState();
}

final class GuideTripDetailsInitial extends GuideTripDetailsState {
  const GuideTripDetailsInitial();
}

final class GuideTripDetailsLoading extends GuideTripDetailsState {
  const GuideTripDetailsLoading();
}

final class GuideTripDetailsSuccess extends GuideTripDetailsState {
  final GuideTripDetails details;

  /// The tab the details are showing.
  final int selectedTab;

  const GuideTripDetailsSuccess({
    required this.details,
    required this.selectedTab,
  });
}

final class GuideTripDetailsError extends GuideTripDetailsState {
  final String error;

  const GuideTripDetailsError({required this.error});
}

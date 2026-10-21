part of 'dashboard_cubit.dart';

@immutable
sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardSuccess extends DashboardState {
  final GuideDashboardStats stats;
  final List<BookingRequest> bookings;
  final bool showVerificationBanner;

  const DashboardSuccess({
    required this.stats,
    required this.bookings,
    required this.showVerificationBanner,
  });
}

final class DashboardError extends DashboardState {
  final String error;

  const DashboardError({required this.error});
}

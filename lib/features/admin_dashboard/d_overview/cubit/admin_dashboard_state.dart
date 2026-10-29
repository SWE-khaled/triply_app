part of 'admin_dashboard_cubit.dart';

@immutable
sealed class AdminDashboardState {}

final class AdminDashboardInitial extends AdminDashboardState {}

final class AdminDashboardLoadingState extends AdminDashboardState {}

final class AdminDashboardSuccessState extends AdminDashboardState {
  final List<MockGuide> guides;
  final int totalUsersCount;
  final int tourGuidesCount;
  final int totalTripsCount;
  final int totalBookingsCount;
  final String earningsLabel;
  final int pendingTripsCount;

  AdminDashboardSuccessState({
    required this.guides,
    this.totalUsersCount = 12480,
    this.tourGuidesCount = 326,
    this.totalTripsCount = 1204,
    this.totalBookingsCount = 8930,
    this.earningsLabel = 'EGP 2,838',
    this.pendingTripsCount = 3,
  });

  int get pendingGuidesCount =>
      guides.where((g) => g.status == 'pending').length;

  int get totalPending => pendingGuidesCount + pendingTripsCount;
}

final class AdminDashboardEmptyState extends AdminDashboardState {}

final class AdminDashboardErrorState extends AdminDashboardState {
  final String message;
  AdminDashboardErrorState(this.message);
}

final class AdminActionSuccessState extends AdminDashboardState {
  final String message;
  AdminActionSuccessState(this.message);
}

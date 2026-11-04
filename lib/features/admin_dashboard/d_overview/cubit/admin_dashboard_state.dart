part of 'admin_dashboard_cubit.dart';

/// The state of the admin Overview tab.
@immutable
sealed class AdminDashboardState {
  const AdminDashboardState();
}

/// Nothing has been requested yet.
final class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// The Firestore listeners are being attached.
final class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// One of the listeners failed before any data arrived.
final class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);
}

/// The live dashboard data, kept in sync with Firestore.
final class AdminDashboardSuccess extends AdminDashboardState {
  final List<AdminGuide> guides;
  final int totalUsersCount;
  final int tourGuidesCount;
  final int totalTripsCount;
  final int totalBookingsCount;
  final double totalEarnings;
  final int pendingTripsCount;

  const AdminDashboardSuccess({
    this.guides = const [],
    this.totalUsersCount = 0,
    this.tourGuidesCount = 0,
    this.totalTripsCount = 0,
    this.totalBookingsCount = 0,
    this.totalEarnings = 0,
    this.pendingTripsCount = 0,
  });

  int get pendingGuidesCount =>
      guides.where((guide) => guide.status == 'pending').length;

  int get totalPending => pendingGuidesCount + pendingTripsCount;

  String get earningsLabel {
    if (totalEarnings <= 0) return 'EGP 0';
    final raw = totalEarnings.toStringAsFixed(0);
    return 'EGP ${_groupThousands(raw)}';
  }

  AdminDashboardSuccess copyWith({
    List<AdminGuide>? guides,
    int? totalUsersCount,
    int? tourGuidesCount,
    int? totalTripsCount,
    int? totalBookingsCount,
    double? totalEarnings,
    int? pendingTripsCount,
  }) {
    return AdminDashboardSuccess(
      guides: guides ?? this.guides,
      totalUsersCount: totalUsersCount ?? this.totalUsersCount,
      tourGuidesCount: tourGuidesCount ?? this.tourGuidesCount,
      totalTripsCount: totalTripsCount ?? this.totalTripsCount,
      totalBookingsCount: totalBookingsCount ?? this.totalBookingsCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingTripsCount: pendingTripsCount ?? this.pendingTripsCount,
    );
  }
}

/// Groups the thousands of [value] with commas: `1204` -> `1,204`.
String _groupThousands(String value) {
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    if (i > 0 && (value.length - i) % 3 == 0) buffer.write(',');
    buffer.write(value[i]);
  }
  return buffer.toString();
}

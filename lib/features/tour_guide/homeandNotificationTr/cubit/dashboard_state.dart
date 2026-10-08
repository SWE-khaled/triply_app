import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';

class DashboardState {
  final GuideDashboardStats stats;
  final List<BookingRequest> bookings;
  final bool showVerificationBanner;

  const DashboardState({
    required this.stats,
    required this.bookings,
    required this.showVerificationBanner,
  });

  DashboardState copyWith({
    GuideDashboardStats? stats,
    List<BookingRequest>? bookings,
    bool? showVerificationBanner,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      bookings: bookings ?? this.bookings,
      showVerificationBanner:
          showVerificationBanner ?? this.showVerificationBanner,
    );
  }
}

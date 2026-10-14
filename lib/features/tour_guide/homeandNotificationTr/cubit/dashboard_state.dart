import '../model/guide_dashboard_booking_request.dart';
import '../model/guide_dashboard_stats.dart';

class DashboardState {
  final GuideDashboardStats stats;
  final List<BookingRequest> bookings;
  final bool showVerificationBanner;
  final bool isLoading;
  final String? countsError;

  const DashboardState({
    required this.stats,
    required this.bookings,
    required this.showVerificationBanner,
    this.isLoading = false,
    this.countsError,
  });

  DashboardState copyWith({
    GuideDashboardStats? stats,
    List<BookingRequest>? bookings,
    bool? showVerificationBanner,
    bool? isLoading,
    String? countsError,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      bookings: bookings ?? this.bookings,
      showVerificationBanner:
          showVerificationBanner ?? this.showVerificationBanner,
      isLoading: isLoading ?? this.isLoading,
      // Null clears a previous error; pass state.countsError to preserve.
      countsError: countsError,
    );
  }
}

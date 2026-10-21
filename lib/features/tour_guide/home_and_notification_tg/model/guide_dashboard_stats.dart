class GuideDashboardStats {
  final String guideName;
  final String avatarUrl;
  final int totalBookings;
  final int upcomingTrips;
  final int activeTrips;
  final int completedTrips;
  final String earningsLabel;
  final int pendingRequests;

  const GuideDashboardStats({
    required this.guideName,
    required this.avatarUrl,
    required this.totalBookings,
    required this.upcomingTrips,
    required this.activeTrips,
    required this.completedTrips,
    required this.earningsLabel,
    required this.pendingRequests,
  });

  factory GuideDashboardStats.fromJson(Map<String, dynamic> json) {
    return GuideDashboardStats(
      guideName: json['guide_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      totalBookings: (json['total_bookings'] as num? ?? 0).toInt(),
      upcomingTrips: (json['upcoming_trips'] as num? ?? 0).toInt(),
      activeTrips: (json['active_trips'] as num? ?? 0).toInt(),
      completedTrips: (json['completed_trips'] as num? ?? 0).toInt(),
      earningsLabel: json['earnings_label'] as String? ?? '',
      pendingRequests: (json['pending_requests'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guide_name': guideName,
      'avatar_url': avatarUrl,
      'total_bookings': totalBookings,
      'upcoming_trips': upcomingTrips,
      'completed_trips': completedTrips,
      'active_trips': activeTrips,
      'earnings_label': earningsLabel,
      'pending_requests': pendingRequests,
    };
  }
}

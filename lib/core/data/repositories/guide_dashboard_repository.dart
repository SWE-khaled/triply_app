import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/tour_guide/earnings_tg/model/earnings.dart';
import '../../../features/tour_guide/home_and_notification_tg/model/booking_details.dart';
import '../../../features/tour_guide/home_and_notification_tg/model/guide_dashboard_booking_request.dart';
import '../../../features/tour_guide/home_and_notification_tg/model/guide_dashboard_stats.dart';
import '../../../features/tour_guide/my_trips_tg/model/guide_trip.dart';
import '../../../features/tour_guide/travelers_tg/model/traveler.dart';
import '../../helper/price_format.dart';
import '../../helper/schedule_format.dart';
import '../mock/tourguide/mock_booking_details.dart';
import '../mock/tourguide/mock_earnings.dart';
import '../mock/tourguide/mock_guide_dashboard.dart';
import '../mock/tourguide/mock_travelers.dart';
import '../remote/firestore_service.dart';

/// The guide's booking numbers, read from Firestore.
class GuideDashboardMetrics {
  /// How many bookings the guide ever received.
  final int totalBookings;

  /// Sum of every booking total — the earnings shown on the dashboard.
  final double totalEarnings;

  /// The "New bookings" rows.
  final List<BookingRequest> bookings;

  const GuideDashboardMetrics({
    required this.totalBookings,
    required this.totalEarnings,
    required this.bookings,
  });
}

/// Reads the dashboard numbers of the signed-in tour guide.
///
/// Firestore is the source of truth; the mock dataset is the fallback.
class GuideDashboardRepository {
  GuideDashboardRepository({FirestoreService? firestore, this.auth})
    : _firestore = firestore ?? FirestoreService();

  /// Firestore collection holding the bookings.
  static const String bookingsCollection = 'bookings';

  final FirestoreService _firestore;

  /// The auth client to read the signed-in guide from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in guide's uid, or null when signed out.
  /// The signed-in guide's uid, or null when signed out.
  ///
  /// Returns null (instead of throwing) when there is no Firebase app,
  /// so the repositories stay usable in plain unit tests.
  String? get currentGuideId {
    try {
      return _firebaseAuth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Booking counters + the "New bookings" rows.
  ///
  /// Falls back to the mock dataset when the guide is signed out or the
  /// read fails.
  Future<GuideDashboardMetrics> fetchMetrics() async {
    final uid = currentGuideId;
    if (uid == null) return _mockMetrics();
    try {
      final snapshot = await _firestore
          .collection(bookingsCollection)
          .where('guideId', isEqualTo: uid)
          .get();
      final rows = snapshot.docs
          .map((doc) => _toBookingRequest(doc.data(), doc.id))
          .toList();
      final earnings = snapshot.docs.fold<double>(
        0,
        (sum, doc) =>
            sum + ((doc.data()['totalPrice'] as num?)?.toDouble() ?? 0),
      );
      return GuideDashboardMetrics(
        totalBookings: snapshot.docs.length,
        totalEarnings: earnings,
        bookings: rows,
      );
    } catch (_) {
      return _mockMetrics();
    }
  }

  /// The dashboard counters, combining the trips with the bookings.
  Future<GuideDashboardStats> fetchStats(List<GuideTrip> trips) async {
    final metrics = await fetchMetrics();
    final base = GuideDashboardStats.fromJson(mockGuideDashboardRaw);

    int count(GuideTripStatus status) =>
        trips.where((trip) => trip.status == status).length;

    return GuideDashboardStats(
      guideName: base.guideName,
      avatarUrl: base.avatarUrl,
      totalBookings: metrics.totalBookings,
      upcomingTrips:
          count(GuideTripStatus.active) + count(GuideTripStatus.pending),
      activeTrips: count(GuideTripStatus.active),
      completedTrips: count(GuideTripStatus.completed),
      earningsLabel: _formatAmount(metrics.totalEarnings),
      pendingRequests: count(GuideTripStatus.pending),
    );
  }

  /// One booking with all of its details.
  ///
  /// Falls back to the mock dataset when the guide is signed out, the
  /// booking does not exist or the read fails.
  Future<BookingDetails?> fetchBookingDetails(String bookingId) async {
    final uid = currentGuideId;
    if (uid == null) return _mockBookingDetails(bookingId);
    try {
      final data = await _firestore.readDoc(bookingsCollection, bookingId);
      if (data == null) return _mockBookingDetails(bookingId);
      final merged = <String, dynamic>{
        'id': bookingId,
        'guest_name': '',
        'country': '',
        'traveler_count': 1,
        'avatar_url': '',
        'is_private': true,
        'tour_title': '',
        'datetime_label': '',
        'location': '',
        'booking_code': '',
        'price_label': '',
        ...data,
      };
      merged['id'] = bookingId;
      return BookingDetails.fromJson(merged);
    } catch (_) {
      return _mockBookingDetails(bookingId);
    }
  }

  /// The travelers booked on one trip.
  ///
  /// Every booking of the trip contributes its lead traveler.
  Future<List<Traveler>> fetchTravelers(String tripId) async {
    final uid = currentGuideId;
    if (uid == null) return _mockTravelers(tripId);
    try {
      final snapshot = await _firestore
          .collection(bookingsCollection)
          .where('guideId', isEqualTo: uid)
          .where('tripId', isEqualTo: tripId)
          .get();
      return snapshot.docs
          .map((doc) => _toTraveler(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return _mockTravelers(tripId);
    }
  }

  /// The guide's earnings, derived from the bookings.
  Future<EarningsSummary> fetchEarnings() async {
    final uid = currentGuideId;
    if (uid == null) return _mockEarnings();
    try {
      final snapshot = await _firestore
          .collection(bookingsCollection)
          .where('guideId', isEqualTo: uid)
          .get();
      final activities = snapshot.docs.map((doc) {
        final data = doc.data();
        return EarningActivity(
          id: 'ea-${doc.id}',
          title: (data['tour_title'] as String?) ?? '',
          amountEgp: ((data['totalPrice'] as num?) ?? 0).toDouble(),
        );
      }).toList();
      final total = activities.fold<double>(
        0,
        (sum, activity) => sum + activity.amountEgp,
      );
      return EarningsSummary(
        availableBalance: total,
        month: formatMonthName(DateTime.now()),
        activities: activities,
      );
    } catch (_) {
      return _mockEarnings();
    }
  }

  /// Reads a booking document into a dashboard row.
  BookingRequest _toBookingRequest(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'guest_name': '',
      'tour_title': '',
      'detail_label': '',
      'avatar_url': '',
      'is_private': false,
      ...?data,
    };
    merged['id'] = id;
    return BookingRequest.fromJson(merged);
  }

  /// Reads a booking document into a traveler row.
  Traveler _toTraveler(Map<String, dynamic>? data, String id) {
    final merged = <String, dynamic>{
      'id': id,
      'tripId': '',
      'name': '',
      'tagline': '',
      'avatarUrl': '',
      'seatsLabel': '',
      ...?data,
    };
    merged['id'] = (data?['touristId'] as String?) ?? id;
    merged['tripId'] = data?['tripId'] as String? ?? '';
    merged['name'] = data?['guest_name'] as String? ?? '';
    merged['avatarUrl'] = data?['avatar_url'] as String? ?? '';
    final country = data?['country'] as String? ?? '';
    merged['tagline'] = country.isEmpty ? 'Traveler' : 'Traveler · $country';
    final count = ((data?['traveler_count'] as num?) ?? 1).toInt();
    merged['seatsLabel'] = '$count ${count == 1 ? 'traveler' : 'travelers'}';
    return Traveler.fromJson(merged);
  }

  GuideDashboardMetrics _mockMetrics() {
    final rows = mockBookingRequestsRaw
        .map(BookingRequest.fromJson)
        .toList(growable: false);
    final earnings = mockBookingDetailsRaw.fold<double>(
      0,
      (sum, booking) =>
          sum + ((booking['totalPrice'] as num?)?.toDouble() ?? 0),
    );
    return GuideDashboardMetrics(
      totalBookings: rows.length,
      totalEarnings: earnings,
      bookings: rows,
    );
  }

  BookingDetails? _mockBookingDetails(String bookingId) {
    for (final booking in mockBookingDetailsRaw) {
      if (booking['id'] == bookingId) return BookingDetails.fromJson(booking);
    }
    return null;
  }

  List<Traveler> _mockTravelers(String tripId) => mockTravelersJson
      .map(Traveler.fromJson)
      .where((traveler) => traveler.tripId == tripId)
      .toList(growable: false);

  EarningsSummary _mockEarnings() => EarningsSummary.fromJson(mockEarningsJson);

  /// Formats an amount for the earnings stat card (no currency prefix —
  /// the card is width-constrained).
  String _formatAmount(double amount) => formatEgp(amount);
}

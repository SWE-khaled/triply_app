import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:triply/data/firestore/datasources/app_settings_datasource.dart';
import 'package:triply/data/firestore/datasources/bookings_datasource.dart';
import 'package:triply/data/firestore/datasources/guide_profiles_datasource.dart';
import 'package:triply/data/firestore/datasources/guide_verifications_datasource.dart';
import 'package:triply/data/firestore/datasources/posts_datasource.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/datasources/users_datasource.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/guide_verification_doc.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';

/// Dashboard overview numbers. Every figure is a live server aggregate;
/// nothing is hardcoded or sampled. Earnings = sum of `serviceFee` over
/// non-cancelled bookings (manual `owed` refunds are tracked separately
/// and never subtracted here — no money movement is recorded on-chain).
class AdminOverview {
  final int usersTotal;
  final int guidesTotal;
  final int tripsTotal;
  final int bookingsTotal;
  final int pendingGuides;
  final int pendingTrips;
  final double earnings;

  const AdminOverview({
    required this.usersTotal,
    required this.guidesTotal,
    required this.tripsTotal,
    required this.bookingsTotal,
    required this.pendingGuides,
    required this.pendingTrips,
    required this.earnings,
  });

  int get totalPending => pendingGuides + pendingTrips;
}

/// One row of the Manage Users table. `bookings` is intentionally absent:
/// per-user booking counts would cost a query per row; the column shows a
/// placeholder instead of an invented number.
class AdminUserRow {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;

  const AdminUserRow({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  String get status => isActive ? 'active' : 'suspended';
  String get typeLabel {
    if (role == 'guide') return 'Guide';
    if (role == 'admin') return 'Admin';
    return 'Tourist';
  }
}

/// One row of the bookings table: the authoritative record plus
/// best-effort display names (never invented — raw ids when unresolvable).
class AdminBookingRow {
  final BookingDoc booking;
  final String touristName;
  final String tripTitle;
  final String guideName;

  const AdminBookingRow({
    required this.booking,
    required this.touristName,
    required this.tripTitle,
    required this.guideName,
  });
}

/// One row of the guide-verification queue: the canonical verification
/// record plus best-effort contact fields (never invented). `userActive`
/// mirrors `users/{uid}.isActive` and drives Suspend/Activate (account
/// access), which is orthogonal to the verification verdict.
class AdminGuideRow {
  final GuideVerificationDoc verification;
  final String displayName;
  final String email;
  final String contactPhone;
  final bool userActive;
  final String city;

  const AdminGuideRow({
    required this.verification,
    required this.displayName,
    required this.email,
    required this.contactPhone,
    required this.userActive,
    this.city = '',
  });

  String get guideId => verification.guideId;
  String get status => verification.status;
}

/// Central admin data + actions. All reads honor the admin-only rules
/// (non-admin callers get permission-denied, never another user's data); all
/// mutations go through admin-checked paths (callables or admin-only
/// rules). Constructing the repository never touches Firebase.
class AdminRepository {
  UsersDatasource? _usersDS;
  TripsDatasource? _tripsDS;
  BookingsDatasource? _bookingsDS;
  GuideVerificationsDatasource? _verificationsDS;
  GuideProfilesDatasource? _profilesDS;
  PostsDatasource? _postsDS;
  AppSettingsDatasource? _settingsDS;
  FirebaseFunctions? _functionsSvc;

  AdminRepository({
    UsersDatasource? users,
    TripsDatasource? trips,
    BookingsDatasource? bookings,
    GuideVerificationsDatasource? verifications,
    GuideProfilesDatasource? profiles,
    PostsDatasource? posts,
    AppSettingsDatasource? settings,
    FirebaseFunctions? functions,
  }) : _usersDS = users,
       _tripsDS = trips,
       _bookingsDS = bookings,
       _verificationsDS = verifications,
       _profilesDS = profiles,
       _postsDS = posts,
       _settingsDS = settings,
       _functionsSvc = functions;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  UsersDatasource get _users => _usersDS ??= UsersDatasource();
  TripsDatasource get _trips => _tripsDS ??= TripsDatasource();
  BookingsDatasource get _bookings => _bookingsDS ??= BookingsDatasource();
  GuideVerificationsDatasource get _verifications =>
      _verificationsDS ??= GuideVerificationsDatasource();
  GuideProfilesDatasource get _profiles =>
      _profilesDS ??= GuideProfilesDatasource();
  PostsDatasource get _posts => _postsDS ??= PostsDatasource();
  AppSettingsDatasource get _settings =>
      _settingsDS ??= AppSettingsDatasource();
  FirebaseFunctions get _functions =>
      _functionsSvc ??= FirebaseFunctions.instance;

  /// Live dashboard counters. Throws with a user-facing message when the
  /// caller is not an admin (rules) or the backend is unreachable.
  Future<AdminOverview> overviewCounts() async {
    try {
      final usersTotal = await _users.countAll();
      final guidesTotal = await _users.countByRole('guide');
      final tripsTotal = await _trips.countAll();
      final bookingsTotal = await _bookings.countAll();
      final pendingGuides = await _verifications.countPending();
      final pendingTrips = await _trips.countPending();
      final earnings = await _bookings.earningsTotal();
      return AdminOverview(
        usersTotal: usersTotal,
        guidesTotal: guidesTotal,
        tripsTotal: tripsTotal,
        bookingsTotal: bookingsTotal,
        pendingGuides: pendingGuides,
        pendingTrips: pendingTrips,
        earnings: earnings,
      );
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// All tourists + guides (capped pages, merged). Admin-only by rules.
  Future<List<AdminUserRow>> listUsers({int limit = 50}) async {
    try {
      final tourists = await _users.listByRole('tourist', limit: limit);
      final guides = await _users.listByRole('guide', limit: limit);
      return [
        for (final u in [...tourists, ...guides])
          AdminUserRow(
            uid: u.uid,
            name: u.fullName.isNotEmpty ? u.fullName : 'Unnamed user',
            email: u.email,
            phone: u.phone,
            role: u.role,
            isActive: u.isActive,
          ),
      ];
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Suspend/activate a user. Admin-only by rules; the server owns the
  /// field (client `updateFields` strips it for non-admins).
  Future<void> setUserActive(String uid, bool active) async {
    try {
      await _users.setActive(uid, active);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Pending guide verifications with best-effort contact display.
  Future<List<AdminGuideRow>> pendingVerifications({int limit = 50}) async {
    try {
      final pending = await _verifications.listPending(limit: limit);
      return _resolveGuideRows(pending);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// All recent verifications (any status) for review history.
  Future<List<AdminGuideRow>> recentVerifications({int limit = 50}) async {
    try {
      final docs = await _verifications.listRecent(limit: limit);
      return _resolveGuideRows(docs);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<List<AdminGuideRow>> _resolveGuideRows(
    List<GuideVerificationDoc> docs,
  ) async {
    final rows = <AdminGuideRow>[];
    for (final v in docs) {
      var name = '';
      var email = '';
      var phone = '';
      var active = true;
      var city = '';
      try {
        final user = await _users.getById(v.guideId);
        if (user != null) {
          name = user.fullName;
          email = user.email;
          phone = user.phone;
          active = user.isActive;
        }
      } catch (_) {}
      try {
        final profile = await _profiles.getByUserId(v.guideId);
        if (profile != null) {
          if (name.isEmpty) name = profile.displayName;
          if (phone.isEmpty) phone = profile.contactPhone;
          city = profile.location;
        }
      } catch (_) {}
      rows.add(
        AdminGuideRow(
          verification: v,
          displayName: name.isNotEmpty ? name : v.guideId,
          email: email,
          contactPhone: phone,
          userActive: active,
          city: city,
        ),
      );
    }
    return rows;
  }

  /// Approve/reject a guide via the `decideVerification` callable.
  /// Returns the decided status. Server mirrors guideProfiles + legacy
  /// users map and notifies the guide; permission is admin-checked.
  Future<String> decideVerification({
    required String guideId,
    required bool approved,
    String rejectionReason = '',
  }) async {
    try {
      final callable = _functions.httpsCallable('decideVerification');
      final res = await callable.call({
        'guideId': guideId,
        'decision': approved ? 'approved' : 'rejected',
        'rejectionReason': rejectionReason,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return (data['status'] ?? '').toString();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(_functionMessage(e));
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Trips awaiting moderation (oldest first).
  Future<List<TripDoc>> pendingTrips({int limit = 50}) async {
    try {
      return await _trips.listPending(limit: limit);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Newest trips of any status (admin-only by rules).
  Future<List<TripDoc>> allTrips({int limit = 50}) async {
    try {
      return await _trips.listRecent(limit: limit);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Trips owned by one guide (newest first) for review dialogs.
  Future<List<TripDoc>> guideTrips(String guideId, {int limit = 20}) async {
    try {
      final page = await _trips.listByGuide(guideId, limit: limit);
      return page.items;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Approve/reject/cancel a trip via direct Firestore decision write
  /// (Spark-compatible: the rules authorize admins and pin all other
  /// fields — no callable). Returns the decided status.
  /// Capacity/booking protections stay server-side; cancelling a trip does
  /// NOT refund bookings (those keep their own lifecycle) — callers must
  /// not claim refunds from this.
  Future<String> decideTripStatus({
    required String tripId,
    required String decision,
    String rejectionReason = '',
  }) async {
    try {
      await _trips.setDecision(
        id: tripId,
        approvalStatus: decision,
        rejectionReason: decision == 'rejected' ? rejectionReason : '',
      );
      return decision;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Newest bookings of any user (admin-only by rules, read-only here).
  /// Paid state is informational only: nothing here marks paid or refunds.
  Future<List<BookingDoc>> recentBookings({int limit = 50}) async {
    try {
      return await _bookings.listRecent(limit: limit);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Bookings with resolved display names (distinct ids only, so the extra
  /// reads stay bounded). Unresolvable names fall back to short ids —
  /// never invented.
  Future<List<AdminBookingRow>> recentBookingRows({int limit = 50}) async {
    final bookings = await recentBookings(limit: limit);
    final tripTitles = <String, String>{};
    final userNames = <String, String>{};
    Future<String> tripTitle(String? tripId) async {
      if (tripId == null || tripId.isEmpty) return '—';
      if (!tripTitles.containsKey(tripId)) {
        try {
          final doc = await _trips.getById(tripId);
          tripTitles[tripId] = (doc != null && doc.title.isNotEmpty)
              ? doc.title
              : tripId;
        } catch (_) {
          tripTitles[tripId] = tripId;
        }
      }
      return tripTitles[tripId]!;
    }

    Future<String> userName(String uid) async {
      if (uid.isEmpty) return '—';
      if (!userNames.containsKey(uid)) {
        try {
          final doc = await _users.getById(uid);
          final name = doc?.fullName ?? '';
          userNames[uid] = name.isNotEmpty ? name : uid;
        } catch (_) {
          userNames[uid] = uid;
        }
      }
      return userNames[uid]!;
    }

    final rows = <AdminBookingRow>[];
    for (final b in bookings) {
      rows.add(
        AdminBookingRow(
          booking: b,
          touristName: await userName(b.touristId),
          tripTitle: b.isPublic ? await tripTitle(b.tripId) : 'Private tour',
          guideName: await userName(b.guideId),
        ),
      );
    }
    return rows;
  }

  /// Newest community posts (public read). Admin deletes via rules.
  Future<List<PostDoc>> recentPosts({int limit = 50}) async {
    try {
      final page = await _posts.feed(limit: limit);
      return page.items;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Admin post delete (rules: owner or admin). No comment system exists
  /// to moderate — posts only.
  Future<void> deletePost(String postId) async {
    try {
      await _posts.delete(postId);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Current public-trip commission rate (fraction, e.g. 0.12).
  /// Absent doc falls back to the operational default (0.05).
  Future<double> serviceFeeRate() async {
    try {
      final settings = await _settings.getOperational();
      return settings.serviceFeeRate;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Persists the commission rate. Admin-only by rules; rejects
  /// out-of-range values client-side before any write.
  Future<void> saveServiceFeeRate(double rate, {String updatedBy = ''}) async {
    if (!(rate >= 0 && rate < 1)) {
      throw Exception('Commission must be between 0% and 99%.');
    }
    try {
      await _settings.setValue('serviceFeeRate', rate, updatedBy: updatedBy);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  String _functionMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please sign in as an admin.';
      case 'permission-denied':
        return 'Admin access required.';
      case 'invalid-argument':
        return e.message ?? 'Invalid admin request.';
      case 'not-found':
        return e.message ?? 'Record not found.';
      case 'failed-precondition':
        return e.message ?? 'Operation not allowed in its current state.';
      case 'unavailable':
        return 'Admin service unavailable. Please try again.';
      default:
        return e.message ?? 'Admin operation failed. Please try again.';
    }
  }

  String _friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Admin access required.';
        case 'unavailable':
          return 'Network unavailable. Please try again.';
        case 'not-found':
          return 'The requested item was not found.';
        default:
          return 'Firestore error (${e.code}). Please try again.';
      }
    }
    return e.toString();
  }
}

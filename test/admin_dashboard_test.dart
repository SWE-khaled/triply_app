import 'package:flutter_test/flutter_test.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/guide_verification_doc.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/data/firestore/repositories/admin_repository.dart';

/// Focused Phase 7 unit tests: admin row models + repository behavior with
/// scripted fakes (possible because the repository constructs lazily —
/// building it never touches Firebase). Auth flows (login/deny/restore)
/// and live callable paths are covered by emulator tests + the real-SDK
/// probe instead. These are UNIT tests, not integration tests.
class _FakeAdminRepository extends AdminRepository {
  AdminOverview overview = const AdminOverview(
    usersTotal: 10,
    guidesTotal: 3,
    tripsTotal: 5,
    bookingsTotal: 7,
    pendingGuides: 2,
    pendingTrips: 1,
    earnings: 100.5,
  );
  List<AdminUserRow> users = const [];
  List<AdminGuideRow> guides = const [];
  List<TripDoc> trips = const [];
  List<BookingDoc> bookings = const [];
  List<PostDoc> posts = const [];
  double feeRate = 0.05;

  int decideVerificationCalls = 0;
  int decideTripCalls = 0;
  int setActiveCalls = 0;
  int deletePostCalls = 0;
  int saveFeeCalls = 0;
  String decideVerificationResult = 'approved';
  String decideTripResult = 'approved';
  Object? decideError;

  @override
  Future<AdminOverview> overviewCounts() async => overview;

  @override
  Future<List<AdminUserRow>> listUsers({int limit = 50}) async => users;

  @override
  Future<void> setUserActive(String uid, bool active) async {
    setActiveCalls++;
  }

  @override
  Future<List<AdminGuideRow>> pendingVerifications({int limit = 50}) async =>
      guides;

  @override
  Future<List<AdminGuideRow>> recentVerifications({int limit = 50}) async =>
      guides;

  @override
  Future<String> decideVerification({
    required String guideId,
    required bool approved,
    String rejectionReason = '',
  }) async {
    decideVerificationCalls++;
    if (decideError != null) throw decideError!;
    return decideVerificationResult;
  }

  @override
  Future<List<TripDoc>> pendingTrips({int limit = 50}) async => trips;

  @override
  Future<List<TripDoc>> allTrips({int limit = 50}) async => trips;

  @override
  Future<String> decideTripStatus({
    required String tripId,
    required String decision,
    String rejectionReason = '',
  }) async {
    decideTripCalls++;
    if (decideError != null) throw decideError!;
    return decideTripResult;
  }

  @override
  Future<List<BookingDoc>> recentBookings({int limit = 50}) async => bookings;

  @override
  Future<List<PostDoc>> recentPosts({int limit = 50}) async => posts;

  @override
  Future<void> deletePost(String postId) async {
    deletePostCalls++;
    if (decideError != null) throw decideError!;
  }

  @override
  Future<double> serviceFeeRate() async => feeRate;

  @override
  Future<void> saveServiceFeeRate(double rate, {String updatedBy = ''}) async {
    saveFeeCalls++;
    if (decideError != null) throw decideError!;
  }
}

AdminGuideRow _row({String status = 'pending', bool active = true}) =>
    AdminGuideRow(
      verification: GuideVerificationDoc(
        id: 'g1',
        guideId: 'g1',
        idDocumentUrl: 'http://id',
        licenseDocumentUrl: 'http://lic',
        status: status,
      ),
      displayName: 'Gina',
      email: 'g@t.dev',
      contactPhone: '+2010',
      userActive: active,
      city: 'Cairo',
    );

void main() {
  group('admin row models', () {
    test('overview totalPending sums both queues', () {
      const o = AdminOverview(
        usersTotal: 1,
        guidesTotal: 1,
        tripsTotal: 1,
        bookingsTotal: 1,
        pendingGuides: 2,
        pendingTrips: 3,
        earnings: 0,
      );
      expect(o.totalPending, 5);
    });

    test('user row labels + status', () {
      const tourist = AdminUserRow(
        uid: 'u',
        name: 'N',
        email: 'e',
        phone: 'p',
        role: 'tourist',
        isActive: true,
      );
      expect(tourist.typeLabel, 'Tourist');
      expect(tourist.status, 'active');
      const guide = AdminUserRow(
        uid: 'g',
        name: 'G',
        email: 'e',
        phone: 'p',
        role: 'guide',
        isActive: false,
      );
      expect(guide.typeLabel, 'Guide');
      expect(guide.status, 'suspended');
      const admin = AdminUserRow(
        uid: 'a',
        name: 'A',
        email: 'e',
        phone: 'p',
        role: 'admin',
        isActive: true,
      );
      expect(admin.typeLabel, 'Admin');
    });

    test('guide row exposes verification identity', () {
      final row = _row();
      expect(row.guideId, 'g1');
      expect(row.status, 'pending');
      expect(row.userActive, isTrue);
    });
  });

  group('AdminRepository behavior (fake-backed)', () {
    test('overview + lists pass through', () async {
      final repo = _FakeAdminRepository()
        ..users = const [
          AdminUserRow(
            uid: 'u1',
            name: 'N',
            email: 'e',
            phone: 'p',
            role: 'tourist',
            isActive: true,
          ),
        ]
        ..guides = [_row()];
      final overview = await repo.overviewCounts();
      expect(overview.usersTotal, 10);
      expect(overview.totalPending, 3);
      expect(overview.earnings, 100.5);
      expect((await repo.listUsers()).length, 1);
      expect((await repo.pendingVerifications()).single.displayName, 'Gina');
      expect((await repo.recentVerifications()).single.city, 'Cairo');
    });

    test('decide calls forward + surface server errors', () async {
      final repo = _FakeAdminRepository();
      expect(
        await repo.decideVerification(guideId: 'g1', approved: true),
        'approved',
      );
      expect(repo.decideVerificationCalls, 1);
      expect(
        await repo.decideTripStatus(tripId: 't1', decision: 'cancelled'),
        'approved',
      );
      expect(repo.decideTripCalls, 1);
      repo.decideError = Exception('Admin access required.');
      await expectLater(
        repo.decideVerification(guideId: 'g1', approved: true),
        throwsA(predicate((e) => e.toString().contains('Admin access'))),
      );
      await expectLater(
        repo.deletePost('p1'),
        throwsA(predicate((e) => e.toString().contains('Admin access'))),
      );
      expect(repo.deletePostCalls, 1);
    });

    test('user suspend + fee save invoke backend paths', () async {
      final repo = _FakeAdminRepository();
      await repo.setUserActive('u1', false);
      expect(repo.setActiveCalls, 1);
      await repo.saveServiceFeeRate(0.12, updatedBy: 'admin1');
      expect(repo.saveFeeCalls, 1);
      expect(await repo.serviceFeeRate(), 0.05);
    });
  });
}

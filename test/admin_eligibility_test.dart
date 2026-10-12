import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/admin_dashboard/d_auth/cubit/admin_auth_cubit.dart';

/// Focused unit tests for the Admin UI eligibility rule.
///
/// The `triplykl` substring is an ELIGIBILITY hint shown in the UI only —
/// it is never authorization. Real privilege comes from the server
/// (`admins/{uid}` doc OR `admin:true` custom claim, enforced by
/// firestore.rules + Functions via AdminAccessService/provisionAdmin).
/// These tests are pure (no Firebase channels) and emulator-safe.
void main() {
  group('Admin UI eligibility (triplykl substring)', () {
    test('eligible examples pass (case-insensitive)', () {
      expect(
        AdminAuthCubit.isEligibleAdminEmail('khaledtriplykl@gmail.com'),
        isTrue,
      );
      expect(
        AdminAuthCubit.isEligibleAdminEmail('Admin-TriplyKL@demo.local'),
        isTrue,
      );
      expect(
        AdminAuthCubit.isEligibleAdminEmail('  admin-triplykl@demo.local  '),
        isTrue,
      );
    });

    test('missing substring or invalid email is rejected', () {
      expect(AdminAuthCubit.isEligibleAdminEmail('khaled@gmail.com'), isFalse);
      expect(AdminAuthCubit.isEligibleAdminEmail('admin@demo.local'), isFalse);
      expect(AdminAuthCubit.isEligibleAdminEmail('triplykl'), isFalse);
      expect(AdminAuthCubit.isEligibleAdminEmail(''), isFalse);
    });

    test('eligibility alone grants nothing (documents server rule)', () {
      // Even an eligible email must still pass server authorization:
      // AdminAccessService.isAuthorized (admins doc / claim) + requireAdmin
      // in provisionAdmin. A tourist/guide email containing triplykl without
      // those server records stays unauthorized and is signed back out.
      // (No Firebase here by design — this documents the contract enforced
      //  by emulator tests + rules/callable tests.)
      expect(
        AdminAuthCubit.isEligibleAdminEmail('tourist-triplykl@demo.local'),
        isTrue,
      );
      expect(AdminAuthCubit.accessDeniedMessage, isNotEmpty);
    });
  });
}

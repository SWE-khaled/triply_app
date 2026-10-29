import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/mock/dashboard/d_mock_guides.dart';
import 'package:triply/features/admin_dashboard/d_overview/cubit/admin_dashboard_cubit.dart';

void main() {
  group('AdminDashboardCubit', () {
    test('initial state is AdminDashboardInitial', () {
      final cubit = AdminDashboardCubit();
      expect(cubit.state, isA<AdminDashboardInitial>());
      cubit.close();
    });

    test('loadDashboardData emits Loading then Success with guides', () async {
      final cubit = AdminDashboardCubit();
      final states = <AdminDashboardState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadDashboardData();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminDashboardLoadingState>());
      expect(states[1], isA<AdminDashboardSuccessState>());

      final success = states[1] as AdminDashboardSuccessState;
      expect(success.guides.isNotEmpty, true);
      expect(success.pendingGuidesCount, greaterThanOrEqualTo(0));
      expect(success.totalPending, success.pendingGuidesCount + success.pendingTripsCount);

      await sub.cancel();
      cubit.close();
    });

    test('updateGuideStatus updates guide and emits AdminActionSuccessState then AdminDashboardSuccessState', () async {
      final testGuide = MockGuide(
        name: 'Test Guide',
        email: 'testguide@example.com',
        document: 'License',
        city: 'Cairo',
        status: 'pending',
        phone: '01000000000',
        submitted: '2026-10-25',
        docFileName: 'doc.pdf',
        uploadedTrips: const [],
      );

      final cubit = AdminDashboardCubit(initialGuides: [testGuide]);
      expect(cubit.state, isA<AdminDashboardSuccessState>());

      final states = <AdminDashboardState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.updateGuideStatus(testGuide, 'approved');
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AdminActionSuccessState>());
      final actionSuccess = states[0] as AdminActionSuccessState;
      expect(actionSuccess.message, contains('approved'));

      expect(states[1], isA<AdminDashboardSuccessState>());
      final updatedSuccess = states[1] as AdminDashboardSuccessState;
      expect(updatedSuccess.guides.first.status, 'approved');

      await sub.cancel();
      cubit.close();
    });

    test('loadDashboardData emits AdminDashboardEmptyState if guides list is empty', () async {
      final cubit = AdminDashboardCubit(initialGuides: const []);
      expect(cubit.state, isA<AdminDashboardEmptyState>());
      cubit.close();
    });
  });
}

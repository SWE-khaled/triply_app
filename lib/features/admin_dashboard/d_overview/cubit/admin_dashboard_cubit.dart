import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/dashboard/d_mock_guides.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  List<MockGuide> _guides = [];

  AdminDashboardCubit({List<MockGuide>? initialGuides})
      : super(AdminDashboardInitial()) {
    if (initialGuides != null) {
      _guides = List.from(initialGuides);
      if (_guides.isEmpty) {
        emit(AdminDashboardEmptyState());
      } else {
        emit(AdminDashboardSuccessState(guides: List.unmodifiable(_guides)));
      }
    }
  }

  /// Loads the dashboard data.
  Future<void> loadDashboardData() async {
    emit(AdminDashboardLoadingState());
    try {
      await Future<void>.delayed(Duration.zero);
      _guides = List.from(mockGuides);
      if (_guides.isEmpty) {
        emit(AdminDashboardEmptyState());
      } else {
        emit(AdminDashboardSuccessState(guides: List.unmodifiable(_guides)));
      }
    } catch (e) {
      emit(AdminDashboardErrorState(e.toString()));
    }
  }

  /// Updates a guide's verification status (e.g., 'approved', 'suspended', 'pending').
  Future<void> updateGuideStatus(MockGuide guide, String status) async {
    try {
      final index = _guides.indexOf(guide);
      if (index != -1) {
        _guides[index] = MockGuide(
          name: guide.name,
          email: guide.email,
          document: guide.document,
          city: guide.city,
          status: status,
          phone: guide.phone,
          submitted: guide.submitted,
          docFileName: guide.docFileName,
          uploadedTrips: guide.uploadedTrips,
        );
        emit(AdminActionSuccessState('Guide status updated to $status'));
        await Future<void>.delayed(Duration.zero);
        emit(AdminDashboardSuccessState(guides: List.unmodifiable(_guides)));
      }
    } catch (e) {
      emit(AdminDashboardErrorState(e.toString()));
    }
  }

  /// Refreshes the dashboard data.
  Future<void> refresh() => loadDashboardData();
}

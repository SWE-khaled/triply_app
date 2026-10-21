import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/repositories/guide_dashboard_repository.dart';
import '../model/earnings.dart';

part 'earnings_state.dart';

/// Guide earnings display data.
///
/// The amounts are derived from the guide's bookings in Firestore, with
/// the mock dataset as fallback.
class EarningsCubit extends Cubit<EarningsState>
    with SafeEmitMixin<EarningsState> {
  EarningsCubit({GuideDashboardRepository? repository})
    : _repository = repository ?? GuideDashboardRepository(),
      super(const EarningsInitial()) {
    load();
  }

  final GuideDashboardRepository _repository;

  /// Loads the earnings summary.
  Future<void> load() async {
    safeEmit(const EarningsLoading());
    try {
      final summary = await _repository.fetchEarnings();
      safeEmit(EarningsSuccess(summary: summary));
    } catch (e) {
      safeEmit(EarningsError(error: e.toString()));
    }
  }
}

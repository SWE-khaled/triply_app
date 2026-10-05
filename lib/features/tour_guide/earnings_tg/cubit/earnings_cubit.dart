import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/mock/tourguide/mock_earnings.dart';
import '../model/earnings.dart';
import 'earnings_state.dart';

/// Guide earnings display data (mock -> Model). Static in this phase.
class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit()
    : super(EarningsState(summary: EarningsSummary.fromJson(mockEarningsJson)));
}

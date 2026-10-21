part of 'earnings_cubit.dart';

@immutable
sealed class EarningsState {
  const EarningsState();
}

final class EarningsInitial extends EarningsState {
  const EarningsInitial();
}

final class EarningsLoading extends EarningsState {
  const EarningsLoading();
}

final class EarningsSuccess extends EarningsState {
  final EarningsSummary summary;

  const EarningsSuccess({required this.summary});
}

final class EarningsError extends EarningsState {
  final String error;

  const EarningsError({required this.error});
}

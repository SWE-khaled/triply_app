import '../model/earnings.dart';

class EarningsState {
  final EarningsSummary? summary;
  final bool isLoading;
  final String? error;

  const EarningsState({
    required this.summary,
    this.isLoading = false,
    this.error,
  });

  EarningsState copyWith({
    EarningsSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return EarningsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      // Null clears a previous error; pass the current error to preserve.
      error: error,
    );
  }
}

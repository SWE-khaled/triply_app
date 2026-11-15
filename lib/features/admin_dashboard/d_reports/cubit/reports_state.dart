part of 'reports_cubit.dart';

@immutable
sealed class ReportsState {
  const ReportsState();
}

final class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

final class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);
}

final class ReportsSuccess extends ReportsState {
  final List<Report> reports;
  final String query;
  final String statusFilter;
  final Set<String> busyReportIds;

  const ReportsSuccess({
    required this.reports,
    required this.query,
    required this.statusFilter,
    required this.busyReportIds,
  });

  List<Report> get filtered {
    final q = query.trim().toLowerCase();
    return reports.where((report) {
      final matchesStatus =
          statusFilter == 'all' || report.status == statusFilter;
      if (!matchesStatus) return false;
      if (q.isEmpty) return true;
      return [
        report.reporterId,
        report.reportedUserId,
        report.chatId,
        report.messageId,
        report.text,
        report.reasonCode,
        report.note,
        report.status,
      ].any((value) => value.toLowerCase().contains(q));
    }).toList();
  }
}

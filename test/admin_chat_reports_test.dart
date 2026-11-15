import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/report.dart';
import 'package:triply/features/admin_dashboard/d_reports/cubit/reports_cubit.dart';

void main() {
  test('report list filters by status and searches report details', () {
    final reports = ReportsSuccess(
      reports: [
        const Report(
          id: 'report-a',
          reporterId: 'tourist-uid',
          reportedUserId: 'guide-uid',
          reasonCode: 'harassment',
          text: 'Repeated unwanted messages',
          status: 'open',
        ),
        const Report(
          id: 'report-b',
          reporterId: 'guide-uid',
          reportedUserId: 'tourist-uid',
          reasonCode: 'spam',
          text: 'Promotional links',
          status: 'resolved',
        ),
      ],
      query: 'guide-uid',
      statusFilter: 'open',
      busyReportIds: const {},
    );

    expect(reports.filtered.map((report) => report.id), ['report-a']);

    final resolved = ReportsSuccess(
      reports: reports.reports,
      query: '',
      statusFilter: 'resolved',
      busyReportIds: const {},
    );
    expect(resolved.filtered.map((report) => report.id), ['report-b']);
  });
}

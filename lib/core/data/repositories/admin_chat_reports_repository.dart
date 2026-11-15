import '../models/report.dart';
import '../remote/firestore_service.dart';

/// Reads and reviews chat reports in the admin dashboard.
class AdminChatReportsRepository {
  AdminChatReportsRepository({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  static const String reportsCollection = 'reports';
  static const List<String> reviewStatuses = ['resolved', 'dismissed'];

  final FirestoreService _firestore;

  Stream<List<Report>> watchReports() {
    return _firestore.collection(reportsCollection).snapshots().map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => Report.fromDocument(doc.data(), doc.id))
          .toList();
      reports.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return reports;
    });
  }

  Future<void> updateStatus({
    required String reportId,
    required String status,
    required String reviewerId,
    required String reviewNote,
  }) async {
    if (!reviewStatuses.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported report status');
    }
    if (reviewerId.isEmpty) {
      throw StateError('An authenticated admin is required to review reports.');
    }
    await _firestore.collection(reportsCollection).doc(reportId).update({
      'status': status,
      'reviewerId': reviewerId,
      'reviewNote': reviewNote.trim(),
    });
  }
}

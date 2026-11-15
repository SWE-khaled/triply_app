import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/models/report.dart';
import 'package:triply/core/data/repositories/admin_chat_reports_repository.dart';

part 'reports_state.dart';

/// Owns the live chat-report list and admin review actions.
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({AdminChatReportsRepository? repository, FirebaseAuth? auth})
    : _repository = repository ?? AdminChatReportsRepository(),
      _auth = auth ?? FirebaseAuth.instance,
      super(const ReportsInitial());

  final AdminChatReportsRepository _repository;
  final FirebaseAuth _auth;
  StreamSubscription<List<Report>>? _subscription;
  List<Report> _reports = const [];
  String _query = '';
  String _statusFilter = 'all';
  final Set<String> _busyReportIds = {};

  void start() {
    emit(const ReportsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchReports().listen(
      (reports) {
        _reports = reports;
        _emitSuccess();
      },
      onError: (Object _) {
        if (!isClosed) emit(const ReportsError('Could not load chat reports.'));
      },
    );
  }

  void retry() => start();

  void search(String query) {
    _query = query;
    _emitSuccess();
  }

  void filterByStatus(String status) {
    _statusFilter = status;
    _emitSuccess();
  }

  Future<String?> review(
    Report report, {
    required String status,
    required String reviewNote,
  }) async {
    if (_busyReportIds.contains(report.id)) {
      return 'This report is already being updated.';
    }
    _busyReportIds.add(report.id);
    _emitSuccess();
    try {
      final reviewerId = _auth.currentUser?.uid ?? '';
      await _repository.updateStatus(
        reportId: report.id,
        status: status,
        reviewerId: reviewerId,
        reviewNote: reviewNote,
      );
      return null;
    } catch (error) {
      return error.toString();
    } finally {
      _busyReportIds.remove(report.id);
      _emitSuccess();
    }
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(
      ReportsSuccess(
        reports: List.unmodifiable(_reports),
        query: _query,
        statusFilter: _statusFilter,
        busyReportIds: Set.unmodifiable(_busyReportIds),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

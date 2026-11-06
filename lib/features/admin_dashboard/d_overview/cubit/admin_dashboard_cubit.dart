import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_guides_repository.dart';

part 'admin_dashboard_state.dart';

/// Owns the live KPIs and the guide applications of the Overview tab.
///
/// Every number is a Firestore stream, so the dashboard updates itself
/// without a manual refresh. The cubit keeps the latest value of each
/// stream and re-emits a single [AdminDashboardSuccess] state.
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit({
    FirebaseFirestore? firestore,
    AdminGuidesRepository? guidesRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _guidesRepository = guidesRepository ?? AdminGuidesRepository(),
       super(const AdminDashboardInitial());

  final FirebaseFirestore _firestore;
  final AdminGuidesRepository _guidesRepository;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  int _totalUsersCount = 0;
  int _tourGuidesCount = 0;
  int _totalTripsCount = 0;
  int _totalBookingsCount = 0;
  double _totalEarnings = 0;
  int _pendingTripsCount = 0;
  List<AdminGuide> _guides = const [];
  bool _started = false;

  /// Attaches the Firestore listeners. Calling it twice is a no-op.
  void start() {
    if (_started) return;
    _started = true;
    emit(const AdminDashboardLoading());
    _listenUsers();
    _listenTrips();
    _listenBookings();
    _listenGuides();
  }

  /// Cancels the current listeners and starts over.
  void retry() {
    _cancelSubscriptions();
    _started = false;
    start();
  }

  void _listenUsers() {
    _subscriptions.add(
      _firestore.collection('users').snapshots().listen((snapshot) {
        _totalUsersCount = snapshot.docs.length;
        _emitSuccess();
      }, onError: _onError),
    );

    _subscriptions.add(
      _firestore
          .collection('users')
          .where('role', isEqualTo: 'guide')
          .snapshots()
          .listen((snapshot) {
            _tourGuidesCount = snapshot.docs.length;
            _emitSuccess();
          }, onError: _onError),
    );
  }

  void _listenTrips() {
    _subscriptions.add(
      _firestore.collection('trips').snapshots().listen((snapshot) {
        var pending = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final status =
              (data['approvalStatus'] as String?) ??
              (data['status'] as String?) ??
              'pending';
          if (status == 'pending' || status == 'pending_review') pending++;
        }
        _totalTripsCount = snapshot.docs.length;
        _pendingTripsCount = pending;
        _emitSuccess();
      }, onError: _onError),
    );
  }

  void _listenBookings() {
    _subscriptions.add(
      _firestore.collection('bookings').snapshots().listen((snapshot) {
        var earnings = 0.0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final price =
              (data['totalPrice'] as num?) ??
              (data['price'] as num?) ??
              (data['amount'] as num?) ??
              0;
          earnings += price * 0.1; // 10% platform commission.
        }
        _totalBookingsCount = snapshot.docs.length;
        _totalEarnings = earnings;
        _emitSuccess();
      }, onError: _onError),
    );
  }

  void _listenGuides() {
    _subscriptions.add(
      _guidesRepository.watchGuides().listen((guides) {
        _guides = guides;
        _emitSuccess();
      }, onError: _onError),
    );
  }

  /// Approves / suspends a guide from the mini table on the Overview tab.
  ///
  /// The table updates immediately and rolls back when Firestore refuses
  /// the write (the caller then shows the failure to the admin).
  Future<bool> updateGuideStatus(AdminGuide guide, String status) async {
    if (guide.uid.isEmpty) return false;

    final previous = _guides;
    _guides = [
      for (final current in _guides)
        if (current.uid == guide.uid)
          current.copyWith(status: status)
        else
          current,
    ];
    _emitSuccess();

    final ok = await _guidesRepository.decideVerification(
      guideId: guide.uid,
      approve: status == 'approved',
    );

    if (!ok && !isClosed) {
      _guides = previous;
      _emitSuccess();
    }
    return ok;
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(
      AdminDashboardSuccess(
        guides: List.unmodifiable(_guides),
        totalUsersCount: _totalUsersCount,
        tourGuidesCount: _tourGuidesCount,
        totalTripsCount: _totalTripsCount,
        totalBookingsCount: _totalBookingsCount,
        totalEarnings: _totalEarnings,
        pendingTripsCount: _pendingTripsCount,
      ),
    );
  }

  void _onError(Object error) {
    if (isClosed) return;
    // Keep whatever data already arrived; only show the failure screen when
    // there is nothing to render yet.
    if (state is AdminDashboardSuccess) return;
    emit(const AdminDashboardError('Could not load the dashboard data.'));
  }

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}

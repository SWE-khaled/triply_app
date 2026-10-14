import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import '../../../../core/data/mock/tourguide/mock_earnings.dart';
import '../model/earnings.dart';
import 'earnings_state.dart';

/// Guide earnings: Firestore `bookings` for the signed-in guide first
/// (non-cancelled totals + per-booking activity rows), mock fallback.
class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit({
    BookingsRepository? repository,
    TripsDatasource? trips,
  })  : _repository = repository ?? BookingsRepository(),
        _trips = trips ?? TripsDatasource(),
        super(
            EarningsState(summary: EarningsSummary.fromJson(mockEarningsJson))) {
    loadRemote();
  }

  final BookingsRepository _repository;
  final TripsDatasource _trips;

  /// Best-effort remote load. Returns true when Firestore bookings
  /// replaced the summary; false keeps the mock baseline — callers must
  /// surface this, never present mocks as live data.
  Future<bool> loadRemote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return false;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _repository.guideBookings(uid, limit: 500);
      if (result is! FirestoreOk<List<BookingDoc>>) {
        emit(state.copyWith(isLoading: false));
        return false;
      }
      final payable =
          result.data.where((b) => b.status != 'cancelled').toList();
      if (payable.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return false;
      }
      // Tour titles for activity rows (best-effort; ids kept on failure).
      final titles = <String, String>{};
      for (final b in payable) {
        final tripId = b.tripId;
        if (tripId == null || tripId.isEmpty || titles.containsKey(tripId)) {
          continue;
        }
        try {
          titles[tripId] = await _trips.getById(tripId).then(
                (t) => t?.title ?? tripId,
              );
        } catch (_) {
          titles[tripId] = tripId;
        }
      }
      final now = DateTime.now();
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      emit(state.copyWith(
        summary: EarningsSummary(
          availableBalance:
              FirestoreMappers.guideEarningsTotal(payable),
          month: '${months[now.month - 1]} ${now.year}',
          activities: payable
              .map((b) => EarningActivity(
                    id: b.id,
                    title: (b.tripId != null && titles.containsKey(b.tripId)
                            ? titles[b.tripId]!
                            : b.id) +
                        (b.isPrivate ? ' · Private' : ''),
                    amountEgp: b.totalAmount,
                  ))
              .toList(),
        ),
        isLoading: false,
      ));
      return true;
    } catch (e) {
      debugPrint('Triply: EarningsCubit.loadRemote failed: $e');
      emit(state.copyWith(
        isLoading: false,
        error: FirestoreQueryHelper.friendlyError(e),
      ));
      return false;
    }
  }
}

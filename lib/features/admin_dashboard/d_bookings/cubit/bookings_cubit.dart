import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_bookings_repository.dart';

part 'bookings_state.dart';

/// Owns the Bookings tab: the live booking list, the search query and the
/// confirm / cancel actions.
class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit({AdminBookingsRepository? repository})
    : _repository = repository ?? AdminBookingsRepository(),
      super(const BookingsInitial());

  final AdminBookingsRepository _repository;

  StreamSubscription<List<AdminBooking>>? _subscription;
  List<AdminBooking> _bookings = const [];
  String _query = '';

  /// Subscribes to the booking stream. Calling it twice is a no-op.
  void start() {
    emit(const BookingsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchBookings().listen(
      (bookings) {
        _bookings = bookings;
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) emit(const BookingsError('Could not load bookings.'));
      },
    );
  }

  /// Applies the search box content to the loaded list.
  void search(String query) {
    _query = query;
    final current = state;
    if (current is BookingsSuccess) {
      emit(current.copyWith(query: query));
    }
  }

  /// Marks a booking as confirmed or cancelled.
  ///
  /// The row flips immediately and rolls back when Firestore refuses the
  /// write; the view then reports the failure to the admin.
  Future<bool> updateStatus(AdminBooking booking, String status) async {
    final current = state;
    if (current is! BookingsSuccess) return false;

    final optimistic = current.copyWith(
      bookings: [
        for (final item in current.bookings)
          if (item.id == booking.id) item.copyWith(status: status) else item,
      ],
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.updateStatus(booking.id, status);
    if (isClosed) return ok;

    if (ok) {
      emit(optimistic.copyWith(busy: false));
    } else {
      emit(current.copyWith(busy: false));
    }
    return ok;
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(
      BookingsSuccess(bookings: List.unmodifiable(_bookings), query: _query),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

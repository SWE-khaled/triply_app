import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_tourists_repository.dart';

part 'users_state.dart';

/// Owns the Users tab: the live tourist list, the search query and the
/// suspend / activate action.
class UsersCubit extends Cubit<UsersState> {
  UsersCubit({AdminTouristsRepository? repository})
    : _repository = repository ?? AdminTouristsRepository(),
      super(const UsersInitial());

  final AdminTouristsRepository _repository;

  StreamSubscription<List<AdminTourist>>? _subscription;
  List<AdminTourist> _tourists = const [];
  String _query = '';

  /// Subscribes to the tourist stream. Calling it twice is a no-op.
  void start() {
    emit(const UsersLoading());
    _subscription?.cancel();
    _subscription = _repository.watchTourists().listen(
      (tourists) {
        _tourists = tourists;
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) emit(const UsersError('Could not load tourists.'));
      },
    );
  }

  /// Applies the search box content to the loaded list.
  void search(String query) {
    _query = query;
    final current = state;
    if (current is UsersSuccess) {
      emit(current.copyWith(query: query));
    }
  }

  /// Suspends or re-activates a tourist.
  ///
  /// The row flips immediately and rolls back when Firestore refuses the
  /// write; the view then reports the failure to the admin.
  Future<bool> toggleStatus(AdminTourist tourist) async {
    final current = state;
    if (current is! UsersSuccess) return false;

    final newStatus = tourist.status == 'active' ? 'suspended' : 'active';
    final optimistic = current.copyWith(
      tourists: [
        for (final user in current.tourists)
          if (user.uid == tourist.uid)
            user.copyWith(status: newStatus)
          else
            user,
      ],
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.updateStatus(tourist.uid, newStatus);
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
    emit(UsersSuccess(tourists: List.unmodifiable(_tourists), query: _query));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

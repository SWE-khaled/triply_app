import 'package:flutter_bloc/flutter_bloc.dart';

/// Emits safely after an async gap.
///
/// A screen can be popped while a read or a write is still in flight —
/// [Cubit.emit] throws in that case ("Cannot emit new states after
/// calling close"). Every emit that follows an `await` goes through
/// [safeEmit] instead.
mixin SafeEmitMixin<State> on Cubit<State> {
  /// Emits [next] unless this cubit is already closed.
  void safeEmit(State next) {
    if (isClosed) return;
    emit(next);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import 'logout_state.dart';

/// Owns the sign-out write. Navigation and feedback stay in the View.
class LogoutCubit extends Cubit<LogoutState> with SafeEmitMixin<LogoutState> {
  LogoutCubit({required this.onSignOut}) : super(const LogoutInitial());

  /// Wired to `AuthCubit.signOut()` so the session reset still runs.
  final Future<void> Function() onSignOut;

  Future<void> logout() async {
    safeEmit(const LoggingOut());
    try {
      await onSignOut();
      safeEmit(const LoggedOut());
    } catch (error) {
      safeEmit(LogoutError(message: 'Logout failed: $error'));
    }
  }
}

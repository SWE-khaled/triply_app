import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../../common/auth/data/auth_repository.dart';
import 'guide_phone_state.dart';

/// Loads the guide's public phone for the Trip Details guide card.
///
/// The per-guide cache is kept here so the session behavior of the old
/// TripDetailsCubit helper is preserved.
class GuidePhoneCubit extends Cubit<GuidePhoneState>
    with SafeEmitMixin<GuidePhoneState> {
  GuidePhoneCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const GuidePhoneInitial());

  final AuthRepository _authRepository;

  final Map<String, Future<String?>> _requests = {};
  final Map<String, String?> _values = {};

  Future<void> loadPhone(String guideId) async {
    if (guideId.isEmpty) {
      safeEmit(const GuidePhoneSuccess(phone: null));
      return;
    }
    final cached = _values[guideId];
    if (_values.containsKey(guideId)) {
      safeEmit(GuidePhoneSuccess(phone: cached));
      return;
    }
    safeEmit(const GuidePhoneLoading());
    try {
      final request = _requests.putIfAbsent(
        guideId,
        () => _authRepository.getUserPhone(guideId),
      );
      final phone = await request;
      _values[guideId] = phone;
      safeEmit(GuidePhoneSuccess(phone: phone));
    } catch (error) {
      safeEmit(GuidePhoneError(message: pageLoadErrorMessage(error)));
    }
  }
}

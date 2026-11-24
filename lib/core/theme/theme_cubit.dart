import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/app_prefs.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false);

  String? _accountId;
  String? _role;
  int _loadGeneration = 0;

  bool get isDark => state;

  Future<void> loadForAccount(
    String? accountId, {
    String? role = 'tourist',
  }) async {
    final generation = ++_loadGeneration;
    _accountId = accountId;
    _role = role == 'tourist' || role == 'guide' ? role : null;
    if (accountId == null || accountId.isEmpty || _role == null) {
      emit(false);
      return;
    }
    final isDark = await AppPrefs.instance.darkModeForRole(accountId, _role!);
    if (generation == _loadGeneration) emit(isDark);
  }

  Future<void> setDarkMode(bool enabled, {String? role}) async {
    ++_loadGeneration;
    final accountId = _accountId;
    final roleToSave = role ?? _role;
    if (accountId == null ||
        accountId.isEmpty ||
        roleToSave == null ||
        (roleToSave != 'tourist' && roleToSave != 'guide')) {
      emit(false);
      return;
    }
    _role = roleToSave;
    emit(enabled);
    await AppPrefs.instance.setDarkModeForRole(accountId, roleToSave, enabled);
  }

  Future<void> toggle() => setDarkMode(!state);
}

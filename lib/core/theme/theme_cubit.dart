import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/app_prefs.dart';
import '../utils/safe_emit_mixin.dart';
import 'app_palette.dart';

/// Owns the app-wide theme choice and keeps [AppPalette] in sync with it.
///
/// The state is a plain [ThemeMode], so `BlocBuilder<ThemeCubit, ThemeMode>`
/// around `MaterialApp` is enough to apply a new `themeMode` instantly. The
/// choice is persisted through [AppPrefs] and restored on the next launch.
class ThemeCubit extends Cubit<ThemeMode> with SafeEmitMixin<ThemeMode> {
  ThemeCubit({AppPrefs? prefs, Brightness? platformBrightness})
    : _prefs = prefs ?? AppPrefs.instance,
      _platformBrightness =
          platformBrightness ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
      super(ThemeMode.system) {
    _applyPalette(state);
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    _previousBrightnessHandler = dispatcher.onPlatformBrightnessChanged;
    dispatcher.onPlatformBrightnessChanged = _onPlatformBrightnessChanged;
  }

  final AppPrefs _prefs;
  Brightness _platformBrightness;
  void Function()? _previousBrightnessHandler;

  /// Restores the saved preference. Safe to call at startup — failures fall
  /// back to `ThemeMode.system` without interrupting the splash.
  Future<void> load() async {
    final saved = await _prefs.themeMode();
    if (saved != null) setMode(saved);
  }

  /// Applies and persists a new mode.
  void setMode(ThemeMode mode) {
    _applyPalette(mode);
    safeEmit(mode);
    _prefs.setThemeMode(mode).catchError((Object error) {
      // Persistence is best-effort; the in-memory choice still applies.
    });
  }

  /// Switches between light and dark. When `system` is selected, this flips
  /// the currently resolved brightness so the switch always has a visible
  /// effect on the first tap.
  void toggle() {
    final resolved = AppPalette.forMode(state, _platformBrightness);
    setMode(resolved.isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => AppPalette.forMode(state, _platformBrightness).isDark;

  void _applyPalette(ThemeMode mode) {
    AppPalette.current = AppPalette.forMode(mode, _platformBrightness);
  }

  void _onPlatformBrightnessChanged() {
    _previousBrightnessHandler?.call();
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (state == ThemeMode.system) {
      _applyPalette(state);
      safeEmit(state);
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        _previousBrightnessHandler;
    return super.close();
  }
}

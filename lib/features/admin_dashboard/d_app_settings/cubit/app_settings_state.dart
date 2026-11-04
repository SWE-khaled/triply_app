part of 'app_settings_cubit.dart';

/// The state of the App Settings tab.
@immutable
sealed class AppSettingsState {
  const AppSettingsState();
}

/// Nothing has been requested yet.
final class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

/// The settings document is being loaded for the first time.
final class AppSettingsLoading extends AppSettingsState {
  const AppSettingsLoading();
}

/// The settings could not be read.
final class AppSettingsError extends AppSettingsState {
  final String message;

  const AppSettingsError(this.message);
}

/// The current settings, kept in sync with the `appSettings/general` doc.
final class AppSettingsSuccess extends AppSettingsState {
  final String commission;
  final String approvalMode;
  final bool saving;

  const AppSettingsSuccess({
    this.commission = '10',
    this.approvalMode = 'Manual admin approval',
    this.saving = false,
  });

  AppSettingsSuccess copyWith({
    String? commission,
    String? approvalMode,
    bool? saving,
  }) {
    return AppSettingsSuccess(
      commission: commission ?? this.commission,
      approvalMode: approvalMode ?? this.approvalMode,
      saving: saving ?? this.saving,
    );
  }
}

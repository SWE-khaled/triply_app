import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_settings_state.dart';

/// Owns the App Settings tab: the `appSettings/general` document and the
/// save action.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const AppSettingsInitial());

  /// The approval modes the dropdown offers.
  static const List<String> approvalOptions = [
    'Manual admin approval',
    'Automatic approval',
    'Semi-automatic review',
  ];

  final FirebaseFirestore _firestore;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _started = false;

  /// Starts listening to the settings document. Calling it twice is a no-op.
  void start() {
    if (_started) return;
    _started = true;
    emit(const AppSettingsLoading());
    _subscription = _firestore
        .collection('appSettings')
        .doc('general')
        .snapshots()
        .listen(
          (doc) {
            final data = doc.data();
            final current = state;
            final saving = current is AppSettingsSuccess
                ? current.saving
                : false;
            final commission = data?['commission']?.toString() ?? '10';
            final rawMode = (data?['approvalMode'] as String?) ??
                'Manual admin approval';
            final mode = approvalOptions.contains(rawMode)
                ? rawMode
                : 'Manual admin approval';
            emit(
              AppSettingsSuccess(
                commission: commission,
                approvalMode: mode,
                saving: saving,
              ),
            );
          },
          onError: (_) {
            if (!isClosed) {
              emit(const AppSettingsError('Could not load app settings.'));
            }
          },
        );
  }

  /// Cancels the current listener and starts over.
  void retry() {
    _subscription?.cancel();
    _started = false;
    start();
  }

  /// Updates the dropdown choice locally; [save] persists it.
  void setApprovalMode(String mode) {
    final current = state;
    if (current is AppSettingsSuccess) {
      emit(current.copyWith(approvalMode: mode));
    }
  }

  /// Writes the settings to Firestore.
  ///
  /// Returns `null` on success, or the message to show when the save failed.
  Future<String?> save(String commissionText) async {
    final current = state;
    if (current is! AppSettingsSuccess) return 'Settings are still loading.';

    emit(current.copyWith(saving: true));
    try {
      final commission = double.tryParse(commissionText.trim()) ?? 10.0;
      await _firestore
          .collection('appSettings')
          .doc('general')
          .set({
            'commission': commission,
            'approvalMode': current.approvalMode,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!isClosed) {
        emit(
          current.copyWith(
            commission: commissionText.trim(),
            saving: false,
          ),
        );
      }
      return null;
    } catch (error) {
      if (!isClosed) emit(current.copyWith(saving: false));
      return 'Failed to save settings: $error';
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

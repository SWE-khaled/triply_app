import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../support/contact_us/data/contact_messages_repository.dart';
import '../../../support/contact_us/model/contact_message_model.dart';

part 'support_center_state.dart';

/// Owns the live Support Center list and admin status updates.
class SupportCenterCubit extends Cubit<SupportCenterState> {
  SupportCenterCubit({ContactMessagesRepository? repository})
    : _repository = repository ?? ContactMessagesRepository(),
      super(const SupportCenterInitial());

  final ContactMessagesRepository _repository;
  StreamSubscription<List<ContactMessageModel>>? _subscription;
  List<ContactMessageModel> _messages = const [];
  String _query = '';
  String _statusFilter = 'all';
  String _roleFilter = 'all';
  final Set<String> _busyIds = {};

  void start() {
    emit(const SupportCenterLoading());
    _subscription?.cancel();
    try {
      _subscription = _repository.watchAll().listen(
        (messages) {
          _messages = messages;
          _emitSuccess();
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('SupportCenter stream failed: $error\n$stackTrace');
          if (!isClosed) {
            emit(SupportCenterError(loadErrorMessage(error)));
          }
        },
      );
    } catch (error, stackTrace) {
      debugPrint('SupportCenter query failed: $error\n$stackTrace');
      if (!isClosed) emit(SupportCenterError(loadErrorMessage(error)));
    }
  }

  void retry() => start();

  void search(String query) {
    _query = query;
    _emitSuccess();
  }

  void filterByStatus(String status) {
    _statusFilter = status;
    _emitSuccess();
  }

  void filterByRole(String role) {
    _roleFilter = role;
    _emitSuccess();
  }

  Future<String?> updateStatus(ContactMessageModel message, String status) async {
    if (_busyIds.contains(message.id)) {
      return 'This message is already being updated.';
    }
    if (!ContactMessageModel.statuses.contains(status)) {
      return 'Unsupported status.';
    }
    if (message.status == status) return null;

    _busyIds.add(message.id);
    _emitSuccess();
    try {
      await _repository.updateStatus(messageId: message.id, status: status);
      return null;
    } catch (error, stackTrace) {
      debugPrint('SupportCenter status update failed: $error\n$stackTrace');
      return statusErrorMessage(error);
    } finally {
      _busyIds.remove(message.id);
      _emitSuccess();
    }
  }

  static String loadErrorMessage(Object error) {
    if (error is FirebaseException) {
      final detail = error.message?.trim().isNotEmpty ?? false
          ? error.message!.trim()
          : 'no additional details';
      return switch (error.code) {
        'permission-denied' =>
          'Permission denied reading contact messages. Ask an administrator '
              'to publish the latest Firestore rules and verify your admin role.',
        'unauthenticated' =>
          'Your admin session expired. Please sign in again.',
        'unavailable' || 'deadline-exceeded' =>
          'Firestore is temporarily unavailable. Please try again shortly.',
        'failed-precondition' =>
          'The support query is not configured correctly. Please contact '
              'an administrator.',
        _ => 'Could not load contact messages (${error.code}): $detail',
      };
    }
    return 'Could not load contact messages: $error';
  }

  static String statusErrorMessage(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Permission denied: only an administrator can change message '
            'statuses.';
      }
      if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
        return 'Firestore is temporarily unavailable. Please try again.';
      }
      return 'Could not update status (${error.code}): '
          '${error.message ?? 'no additional details'}';
    }
    return 'Could not update status: $error';
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(
      SupportCenterSuccess(
        messages: List.unmodifiable(_messages),
        query: _query,
        statusFilter: _statusFilter,
        roleFilter: _roleFilter,
        busyIds: Set.unmodifiable(_busyIds),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

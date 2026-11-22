import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/admin_dashboard/d_support_center/cubit/support_center_cubit.dart';
import 'package:triply/features/support/contact_us/data/contact_messages_repository.dart';
import 'package:triply/features/support/contact_us/model/contact_message_model.dart';

class FakeContactMessagesRepository extends ContactMessagesRepository {
  Completer<void>? updateGate;
  Object? streamError;
  final List<String> updatedIds = <String>[];

  @override
  Stream<List<ContactMessageModel>> watchAll() {
    final error = streamError;
    if (error == null) return Stream<List<ContactMessageModel>>.empty();
    return Stream<List<ContactMessageModel>>.error(error);
  }

  @override
  Future<void> updateStatus({
    required String messageId,
    required String status,
  }) async {
    updatedIds.add(messageId);
    await updateGate?.future;
  }
}

ContactMessageModel _message({
  required String id,
  required String role,
  required String status,
  required String name,
  required String text,
  required String type,
}) {
  return ContactMessageModel(
    id: id,
    userId: 'uid-$id',
    userName: name,
    userEmail: '$id@example.com',
    userRole: role,
    message: text,
    type: type,
    status: status,
  );
}

SupportCenterSuccess _state({
  String query = '',
  String statusFilter = 'all',
  String roleFilter = 'all',
}) {
  return SupportCenterSuccess(
    messages: <ContactMessageModel>[
      _message(
        id: '1',
        role: 'tourist',
        status: 'pending',
        name: 'Ahmed',
        text: 'My trip was cancelled.',
        type: 'complaint',
      ),
      _message(
        id: '2',
        role: 'tourGuide',
        status: 'inProgress',
        name: 'Mona',
        text: 'Question about guide payouts.',
        type: 'inquiry',
      ),
      _message(
        id: '3',
        role: 'tourist',
        status: 'resolved',
        name: 'Sara',
        text: 'General feedback about the app.',
        type: 'general',
      ),
    ],
    query: query,
    statusFilter: statusFilter,
    roleFilter: roleFilter,
    busyIds: const <String>{},
  );
}

void main() {
  group('SupportCenterSuccess', () {
    test('filters by status and role together', () {
      expect(_state().filtered, hasLength(3));
      expect(_state(statusFilter: 'pending').filtered.map((m) => m.id),
          <String>['1']);
      expect(_state(roleFilter: 'tourGuide').filtered.map((m) => m.id),
          <String>['2']);
      expect(
        _state(statusFilter: 'resolved', roleFilter: 'tourist')
            .filtered
            .map((m) => m.id),
        <String>['3'],
      );
    });

    test('searches sender and message fields', () {
      expect(_state(query: 'mona').filtered.map((m) => m.id), <String>['2']);
      expect(_state(query: 'cancelled').filtered.map((m) => m.id),
          <String>['1']);
      expect(_state(query: 'missing').filtered, isEmpty);
    });
  });

  group('SupportCenterCubit', () {
    test('ignores a second status update for the same message', () async {
      final repository = FakeContactMessagesRepository();
      final gate = Completer<void>();
      repository.updateGate = gate;
      final cubit = SupportCenterCubit(repository: repository);
      addTearDown(() => cubit.close());
      final message = _message(
        id: '9',
        role: 'tourist',
        status: 'pending',
        name: 'Test',
        text: 'Please review this request.',
        type: 'general',
      );

      final first = cubit.updateStatus(message, 'resolved');
      final second = await cubit.updateStatus(message, 'resolved');

      expect(second, isNotNull);
      expect(repository.updatedIds, <String>['9']);
      gate.complete();
      expect(await first, isNull);
    });

    test('explains a Firestore permission-denied stream failure', () async {
      final repository = FakeContactMessagesRepository()
        ..streamError = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        );
      final cubit = SupportCenterCubit(repository: repository);
      addTearDown(() => cubit.close());

      cubit.start();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(cubit.state, isA<SupportCenterError>());
      expect(
        (cubit.state as SupportCenterError).message,
        contains('Permission denied reading contact messages'),
      );
    });
  });
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/support/contact_us/cubit/contact_us_view_model.dart';
import 'package:triply/features/support/contact_us/data/contact_messages_repository.dart';

class FakeContactMessagesRepository extends ContactMessagesRepository {
  FakeContactMessagesRepository({
    this.identity = const ContactIdentity(
      uid: 'uid-1',
      name: 'Test Tourist',
      email: 'tourist@example.com',
      role: 'tourist',
    ),
  });

  final ContactIdentity identity;
  final List<Map<String, String>> submissions = <Map<String, String>>[];
  Completer<void>? submitGate;
  Object? submitError;

  @override
  Future<ContactIdentity> currentIdentity() async => identity;

  @override
  Future<void> submit({
    required String email,
    required String message,
    required String type,
  }) async {
    submissions.add(<String, String>{
      'email': email,
      'message': message,
      'type': type,
    });
    await submitGate?.future;
    final error = submitError;
    if (error != null) throw error;
  }
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 1));

void main() {
  group('ContactUsViewModel', () {
    test('prefills the authenticated email and role', () async {
      final repository = FakeContactMessagesRepository();
      final viewModel = ContactUsViewModel(repository: repository);
      addTearDown(() => viewModel.close());

      await _settle();

      expect(viewModel.state.email, 'tourist@example.com');
      expect(viewModel.state.emailLocked, isTrue);
      expect(viewModel.state.userName, 'Test Tourist');
      expect(viewModel.state.userRole, 'tourist');
      expect(viewModel.state.status, ContactFormStatus.ready);
    });

    test('rejects an invalid email and a too-short message', () async {
      final repository = FakeContactMessagesRepository();
      final viewModel = ContactUsViewModel(repository: repository);
      addTearDown(() => viewModel.close());
      await _settle();

      viewModel.emailChanged('not-an-email');
      viewModel.messageChanged('short');
      final submitted = await viewModel.submit();

      expect(submitted, isFalse);
      expect(repository.submissions, isEmpty);
      expect(viewModel.state.emailError, contains('valid email'));
      expect(viewModel.state.messageError, contains('at least 10'));
    });

    test('prevents duplicate submissions while one is in flight', () async {
      final repository = FakeContactMessagesRepository();
      final gate = Completer<void>();
      repository.submitGate = gate;
      final viewModel = ContactUsViewModel(repository: repository);
      addTearDown(() => viewModel.close());
      await _settle();

      viewModel.messageChanged('This is a detailed complaint about my trip.');
      final first = viewModel.submit();
      final second = viewModel.submit();

      expect(await second, isFalse);
      expect(repository.submissions, hasLength(1));
      expect(viewModel.state.status, ContactFormStatus.submitting);

      gate.complete();
      expect(await first, isTrue);
      expect(viewModel.state.status, ContactFormStatus.success);
      expect(viewModel.state.message, isEmpty);
      expect(viewModel.state.feedback, contains('has been sent'));
      expect(repository.submissions.single['type'], 'general');
    });

    test('surfaces a submission failure without clearing the message',
        () async {
      final repository = FakeContactMessagesRepository()
        ..submitError = StateError('offline');
      final viewModel = ContactUsViewModel(repository: repository);
      addTearDown(() => viewModel.close());
      await _settle();

      viewModel.messageChanged('This is a detailed inquiry about my booking.');
      final submitted = await viewModel.submit();

      expect(submitted, isFalse);
      expect(viewModel.state.status, ContactFormStatus.failure);
      expect(viewModel.state.isFeedbackError, isTrue);
      expect(viewModel.state.feedback, contains('Could not send'));
      expect(viewModel.state.message,
          'This is a detailed inquiry about my booking.');
    });

    test('explains a Firestore permission-denied failure', () async {
      final repository = FakeContactMessagesRepository()
        ..submitError = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        );
      final viewModel = ContactUsViewModel(repository: repository);
      addTearDown(() => viewModel.close());
      await _settle();

      viewModel.messageChanged('This is a detailed inquiry about my booking.');
      final submitted = await viewModel.submit();

      expect(submitted, isFalse);
      expect(viewModel.state.feedback, contains('Permission denied'));
      expect(viewModel.state.feedback, contains('publish the latest Firestore rules'));
    });
  });
}

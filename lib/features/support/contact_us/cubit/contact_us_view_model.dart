import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/contact_messages_repository.dart';

part 'contact_us_state.dart';

/// MVVM ViewModel for the shared Tourist/Tour Guide Contact Us screen.
///
/// It owns validation, trusted identity prefill, submission state and
/// duplicate-submit protection. The view only renders state and calls methods.
class ContactUsViewModel extends Cubit<ContactUsState> {
  ContactUsViewModel({ContactMessagesRepository? repository})
    : _repository = repository ?? ContactMessagesRepository(),
      super(const ContactUsState()) {
    loadIdentity();
  }

  static const int minMessageLength = 10;
  static const int maxMessageLength = 1000;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final ContactMessagesRepository _repository;

  /// Prefills the email from the authenticated account when available.
  Future<void> loadIdentity() async {
    emit(state.copyWith(status: ContactFormStatus.ready));
    try {
      final identity = await _repository.currentIdentity();
      if (isClosed) return;
      emit(
        state.copyWith(
          email: identity.email,
          userName: identity.name,
          userRole: identity.role,
          emailLocked: identity.email.isNotEmpty,
          status: ContactFormStatus.ready,
          clearEmailError: true,
        ),
      );
    } catch (error, stackTrace) {
      // The form remains usable; validation will still require an email.
      debugPrint('ContactUs identity prefill failed: $error\n$stackTrace');
      if (!isClosed) emit(state.copyWith(status: ContactFormStatus.ready));
    }
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        status: ContactFormStatus.ready,
        clearEmailError: true,
        clearFeedback: true,
      ),
    );
  }

  void messageChanged(String value) {
    emit(
      state.copyWith(
        message: value,
        status: ContactFormStatus.ready,
        clearMessageError: true,
        clearFeedback: true,
      ),
    );
  }

  void typeChanged(ContactMessageType type) {
    emit(
      state.copyWith(
        type: type,
        status: ContactFormStatus.ready,
        clearFeedback: true,
      ),
    );
  }

  /// Returns `true` only when the message was actually submitted.
  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final emailError = validateEmail(state.email);
    final messageError = validateMessage(state.message);
    if (emailError != null || messageError != null) {
      emit(
        state.copyWith(
          status: ContactFormStatus.failure,
          emailError: emailError,
          messageError: messageError,
          clearEmailError: emailError == null,
          clearMessageError: messageError == null,
          clearFeedback: true,
          isFeedbackError: false,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: ContactFormStatus.submitting,
        clearFeedback: true,
        clearEmailError: true,
        clearMessageError: true,
      ),
    );

    try {
      await _repository.submit(
        email: state.email.trim(),
        message: state.message.trim(),
        type: state.type.value,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ContactFormStatus.success,
            message: '',
            feedback: 'Your message has been sent. We will review it soon.',
            isFeedbackError: false,
          ),
        );
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('ContactUs submission failed: $error\n$stackTrace');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ContactFormStatus.failure,
            feedback: submitErrorMessage(error),
            isFeedbackError: true,
          ),
        );
      }
      return false;
    }
  }

  /// Converts a data-layer failure into an actionable user message without
  /// hiding the Firestore reason behind a generic retry string.
  static String submitErrorMessage(Object error) {
    if (error is StateError) {
      return 'Could not send your message: ${error.message}';
    }
    if (error is FirebaseException) {
      final detail = error.message?.trim().isNotEmpty ?? false
          ? error.message!.trim()
          : 'no additional details';
      return switch (error.code) {
        'permission-denied' =>
          'Permission denied: your account is not authorized to send '
              'support messages yet. Ask an administrator to publish the '
              'latest Firestore rules.',
        'unauthenticated' =>
          'Your session expired. Please sign in again and retry.',
        'not-found' =>
          'Your account profile was not found. Please complete your profile '
              'and retry.',
        'unavailable' || 'deadline-exceeded' =>
          'Firestore is temporarily unavailable. Please try again shortly.',
        'failed-precondition' =>
          'The support service is not configured correctly. Please contact '
              'an administrator.',
        _ => 'Could not send your message (${error.code}): $detail',
      };
    }
    return 'Could not send your message: $error';
  }

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email address is required.';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  static String? validateMessage(String value) {
    final message = value.trim();
    if (message.isEmpty) return 'Message is required.';
    if (message.length < minMessageLength) {
      return 'Message must be at least $minMessageLength characters.';
    }
    if (message.length > maxMessageLength) {
      return 'Message must be $maxMessageLength characters or fewer.';
    }
    return null;
  }
}

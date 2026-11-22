part of 'contact_us_view_model.dart';

/// The selected category of a support message.
enum ContactMessageType {
  complaint,
  inquiry,
  general;

  String get value => switch (this) {
    ContactMessageType.complaint => 'complaint',
    ContactMessageType.inquiry => 'inquiry',
    ContactMessageType.general => 'general',
  };

  String get label => switch (this) {
    ContactMessageType.complaint => 'Complaint',
    ContactMessageType.inquiry => 'Inquiry',
    ContactMessageType.general => 'General',
  };
}

enum ContactFormStatus { initial, ready, submitting, success, failure }

@immutable
class ContactUsState {
  const ContactUsState({
    this.email = '',
    this.message = '',
    this.type = ContactMessageType.general,
    this.status = ContactFormStatus.initial,
    this.emailError,
    this.messageError,
    this.feedback,
    this.isFeedbackError = false,
    this.userName,
    this.userRole,
    this.emailLocked = false,
  });

  final String email;
  final String message;
  final ContactMessageType type;
  final ContactFormStatus status;
  final String? emailError;
  final String? messageError;
  final String? feedback;
  final bool isFeedbackError;
  final String? userName;
  final String? userRole;
  final bool emailLocked;

  bool get isSubmitting => status == ContactFormStatus.submitting;

  ContactUsState copyWith({
    String? email,
    String? message,
    ContactMessageType? type,
    ContactFormStatus? status,
    String? emailError,
    String? messageError,
    String? feedback,
    bool? isFeedbackError,
    String? userName,
    String? userRole,
    bool? emailLocked,
    bool clearEmailError = false,
    bool clearMessageError = false,
    bool clearFeedback = false,
    bool clearIdentity = false,
  }) {
    return ContactUsState(
      email: email ?? this.email,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      messageError: clearMessageError
          ? null
          : (messageError ?? this.messageError),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      isFeedbackError: isFeedbackError ?? this.isFeedbackError,
      userName: clearIdentity ? null : (userName ?? this.userName),
      userRole: clearIdentity ? null : (userRole ?? this.userRole),
      emailLocked: emailLocked ?? this.emailLocked,
    );
  }
}

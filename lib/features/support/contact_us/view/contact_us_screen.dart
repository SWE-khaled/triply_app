import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/contact_us_view_model.dart';

/// Shared Contact Us screen used by Tourist and Tour Guide settings.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactUsViewModel(),
      child: const _ContactUsView(),
    );
  }
}

class _ContactUsView extends StatefulWidget {
  const _ContactUsView();

  @override
  State<_ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<_ContactUsView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _syncEmailField(String trustedEmail) {
    if (trustedEmail.isEmpty || trustedEmail == _emailController.text) return;
    if (_emailFocus.hasFocus) return;
    _emailController.value = _emailController.value.copyWith(
      text: trustedEmail,
      selection: TextSelection.collapsed(offset: trustedEmail.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderSide = BorderSide(
      color: colors.outline.withValues(alpha: 0.45),
    );

    InputBorder fieldBorder({bool focused = false}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: focused
          ? BorderSide(color: colors.primary, width: 1.6)
          : borderSide,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: colors.onSurface,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Contact Us',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ContactUsViewModel, ContactUsState>(
          listener: (context, state) {
            _syncEmailField(state.email);
            final feedback = state.feedback;
            if (feedback == null) return;
            showAppSnackBar(
              context,
              feedback,
              icon: state.isFeedbackError
                  ? Icons.error_outline
                  : Icons.check_circle,
            );
          },
          builder: (context, state) {
            final cubit = context.read<ContactUsViewModel>();
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Help & Support',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tell us what happened and the Triply administration '
                        'will review your message.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: colors.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        readOnly: state.emailLocked,
                        onChanged: cubit.emailChanged,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'you@example.com',
                          filled: true,
                          fillColor: colors.onSurface.withValues(alpha: 0.03),
                          errorText: state.emailError,
                          border: fieldBorder(),
                          enabledBorder: fieldBorder(),
                          focusedBorder: fieldBorder(focused: true),
                          errorBorder: fieldBorder(),
                          focusedErrorBorder: fieldBorder(focused: true),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        minLines: 4,
                        maxLength: ContactUsViewModel.maxMessageLength,
                        onChanged: cubit.messageChanged,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          hintText: 'Describe your complaint or inquiry...',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: colors.onSurface.withValues(alpha: 0.03),
                          errorText: state.messageError,
                          border: fieldBorder(),
                          enabledBorder: fieldBorder(),
                          focusedBorder: fieldBorder(focused: true),
                          errorBorder: fieldBorder(),
                          focusedErrorBorder: fieldBorder(focused: true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ContactMessageType>(
                        initialValue: state.type,
                        onChanged: state.isSubmitting
                            ? null
                            : (value) {
                                if (value != null) cubit.typeChanged(value);
                              },
                        items: ContactMessageType.values
                            .map(
                              (type) => DropdownMenuItem<ContactMessageType>(
                                value: type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Message type',
                          filled: true,
                          fillColor: colors.onSurface.withValues(alpha: 0.03),
                          border: fieldBorder(),
                          enabledBorder: fieldBorder(),
                          focusedBorder: fieldBorder(focused: true),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.isSubmitting ? null : cubit.submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

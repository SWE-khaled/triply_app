import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/common/auth/cubit/auth_cubit.dart';
import 'package:triply/features/tour_guide/home_and_notification_tg/view/guide_dashboard_screen.dart';
import 'package:triply/core/routing/app_routes.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../tour_guide/profile_tg/data/tour_guide_profile_service.dart';

class TourGuideVerificationScreen extends StatefulWidget {
  const TourGuideVerificationScreen({super.key});

  @override
  State<TourGuideVerificationScreen> createState() =>
      _TourGuideVerificationScreenState();
}

class _TourGuideVerificationScreenState
    extends State<TourGuideVerificationScreen> {
  PlatformFile? _idFile;
  PlatformFile? _licenseFile;
  bool _isLoading = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final TourGuideProfileService _authService = TourGuideProfileService();

  Future<void> _pickFile(int type) async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result.isNotEmpty) {
        final file = result.first;

        // Validate file size (10 MB = 10 * 1024 * 1024 bytes)
        final fileSize = file.lengthSync() ?? await file.length();
        if (fileSize != null && fileSize > 10485760) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File must be smaller than 10MB.')),
          );
          return;
        }

        setState(() {
          if (type == 1) {
            _idFile = file;
          } else {
            _licenseFile = file;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _submitForReview() async {
    if (_idFile == null || _licenseFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please log in again.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final idDocUrl = await _cloudinaryService.uploadFile(_idFile!, user.uid);
      final licenseDocUrl = await _cloudinaryService.uploadFile(
        _licenseFile!,
        user.uid,
      );

      await _authService.submitVerificationDocuments(
        idDocumentUrl: idDocUrl,
        licenseDocumentUrl: licenseDocUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documents submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GuideDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        _idFile != null && _licenseFile != null && !_isLoading;

    return Scaffold(
      backgroundColor: AppThemeColors.resolve(
        context,
        light: Colors.white,
        dark: AppThemeDark.backgroundPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back + skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button — leaves the guide session and returns to
                  // the guide login without stacking it over this screen.
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            final authCubit = context.read<AuthCubit>();
                            // Navigate first: the verification screen's
                            // Firestore listener is cancelled on dispose,
                            // before the auth token is revoked.
                            navigator.pushNamedAndRemoveUntil(
                              AppRoutes.guideLogin,
                              (_) => false,
                            );
                            await WidgetsBinding.instance.endOfFrame;
                            try {
                              await authCubit.signOut();
                            } catch (_) {
                              // Already on the login screen; the next
                              // sign-in simply overwrites the old token.
                            }
                          },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFFE0E0E0),
                            dark: AppThemeDark.borderSubtle,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.deepNile,
                          dark: AppThemeDark.textPrimary,
                        ),
                        size: 20,
                      ),
                    ),
                  ),
                  // Skip for now
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GuideDashboardScreen(),
                              ),
                              (route) => false,
                            );
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      backgroundColor: AppThemeColors.resolve(
                        context,
                        light: const Color(0xFFF5F5F5),
                        dark: AppThemeDark.surfaceElevated,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.deepNile,
                          dark: AppThemeDark.textPrimary,
                        ),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // "FINAL STEP" label
                    const Text(
                      'FINAL STEP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4923A), // warm orange/gold
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      'Verify your guide identity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppThemeColors.resolve(
                          context,
                          light: AppColors.deepNile,
                          dark: AppThemeDark.homeSectionTitle,
                        ),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'Upload your identity document and a separate official document proving that you\'re a licensed guide.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFF7A9B9F),
                          dark: AppThemeDark.textSecondary,
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Accepted Documents card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppThemeColors.resolve(
                          context,
                          light: Colors.white,
                          dark: AppThemeDark.surfaceDefault,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFFE8E8E8),
                            dark: AppThemeDark.borderSubtle,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accepted documents',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.deepNile,
                                dark: AppThemeDark.homeSectionTitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildBullet(context, 'Ministry of Tourism guide ID'),
                          const SizedBox(height: 6),
                          _buildBullet(
                            context,
                            'Tour guide syndicate membership',
                          ),
                          const SizedBox(height: 6),
                          _buildBullet(
                            context,
                            'Valid professional guide license',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Review time info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppThemeColors.resolve(
                          context,
                          light: const Color(0xFFEDF6F8),
                          dark: AppThemeDark.surfaceElevated,
                        ), // very light teal background
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFFB8D8DF),
                            dark: AppThemeDark.borderSubtle,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review time: 3–6 working days',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.deepNile,
                                dark: AppThemeDark.homeSectionTitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You can use your dashboard while your documents are being reviewed, but you can\'t publish trips yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppThemeColors.resolve(
                                context,
                                light: AppColors.deepNile.withValues(
                                  alpha: 0.70,
                                ),
                                dark: AppThemeDark.textSecondary,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live submission status — follows the admin's
                    // decision through Firestore snapshots, no reload.
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: _authService.watchVerificationSubmission(),
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        final status = data?['status'] as String?;
                        if (status == null) return const SizedBox.shrink();
                        if (status == 'approved') {
                          return _buildStatusCard(
                            color: Colors.green,
                            icon: Icons.verified,
                            title: 'Documents approved',
                            message:
                                'Your documents are approved. You can publish trips now.',
                          );
                        }
                        if (status == 'rejected') {
                          final reason =
                              (data?['rejectionReason'] as String?) ?? '';
                          return _buildStatusCard(
                            color: Colors.red,
                            icon: Icons.cancel_outlined,
                            title: 'Documents rejected',
                            message: reason.isEmpty
                                ? 'Please review and re-upload your documents.'
                                : reason,
                          );
                        }
                        return _buildStatusCard(
                          color: AppThemeColors.resolve(
                            context,
                            light: const Color(0xFF2E7D8F),
                            dark: AppThemeDark.homeSeeAll,
                          ),
                          icon: Icons.hourglass_top,
                          title: 'Documents under review',
                          message:
                              'We received your documents. The admin usually responds within 3–6 working days. You cannot re-upload until a decision is made.',
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Upload ID Box + Upload Guide License Box.
                    // The pickers follow the live status: locked while the
                    // submission is pending or approved — documents may
                    // only be replaced after a rejection.
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: _authService.watchVerificationSubmission(),
                      builder: (context, snapshot) {
                        final status = snapshot.data?['status'] as String?;
                        final locked =
                            status == 'pending' || status == 'approved';
                        return Column(
                          children: [
                            _buildUploadBox(
                              context: context,
                              number: '1',
                              title: 'Upload your ID',
                              subtitle: 'JPG, PNG or PDF · max 10 MB',
                              file: _idFile,
                              onTap: (locked || _isLoading)
                                  ? null
                                  : () => _pickFile(1),
                            ),
                            const SizedBox(height: 14),

                            // Upload Guide License Box
                            _buildUploadBox(
                              context: context,
                              number: '2',
                              title: 'Upload guide license',
                              subtitle:
                                  'Tourism ID, syndicate card or professional license',
                              file: _licenseFile,
                              onTap: (locked || _isLoading)
                                  ? null
                                  : () => _pickFile(2),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Submit / Re-submit Button: disabled while the
                    // submission is pending or approved — the admin
                    // reviews exactly one submission at a time. Enabled
                    // again after a rejection (resubmit).
                    SizedBox(
                      width: double.infinity,
                      child: StreamBuilder<Map<String, dynamic>?>(
                        stream: _authService.watchVerificationSubmission(),
                        builder: (context, snapshot) {
                          final status = snapshot.data?['status'] as String?;
                          final approved = status == 'approved';
                          final pending = status == 'pending';
                          // Submit when files are chosen, not loading,
                          // and the submission is neither approved nor
                          // already under review.
                          final canSubmitNow =
                              canSubmit && !approved && !pending && !_isLoading;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSubmitNow
                                  ? AppColors.deepNile
                                  : AppThemeColors.resolve(
                                      context,
                                      light: const Color(0xFF7A9B9F),
                                      dark: AppThemeDark.actionDisabled,
                                    ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            onPressed: canSubmitNow ? _submitForReview : null,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    approved
                                        ? 'Documents approved ✓'
                                        : pending
                                        ? 'Under review — waiting for admin'
                                        : status == 'rejected'
                                        ? 'Re-upload documents'
                                        : 'Submit for Review',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            color: AppThemeColors.resolve(
              context,
              light: AppColors.deepNile,
              dark: AppThemeDark.homeSeeAll,
            ),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppThemeColors.resolve(
                context,
                light: AppColors.deepNile,
                dark: AppThemeDark.textPrimary,
              ),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  /// One live verification status banner (approved / pending / rejected).
  Widget _buildStatusCard({
    required Color color,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required BuildContext context,
    required String number,
    required String title,
    required String subtitle,
    required PlatformFile? file,
    required VoidCallback? onTap,
  }) {
    final bool hasFile = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: hasFile
              ? AppThemeColors.resolve(
                  context,
                  light: const Color(0xFFF0F8F5),
                  dark: AppThemeDark.surfaceElevated,
                )
              : AppThemeColors.resolve(
                  context,
                  light: Colors.white,
                  dark: AppThemeDark.surfaceDefault,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile
                ? AppThemeColors.resolve(
                    context,
                    light: Colors.green,
                    dark: AppThemeDark.statusSuccess,
                  )
                : AppThemeColors.resolve(
                    context,
                    light: const Color(0xFFD8D8D8),
                    dark: AppThemeDark.borderSubtle,
                  ),
            width: hasFile ? 1.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_outlined,
              size: 32,
              color: hasFile
                  ? AppThemeColors.resolve(
                      context,
                      light: Colors.green,
                      dark: AppThemeDark.statusSuccess,
                    )
                  : AppThemeColors.resolve(
                      context,
                      light: AppColors.deepNile.withValues(alpha: 0.70),
                      dark: AppThemeDark.homeSeeAll,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? file.name : '$number. $title',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasFile
                    ? AppThemeColors.resolve(
                        context,
                        light: Colors.green[800]!,
                        dark: AppThemeDark.statusSuccess,
                      )
                    : AppThemeColors.resolve(
                        context,
                        light: AppColors.deepNile,
                        dark: AppThemeDark.homeSectionTitle,
                      ),
              ),
            ),
            if (!hasFile) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppThemeColors.resolve(
                    context,
                    light: const Color(0xFF7A9B9F),
                    dark: AppThemeDark.textSecondary,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 6),
              const Text(
                'Tap to change file',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

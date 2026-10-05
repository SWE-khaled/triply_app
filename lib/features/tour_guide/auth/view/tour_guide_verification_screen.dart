import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/tour_guide_colors.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../home/view/tour_guide_home_screen.dart';
import '../data/tour_guide_auth_service.dart';

class TourGuideVerificationScreen extends StatefulWidget {
  const TourGuideVerificationScreen({super.key});

  @override
  State<TourGuideVerificationScreen> createState() => _TourGuideVerificationScreenState();
}

class _TourGuideVerificationScreenState extends State<TourGuideVerificationScreen> {
  PlatformFile? _idFile;
  PlatformFile? _licenseFile;
  bool _isLoading = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final TourGuideAuthService _authService = TourGuideAuthService();

  Future<void> _pickFile(int type) async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        
        // Validate file size (10 MB = 10 * 1024 * 1024 bytes)
        if (file.size > 10485760) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _submitForReview() async {
    if (_idFile == null || _licenseFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final idDocUrl = await _cloudinaryService.uploadFile(_idFile!, user.uid);
      final licenseDocUrl = await _cloudinaryService.uploadFile(_licenseFile!, user.uid);

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
        MaterialPageRoute(builder: (_) => const TourGuideHomeScreen()),
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
    final bool canSubmit = _idFile != null && _licenseFile != null && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back + skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.arrow_back, color: TourGuideColors.deepNile, size: 20),
                    ),
                  ),
                  // Skip for now
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const TourGuideHomeScreen()),
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: TourGuideColors.deepNile,
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
                    const Text(
                      'Verify your guide identity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: TourGuideColors.deepNile,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'Upload your identity document and a separate official document proving that you\'re a licensed guide.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7A9B9F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Accepted Documents card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Accepted documents',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: TourGuideColors.deepNile,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildBullet('Ministry of Tourism guide ID'),
                          const SizedBox(height: 6),
                          _buildBullet('Tour guide syndicate membership'),
                          const SizedBox(height: 6),
                          _buildBullet('Valid professional guide license'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Review time info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF6F8), // very light teal background
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFB8D8DF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Review time: 3–6 working days',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TourGuideColors.deepNile,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You can use your dashboard while your documents are being reviewed, but you can\'t publish trips yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: TourGuideColors.deepNile.withValues(alpha: 0.70),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upload ID Box
                    _buildUploadBox(
                      number: '1',
                      title: 'Upload your ID',
                      subtitle: 'JPG, PNG or PDF · max 10 MB',
                      file: _idFile,
                      onTap: _isLoading ? null : () => _pickFile(1),
                    ),
                    const SizedBox(height: 14),

                    // Upload Guide License Box
                    _buildUploadBox(
                      number: '2',
                      title: 'Upload guide license',
                      subtitle: 'Tourism ID, syndicate card or professional license',
                      file: _licenseFile,
                      onTap: _isLoading ? null : () => _pickFile(2),
                    ),
                    const SizedBox(height: 36),

                    // Submit for Review Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit ? TourGuideColors.deepNile : const Color(0xFF7A9B9F),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        onPressed: canSubmit ? _submitForReview : null,
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Submit for Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: TourGuideColors.deepNile,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: TourGuideColors.deepNile,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
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
          color: hasFile ? const Color(0xFFF0F8F5) : Colors.white, // Subtle green tint if selected
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? Colors.green : const Color(0xFFD8D8D8),
            width: hasFile ? 1.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_outlined,
              size: 32,
              color: hasFile ? Colors.green : TourGuideColors.deepNile.withValues(alpha: 0.70),
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
                color: hasFile ? Colors.green[800] : TourGuideColors.deepNile,
              ),
            ),
            if (!hasFile) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A9B9F),
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

extension on PlatformFile {
  get size => null;
}

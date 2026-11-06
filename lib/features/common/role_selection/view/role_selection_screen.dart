import 'package:flutter/material.dart';
import 'package:triply/core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/app_prefs.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  /// Opens the flow of the chosen role, skipping the slides when they were
  /// already shown once. Without a remembered role there is no completed
  /// login on this device, so the user lands on the login of the chosen
  /// role after the (first-time) onboarding.
  Future<void> _openRole(BuildContext context, String role) async {
    final seen = await AppPrefs.instance.hasSeenOnboarding(role);
    if (!context.mounted) return;

    final route = switch ((role, seen)) {
      ('guide', true) => AppRoutes.guideLogin,
      ('guide', false) => AppRoutes.guideOnboarding,
      (_, true) => AppRoutes.signIn,
      _ => AppRoutes.onboarding,
    };
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        234,
        232,
        226,
      ), // sand/beige background matching Figma
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/edits/Frame 1.png',
                      width: 27,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/images/edits/Frame 2.png',
                    height: 28,
                    width: 64,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'How will you\nuse Triply?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepNile,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose your experience to get started.',
                style: TextStyle(fontSize: 15, color: Color(0xFF7A9B9F)),
              ),
              const SizedBox(height: 24),
              // Tourist Card
              Expanded(
                child: GestureDetector(
                  onTap: () => _openRole(context, 'tourist'),
                  child: _RoleCard(
                    imagePath: 'assets/images/edits/role1p.jpg',
                    title: 'Tourist',
                    description:
                        'Discover Egypt, explore places, find local guides and join unforgettable trips.',
                    buttonText: 'Continue as Tourist',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Tour Guide Card
              Expanded(
                child: GestureDetector(
                  onTap: () => _openRole(context, 'guide'),
                  child: _RoleCard(
                    imagePath: 'assets/images/edits/role2p.jpg',
                    title: 'Tour Guide',
                    description:
                        'Share your knowledge, host experiences, connect with travelers and grow your bookings.',
                    buttonText: 'Continue as Tour Guide',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Footer
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AdminRoutes.login),
                child: Center(
                  child: Text(
                    'Triply Admin Portal',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;

  const _RoleCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image (local asset) ────────────────────────────
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            // Colored fallback if the asset is missing or invalid
            errorBuilder: (_, __, ___) => Container(color: AppColors.deepNile),
          ),

          // ── Gradient overlay ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.deepNile.withValues(alpha: 0.70),
                  AppColors.deepNile.withValues(alpha: 0.95),
                ],
                stops: const [0.25, 0.65, 1.0],
              ),
            ),
          ),

          // ── Card shadow/border ────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Arrow icon top-right
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                // Bottom text (bottom-aligned; scrolls instead of overflowing)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Color(0xFFE6A15C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

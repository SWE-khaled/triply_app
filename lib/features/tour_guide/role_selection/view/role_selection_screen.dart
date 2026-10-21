import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/admin_dashboard/d_auth/view/admin_login_view.dart';
import '../../../../core/constants/tour_guide_colors.dart';
import '../../../common/AuthTourist/cubit/auth_cubit.dart';
import '../../../common/AuthTourist/data/auth_repository.dart';
import '../../../common/AuthTourist/screens/onboarding_screen.dart';
import '../../onboarding/view/tour_guide_onboarding_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  /// The role of the signed-in account, '' when signed out.
  ///
  /// The roles are exclusive: an account is either a tourist or a guide
  /// for its whole life, so the card of the other role is locked.
  String _role = '';
  String? _roleUid;
  Future<String>? _roleFuture;

  Future<String> _roleOf(BuildContext context) {
    final uid = context.read<AuthCubit>().user?.uid;
    if (uid == null) return Future.value('');
    if (uid != _roleUid) {
      _roleUid = uid;
      _roleFuture = AuthRepository().roleOf(uid);
    }
    return _roleFuture!;
  }

  /// Tells the user why the other role is locked instead of silently
  /// doing nothing.
  void _explainLocked(String role) {
    final label = role == 'guide' ? 'Tour Guide' : 'Tourist';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You're signed in as a $label. One account has one role — "
          'sign out to use the other one.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the session changes, so the lock follows the account.
    context.watch<AuthCubit>().user;

    return FutureBuilder<String>(
      future: _roleOf(context),
      builder: (context, snapshot) {
        final role = snapshot.data ?? _role;
        _role = role;
        return Scaffold(
          backgroundColor: const Color.fromARGB(
            255,
            234,
            232,
            226,
          ), // sand/beige background matching Figma
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TourGuideColors.deepNile,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'T',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Triply',
                        style: TextStyle(
                          color: TourGuideColors.deepNile,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'How will you\nuse Triply?',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: TourGuideColors.deepNile,
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
                      onTap: () {
                        if (role == 'guide') {
                          _explainLocked(role);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: _RoleCard(
                        imageUrl:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAdcrwTr2CrRciLN6MEUMeNq3SrUVXpase7qfhxKdcbQ&s=10',
                        title: 'Tourist',
                        description:
                            'Discover Egypt, explore places, find local guides and join unforgettable trips.',
                        buttonText: 'Continue as Tourist',
                        locked: role == 'guide',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Tour Guide Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (role == 'tourist') {
                          _explainLocked(role);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TourGuideOnboardingScreen(),
                          ),
                        );
                      },
                      child: _RoleCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?auto=format&fit=crop&w=800&q=80', // Sphinx and Pyramids
                        title: 'Tour Guide',
                        description:
                            'Share your knowledge, host experiences, connect with travelers and grow your bookings.',
                        buttonText: 'Continue as Tour Guide',
                        locked: role == 'tourist',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginView(),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        'Triply Admin Portal',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String buttonText;

  /// Whether the card belongs to the role this account cannot use.
  final bool locked;

  const _RoleCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.buttonText,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────────
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            // Show a colored placeholder while loading
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(color: TourGuideColors.deepNile);
            },
            // Show colored fallback on error
            errorBuilder: (_, __, ___) =>
                Container(color: TourGuideColors.deepNile),
          ),

          // ── Gradient overlay ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  TourGuideColors.deepNile.withValues(alpha: 0.70),
                  TourGuideColors.deepNile.withValues(alpha: 0.95),
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
                    child: Icon(
                      locked ? Icons.lock_outline : Icons.chevron_right,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                // Bottom text
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                      locked ? 'Locked for your account' : buttonText,
                      style: TextStyle(
                        color: locked
                            ? Colors.white.withValues(alpha: 0.65)
                            : const Color(0xFFE6A15C),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

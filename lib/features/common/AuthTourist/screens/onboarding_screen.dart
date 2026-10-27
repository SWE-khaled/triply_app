import 'package:flutter/material.dart';
import 'package:triply/features/common/AuthTourist/screens/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> {
  static const Color _primary = Color.fromARGB(255, 8, 64, 76);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _precached = false;

  // Change these paths to your real image names.
  final List<Map<String, String>> _slides = [
    {
      'title': 'Discover Egypt Your Way',
      'subtitle':
          'Explore Egypt, discover amazing places, and create unforgettable memories along the way.',
      'image': 'assets/images/choice_role/onboardingTourist1.jpg',
    },
    {
      'title': 'Find & Book Experiences',
      'subtitle':
          'Discover unique trips, local guides, and experiences made for the way you want to travel.',
      'image': 'assets/images/choice_role/onboardingTourist2.jpg',
    },
    {
      'title': 'Enjoy Your Journey',
      'subtitle':
          'Manage your bookings, connect with guides, explore new places and enjoy every moment of your trip.',
      'image': 'assets/images/choice_role/onboardingTourist3.jpg',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final slide in _slides) {
      final path = slide['image'];
      if (path == null) continue;
      // Precache so the slides feel instant; never let a failure break the screen.
      precacheImage(
        AssetImage(path),
        context,
      ).then((_) {}, onError: (Object _) {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  Widget _buildImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFFEAE8E2),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: _primary, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Header: logo + Skip ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  TextButton(
                    onPressed: _goToSignIn,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Slides: image + text change together ──────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: _buildImage(slide['image']!),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'EXPLORE EGYPT · 0${index + 1} / 0${_slides.length}',
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['title']!,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2D33),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['subtitle']!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7478),
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // ── Bottom: dots + Next / Start ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _primary
                              : const Color(0xFFD5DADC),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (!isLast) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToSignIn();
                      }
                    },
                    child: Text(
                      isLast ? 'Start' : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
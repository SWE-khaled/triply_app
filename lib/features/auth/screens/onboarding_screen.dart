import 'package:flutter/material.dart';
import 'package:triply/core/constants/app_routes.dart';
import '../constants/auth_colors.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.landscape_outlined,
      title: "Discover Egypt's Wonders",
      description:
          'Explore ancient pyramids, hidden temples, and breathtaking landscapes across the land of the pharaohs.',
    ),
    _OnboardingPage(
      icon: Icons.map_outlined,
      title: 'Expert Local Guides',
      description:
          'Travel with verified Egyptians who know every story, every secret passage, and every perfect viewpoint.',
    ),
    _OnboardingPage(
      icon: Icons.event_available_outlined,
      title: 'Book Your Adventure',
      description:
          'Choose private tours or join group trips — seamlessly plan and pay in just a few taps.',
    ),
  ];

  void _goToCreateAccount() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.createAccount);
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _goToCreateAccount();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AuthColors.darkTeal,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _goToCreateAccount,
                  child:
                      const Text('Skip', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  // TODO: replace with the illustration asset from the design
                  return Center(
                    child:
                        Icon(_pages[index].icon, color: Colors.white54, size: 140),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _pages[_currentPage].title,
                    style:
                        const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pages[_currentPage].description,
                    style:
                        const TextStyle(color: AuthColors.textGrey, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: index == _currentPage ? 24 : 8,
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? AuthColors.darkTeal
                                  : AuthColors.fieldBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuthColors.darkTeal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isLastPage ? 'Start' : 'Next',
                                style: const TextStyle(color: Colors.white)),
                            if (!isLastPage) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
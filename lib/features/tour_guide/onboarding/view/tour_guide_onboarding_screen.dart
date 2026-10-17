import 'package:flutter/material.dart';
import '../../../../core/constants/tour_guide_colors.dart';
import '../../../common/AuthTourguide/view/tour_guide_login_screen.dart';

class TourGuideOnboardingScreen extends StatefulWidget {
  const TourGuideOnboardingScreen({super.key});

  @override
  State<TourGuideOnboardingScreen> createState() =>
      _TourGuideOnboardingScreenState();
}

class _TourGuideOnboardingScreenState extends State<TourGuideOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _precached = false;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Share Egypt\nYour Way',
      'subtitle':
          'Turn your knowledge of Egypt into unforgettable\nexperiences for travelers.',
      'image': 'assets/onboarding_images/one1.jpg',
    },
    {
      'title': 'Create\nExperiences',
      'subtitle':
          'Create trips and guide services that travelers can\ndiscover and book.',
      'image': 'assets/onboarding_images/two2.jpg',
      'pills': ['Create Trips', 'Offer Guide Services', 'Promote Experiences'],
    },
    {
      'title': 'Grow Your\nGuide Business',
      'subtitle':
          'Manage bookings, communicate with travelers, host\nyour trips and track your earnings — all in one place.',
      'image': 'assets/onboarding_images/three3.jpg',
      'pills': ['Bookings', 'Messages', 'Trips', 'Earnings'],
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final slide in _slides) {
      final path = slide['image'] as String?;
      if (path != null) precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) => Container(
        color: TourGuideColors.deepNile,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.white54, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TourGuideColors.deepNile,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  if (slide['image'] != null)
                    _buildImage(slide['image'] as String),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          TourGuideColors.deepNile.withValues(alpha: 0.65),
                          TourGuideColors.deepNile.withValues(alpha: 0.97),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '0${index + 1} / 0${_slides.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide['title'] as String,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (slide['pills'] != null)
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: (slide['pills'] as List<String>)
                                .map((pill) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Text(
                                        pill,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Back Button
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 8),
                      height: 6,
                      width: _currentPage == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFE6A15C)
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                // Next / Get Started Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: TourGuideColors.deepNile,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TourGuideLoginScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
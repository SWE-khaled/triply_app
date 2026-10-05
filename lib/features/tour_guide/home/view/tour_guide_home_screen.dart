import 'package:flutter/material.dart';
import '../../../../core/constants/tour_guide_colors.dart';

class TourGuideHomeScreen extends StatefulWidget {
  const TourGuideHomeScreen({super.key});

  @override
  State<TourGuideHomeScreen> createState() => _TourGuideHomeScreenState();
}

class _TourGuideHomeScreenState extends State<TourGuideHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TourGuideColors.softSand,
      appBar: AppBar(
        backgroundColor: TourGuideColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Overview',
          style: TextStyle(color: TourGuideColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: TourGuideColors.textPrimary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions, color: Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Identity Verification Pending', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        SizedBox(height: 4),
                        Text('You can\'t publish experiences until verified.', style: TextStyle(color: Color(0xFF92400E), fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Check Status', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TourGuideColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Earnings', style: TextStyle(color: TourGuideColors.textSecondary, fontSize: 14)),
                        SizedBox(height: 8),
                        Text('\$0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TourGuideColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TourGuideColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active Bookings', style: TextStyle(color: TourGuideColors.textSecondary, fontSize: 14)),
                        SizedBox(height: 8),
                        Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TourGuideColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Your Experiences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TourGuideColors.textPrimary)),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Icon(Icons.explore_outlined, size: 64, color: TourGuideColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No experiences yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TourGuideColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Create your first trip or guide service to start earning.', textAlign: TextAlign.center, style: TextStyle(color: TourGuideColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TourGuideColors.deepNile,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Create Experience', style: TextStyle(color: TourGuideColors.pureWhite, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TourGuideColors.deepNile,
        unselectedItemColor: TourGuideColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

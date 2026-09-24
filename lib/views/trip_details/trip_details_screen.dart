import 'package:flutter/material.dart';
import '../../controllers/trip_details_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import 'widgets/booking_bar.dart';
import 'widgets/details_header.dart';
import 'widgets/details_info.dart';
import 'widgets/details_tab_content.dart';
import 'widgets/details_tabs.dart';
import 'widgets/guide_card.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TripDetailsController controller = TripDetailsController();
  late final TripDetails details;
  int selectedTab = 0;
  bool isFavorite = false;

  static const List<String> tabs = ['About', 'Highlights', 'Itinerary', 'Notes'];

  @override
  void initState() {
    super.initState();
    details = controller.getByTripId(widget.trip.id, title: widget.trip.title);
  }

  void _placeholder(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            DetailsHeader(
              imageUrl: details.imageUrl,
              isFavorite: isFavorite,
              onBack: () => Navigator.of(context).pop(),
              onFavorite: () =>
                  setState(() => isFavorite = !isFavorite),
              onShare: () =>
                  _placeholder('Share not available yet'),
            ),
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailsInfo(details: details),
                    const SizedBox(height: 14),
                    DetailsTabs(
                      tabs: tabs,
                      selectedIndex: selectedTab,
                      onSelected: (i) =>
                          setState(() => selectedTab = i),
                    ),
                    const SizedBox(height: 14),
                    DetailsTabContent(
                      details: details,
                      selectedTab: selectedTab,
                    ),
                    const SizedBox(height: 16),
                    BookingBar(
                      details: details,
                      onBookNow: () => _placeholder(
                          'Booking not available yet'),
                    ),
                    const SizedBox(height: 14),
                    GuideCard(
                      details: details,
                      onTap: () => _placeholder(
                          'Guide profile not available yet'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

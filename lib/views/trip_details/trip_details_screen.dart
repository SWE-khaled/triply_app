import 'package:flutter/material.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/trip_details_controller.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/constants/app_colors.dart';
import '../../models/trip.dart';
import '../../models/trip_details.dart';
import '../booking/booking_screen.dart';
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

  static const List<String> tabs = [
    'About',
    'Highlights',
    'Itinerary',
    'Notes',
  ];

  @override
  void initState() {
    super.initState();
    details = controller.getByTripId(
      widget.trip.id,
      title: widget.trip.title,
      imageUrl: widget.trip.imageUrl,
      priceEgp: widget.trip.priceEgp,
      guideName: widget.trip.guideName,
    );
    // Restore persisted state so reopening this trip shows the heart active.
    isFavorite = FavoritesController.isFavorite(widget.trip.id);
  }

  void _onFavorite() {
    final nowFavorite = FavoritesController.toggle(widget.trip.id);
    setState(() => isFavorite = nowFavorite);
    showAppSnackBar(
      context,
      nowFavorite ? 'Added to favourites' : 'Removed from favourites',
      icon: nowFavorite ? Icons.favorite : Icons.heart_broken_outlined,
    );
  }

  void _placeholder(String msg) {
    showAppSnackBar(context, msg, icon: Icons.info_outline);
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
              onFavorite: _onFavorite,
              onShare: () => _placeholder('Share not available yet'),
            ),
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailsInfo(details: details),
                    const SizedBox(height: 18),
                    DetailsTabs(
                      tabs: tabs,
                      selectedIndex: selectedTab,
                      onSelected: (i) => setState(() => selectedTab = i),
                    ),
                    const SizedBox(height: 14),
                    DetailsTabContent(
                      details: details,
                      selectedTab: selectedTab,
                    ),
                    const SizedBox(height: 16),
                    BookingBar(
                      details: details,
                      onBookNow: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(trip: widget.trip),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GuideCard(
                      details: details,
                      onTap: () =>
                          _placeholder('Guide profile not available yet'),
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

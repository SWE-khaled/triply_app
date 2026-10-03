import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../cubit/guide_trip_details_cubit.dart';
import '../cubit/guide_trip_details_state.dart';
import '../../my_trips/model/guide_trip.dart';
import '../widgets/guide_details_info.dart';
import '../widgets/guide_details_tab_content.dart';

/// Guide-side trip details (opened from guide list View).
/// Self-provides its cubit. Edit Trip / View Travelers have no
/// destination screens in Figma yet → placeholder toasts.
class GuideTripDetailsScreen extends StatelessWidget {
  final GuideTrip trip;

  const GuideTripDetailsScreen({super.key, required this.trip});

  static const List<String> tabs = [
    'About',
    'Highlights',
    'Itinerary',
    'Notes',
  ];

  void _todo(BuildContext context, String what) {
    showAppSnackBar(
      context,
      '$what is not available yet',
      icon: Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideTripDetailsCubit()..loadTrip(trip),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          body: BlocBuilder<GuideTripDetailsCubit, GuideTripDetailsState>(
            builder: (context, state) {
              final details = state.details;
              if (details == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            CircleBackButton(
                              icon: Icons.chevron_left,
                              iconColor: AppColors.titleDark,
                              backgroundColor: const Color(0xFFF6F1E7),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Trip Details',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.priceTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Image.network(
                        details.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFE6ECEF),
                          child: const Icon(
                            Icons.image,
                            color: AppColors.subtitle,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      transform: Matrix4.translationValues(0, -24, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GuideDetailsInfo(details: details),
                            const SizedBox(height: 14),
                            Row(
                              children: List.generate(tabs.length, (i) {
                                final selected = i == state.selectedTab;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => context
                                        .read<GuideTripDetailsCubit>()
                                        .selectTab(i),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.tabSelectedBg
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        tabs[i],
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : AppColors.subtitle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 14),
                            GuideDetailsTabContent(
                              details: details,
                              selectedTab: state.selectedTab,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF6EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What's Included",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.title,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    details.included,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColors.dateText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors.starGold,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Meeting Point',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppColors.subtitle,
                                        ),
                                      ),
                                      Text(
                                        details.meetingPoint,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.titleDetails,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'EGP ${formatEgp(details.priceEgp)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.priceTeal,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / person',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.subtitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .push(
                                        AppRoutes.editTrip(
                                          trip: trip,
                                          details: details,
                                        ),
                                      )
                                      .then((saved) {
                                        // Reload so saved edits show immediately.
                                        if (saved == true && context.mounted) {
                                          context
                                              .read<GuideTripDetailsCubit>()
                                              .loadTrip(trip);
                                        }
                                      }),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentOrange,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      'Edit Trip',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () => _todo(context, 'Traveler list'),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: Image.network(
                                        details.guideAvatarUrl,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 44,
                                          height: 44,
                                          color: const Color(0xFFE6ECEF),
                                          child: const Icon(
                                            Icons.person,
                                            color: AppColors.subtitle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            details.guideName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.title,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 12,
                                                color: AppColors.starGold,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${details.guideRating} (${details.guideReviews})',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors.subtitle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'TOP RATED GUIDE',
                                      style: GoogleFonts.poppins(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.starGold,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).push(AppRoutes.travelers(trip)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tabSelectedBg,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  textStyle: AppTextStyles.button(),
                                ),
                                child: const Text('View Travelers'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

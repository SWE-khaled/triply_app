import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/trip_image.dart';
import '../../../common/AuthTourist/cubit/auth_cubit.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../cubit/guide_trip_details_cubit.dart';
import '../model/guide_trip_details.dart';
import '../widgets/guide_details_info.dart';
import '../widgets/guide_details_tab_content.dart';

/// Guide-side trip details (opened from guide list View).
/// Self-provides its cubit. Edit Trip / View Travelers have no
/// destination screens in Figma yet - placeholder toasts.
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

  /// Opens the profile of the guide who published the trip — on the
  /// guide's own screen that is their own profile.
  void _openGuideProfile(BuildContext context) {
    final uid = context.read<AuthCubit>().user?.uid;
    if (uid == null) {
      _todo(context, 'The guide profile');
      return;
    }
    Navigator.of(context).push(AppRoutes.guideProfile(uid));
  }

  /// The badge under the guide's name: "Top rated" only once the guide
  /// actually has the reviews to back it up.
  String _guideBadge(GuideTripDetails details) {
    final isTopRated = details.guideRating >= 4.5 && details.guideReviews > 0;
    return isTopRated ? 'TOP RATED GUIDE' : 'VERIFIED GUIDE';
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
              return switch (state) {
                GuideTripDetailsSuccess(:final details, :final selectedTab) =>
                  SingleChildScrollView(
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
                          child: TripImage(
                            imageUrl: details.imageUrl,
                            fallbackIconSize: 40,
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
                                    final selected = i == selectedTab;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => context
                                            .read<GuideTripDetailsCubit>()
                                            .selectTab(i),
                                        behavior: HitTestBehavior.opaque,
                                        // The labels are spread over the row,
                                        // but the selected pill hugs its own
                                        // label instead of filling a slot.
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.tabSelectedBg
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 14),
                                GuideDetailsTabContent(
                                  details: details,
                                  selectedTab: selectedTab,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF6EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            if (saved == true &&
                                                context.mounted) {
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                                  onTap: () => _openGuideProfile(context),
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
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: const Color(
                                                    0xFFE6ECEF,
                                                  ),
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
                                          _guideBadge(details),
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
                  ),
                GuideTripDetailsInitial() ||
                GuideTripDetailsLoading() => const AppLoadingView(),
                GuideTripDetailsError(:final error) => AppErrorView(
                  message: error,
                  onRetry: () =>
                      context.read<GuideTripDetailsCubit>().loadTrip(trip),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

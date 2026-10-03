import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/guide_profile_cubit.dart';
import '../cubit/guide_profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu.dart';
import '../../my_trips/widgets/guide_bottom_nav.dart';

/// Guide profile. Self-provides its cubit. Menu rows, cover edit and
/// log out have no destination screens in Figma → placeholder toasts.
class GuideProfileScreen extends StatefulWidget {
  const GuideProfileScreen({super.key});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  int bottomIndex = 2; // Profile

  void _todo(String what) {
    showAppSnackBar(
      context,
      '$what is not available yet',
      icon: Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideProfileCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          body: BlocBuilder<GuideProfileCubit, GuideProfileState>(
            builder: (context, state) {
              final profile = state.profile;
              if (profile == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      profile: profile,
                      onEditCover: () => _todo('Editing cover photo'),
                    ),
                    Container(
                      width: double.infinity,
                      transform: Matrix4.translationValues(0, -20, 0),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _stat('${profile.reviewsCount}', 'Reviews'),
                          _divider(),
                          _stat('${profile.languagesCount}', 'Languages'),
                          _divider(),
                          _stat(
                            'EGP ${profile.pricePerHour.toInt()}',
                            'Price/hr',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: profile.languages
                                .map(
                                  (l) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBF6EC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      l,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.subtitle,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'About',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.about,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.dateText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ProfileMenu(
                            icon: Icons.calendar_today_outlined,
                            label: 'Availability',
                            onTap: () => _todo('Availability'),
                          ),
                          ProfileMenu(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () => _todo('Notifications'),
                          ),
                          ProfileMenu(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Payment & Earnings',
                            onTap: () => _todo('Payment & Earnings'),
                          ),
                          ProfileMenu(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () => _todo('Settings'),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () =>
                                  _todo('Logging out & switching role'),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.accentOrange,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Log Out & Switch Role',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: GuideBottomNav(
            currentIndex: bottomIndex,
            onTap: (i) {
              if (i == bottomIndex) return;
              if (i == 1) {
                // Back to the guide trips list.
                Navigator.of(context).pop();
                return;
              }
              // TODO: navigate when guide Home exists.
              _todo('This section');
            },
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.titleDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.cardBorder);
  }
}

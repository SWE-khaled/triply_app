import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Languages + About + menu rows + log out button.
class ProfileMenuSection extends StatelessWidget {
  final List<String> languages;
  final String about;
  final VoidCallback? onAvailability;
  final VoidCallback? onNotifications;
  final VoidCallback? onEarnings;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const ProfileMenuSection({
    super.key,
    required this.languages,
    required this.about,
    this.onAvailability,
    this.onNotifications,
    this.onEarnings,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: languages
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
            about,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: AppColors.dateText,
            ),
          ),
          const SizedBox(height: 8),
          _MenuRow(
            icon: Icons.calendar_today_outlined,
            label: 'Availability',
            onTap: onAvailability,
          ),
          _MenuRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onNotifications,
          ),
          _MenuRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payment & Earnings',
            onTap: onEarnings,
          ),
          _MenuRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onSettings,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onLogout,
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentOrange),
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
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F1E7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.priceTeal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.priceTeal,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

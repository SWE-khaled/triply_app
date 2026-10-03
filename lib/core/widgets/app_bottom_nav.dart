import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Navigation item data
class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

const List<_NavItem> _navItems = [
  _NavItem('Overview', Icons.grid_view_rounded),
  _NavItem('Trips', Icons.luggage_outlined),
  _NavItem('Users', Icons.people_outline),
  _NavItem('Bookings', Icons.bookmark_border),
  _NavItem('User Posts', Icons.article_outlined),
  _NavItem('Guides', Icons.verified_user_outlined),
  _NavItem('Trip Applications', Icons.assignment_outlined),
  _NavItem('App Settings', Icons.settings_outlined),
];

/// The left sidebar of the Triply Admin Console.
/// [selectedIndex] drives which item is highlighted.
/// [onItemSelected] fires whenever a nav item is tapped.
class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Triply', style: AppTextStyles.logoTitle),
                const SizedBox(height: 2),
                Text('ADMIN CONSOLE', style: AppTextStyles.logoSubtitle),
              ],
            ),
          ),

          // ── Nav items ─────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _navItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final isActive = selectedIndex == i;
                  return _NavTile(
                    label: item.label,
                    icon: item.icon,
                    isActive: isActive,
                    onTap: () => onItemSelected(i),
                  );
                },
              ),
            ),
          ),

          // ── Bottom: admin profile + log out ───────────
          _SidebarFooter(onLogout: onLogout),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : AppColors.sidebarInactiveText,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: isActive
                  ? AppTextStyles.navItemActive
                  : AppTextStyles.navItemInactive,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final VoidCallback? onLogout;
  const _SidebarFooter({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amr Khaled', style: AppTextStyles.sidebarUserName),
                  Text('Super Admin', style: AppTextStyles.sidebarUserRole),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onLogout,
            child: Text('Log out', style: AppTextStyles.logoutText),
          ),
        ],
      ),
    );
  }
}

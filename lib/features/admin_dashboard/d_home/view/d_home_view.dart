import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_app_bottom_nav.dart';
import '../../d_overview/view/d_overview_view.dart';
import '../../d_trips/view/d_trips_view.dart';
import '../../d_users/view/d_users_view.dart';
import '../../d_bookings/view/d_bookings_view.dart';
import '../../d_user_posts/view/d_user_posts_view.dart';
import '../../d_guides/view/d_guides_view.dart';
import '../../d_trip_applications/view/d_trip_applications_view.dart';
import '../../d_app_settings/view/d_app_settings_view.dart';
// ignore_for_file: unused_import

/// Root admin shell — sidebar + indexed page body.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const List<_PageMeta> _pages = [
    _PageMeta('Overview', 'Welcome back, Amr Khaled'),
    _PageMeta('Trips', 'Welcome back, Amr Khaled'),
    _PageMeta('Users', 'Welcome back, Amr Khaled'),
    _PageMeta('Bookings', 'Welcome back, Amr Khaled'),
    _PageMeta('User Posts', 'Welcome back, Amr Khaled'),
    _PageMeta('Guides', 'Welcome back, Amr Khaled'),
    _PageMeta('Trip Applications', 'Welcome back, Amr Khaled'),
    _PageMeta('App Settings', 'Welcome back, Amr Khaled'),
  ];

  static const List<Widget> _bodies = [
    OverviewView(),
    TripsView(),
    UsersView(),
    BookingsView(),
    UserPostsView(),
    GuidesView(),
    TripApplicationsView(),
    AppSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final meta = _pages[_selectedIndex];
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // ── Desktop layout: permanent sidebar on the left ────────────────────
    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (i) => setState(() => _selectedIndex = i),
              onLogout: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(
                    title: meta.title,
                    subtitle: meta.subtitle,
                    isDesktop: true,
                  ),
                  Expanded(child: _bodies[_selectedIndex]),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile layout: hamburger menu + Drawer ────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        width: 240,
        child: AdminSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (i) {
            setState(() => _selectedIndex = i);
            Navigator.of(context).pop(); // close drawer
          },
          onLogout: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out')),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            title: meta.title,
            subtitle: meta.subtitle,
            isDesktop: false,
          ),
          Expanded(child: _bodies[_selectedIndex]),
        ],
      ),
    );
  }
}

class _PageMeta {
  final String title;
  final String subtitle;
  const _PageMeta(this.title, this.subtitle);
}

/// Top header bar shown on every admin page.
class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDesktop;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = isDesktop ? 32.0 : 16.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
      child: Row(
        children: [
          // Hamburger on mobile
          if (!isDesktop) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.pageTitle.copyWith(
                    fontSize: isDesktop ? 28 : 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.pageSubtitle),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Admin badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  Text('Super Admin', style: AppTextStyles.adminBadgeText),
                ],
              ],
            ),
          ),

        ],
      ),
    );
  }
}

/// Reusable white admin content card.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdminCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding ?? const EdgeInsets.all(24),
      child: child,
    );
  }
}

/// Standard section header inside a card:  title + subtitle (left) + action widget (right).
class CardSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const CardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: AppTextStyles.sectionSubtitle),
              ],
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

/// "+Add New" primary button used on most screens.
class AddNewButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AddNewButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('+ Add New', style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}

/// Search bar + Filter button row used on multiple screens.
class SearchFilterRow extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;

  const SearchFilterRow({
    super.key,
    required this.hintText,
    this.controller,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.tableCell,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Filter', style: AppTextStyles.buttonOutline),
          ),
        ),
      ],
    );
  }
}

/// Reusable table column header row builder.
Widget buildTableHeader(List<Map<String, dynamic>> columns) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: columns
          .map(
            (col) => Expanded(
              flex: col['flex'] as int? ?? 1,
              child: Text(
                col['label'] as String,
                style: AppTextStyles.tableHeader,
                textAlign: col['align'] as TextAlign? ?? TextAlign.start,
              ),
            ),
          )
          .toList(),
    ),
  );
}

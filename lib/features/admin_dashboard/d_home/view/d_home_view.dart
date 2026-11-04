import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/features/tour_guide/role_selection/view/role_selection_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_app_bottom_nav.dart';
import '../../d_auth/cubit/admin_auth_cubit.dart';
import '../../d_overview/view/d_overview_view.dart';
import '../../d_trips/view/d_trips_view.dart';
import '../../d_users/view/d_users_view.dart';
import '../../d_bookings/view/d_bookings_view.dart';
import '../../d_user_posts/view/d_user_posts_view.dart';
import '../../d_guides/view/d_guides_view.dart';
import '../../d_trip_applications/view/d_trip_applications_view.dart';
import '../../d_app_settings/view/d_app_settings_view.dart';

// ignore_for_file: unused_import

/// Root admin shell â€” sidebar + indexed page body.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Overview',
    'Trips',
    'Users',
    'Bookings',
    'User Posts',
    'Guides',
    'Trip Applications',
    'App Settings',
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AdminAuthCubit>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminName = context.watch<AdminAuthCubit>().session?.name ?? 'Admin';
    final meta = _PageMeta(_titles[_selectedIndex], 'Welcome back, $adminName');
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Desktop layout: permanent sidebar on the left.
    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.adminBackground,
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (i) => setState(() => _selectedIndex = i),
              adminName: adminName,
              onLogout: () => _confirmLogout(context),
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

    // Mobile layout: hamburger menu + Drawer.
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      drawer: Drawer(
        width: 240,
        child: AdminSidebar(
          selectedIndex: _selectedIndex,
          adminName: adminName,
          onItemSelected: (i) {
            setState(() => _selectedIndex = i);
            Navigator.of(context).pop(); // close drawer
          },
          onLogout: () {
            Navigator.of(context).pop();
            _confirmLogout(context);
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
                icon: const Icon(Icons.menu, color: AppColors.adminPrimary),
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
                  style: AppTextStyles.adminPageTitle.copyWith(
                    fontSize: isDesktop ? 28 : 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.adminPageSubtitle),
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
                    color: AppColors.adminPrimary,
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
    final narrow = MediaQuery.of(context).size.width < 800;
    return Container(
      margin: EdgeInsets.fromLTRB(narrow ? 16 : 32, 0, narrow ? 16 : 32, 32),
      decoration: BoxDecoration(
        color: AppColors.adminCardBg,
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
              Text(title, style: AppTextStyles.adminSectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: AppTextStyles.adminSectionSubtitle),
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
          color: AppColors.adminPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('+ Add New', style: AppTextStyles.adminButtonPrimary),
      ),
    );
  }
}

/// Search bar without filter button used on multiple screens.
class SearchFilterRow extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  const SearchFilterRow({
    super.key,
    required this.hintText,
    this.controller,
    this.onFilterTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.adminTableCell,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.adminTextMuted,
        ),
      ),
    );
  }
}

/// Keeps a dense admin table readable on narrow windows.
///
/// Admin tables use fixed-width action buttons (View / Reject / Approve ...).
/// When the window gets narrow those buttons do not fit in their columns and
/// the row throws a RenderFlex overflow, so below [minWidth] the header and
/// the rows scroll horizontally together instead.
class AdminTableArea extends StatefulWidget {
  /// The narrowest width the table is laid out at before it starts scrolling.
  final double minWidth;

  final Widget child;

  const AdminTableArea({
    super.key,
    required this.minWidth,
    required this.child,
  });

  @override
  State<AdminTableArea> createState() => _AdminTableAreaState();
}

class _AdminTableAreaState extends State<AdminTableArea> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= widget.minWidth) return widget.child;
        return Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: widget.minWidth, child: widget.child),
          ),
        );
      },
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
                style: AppTextStyles.adminTableHeader,
                textAlign: col['align'] as TextAlign? ?? TextAlign.start,
              ),
            ),
          )
          .toList(),
    ),
  );
}


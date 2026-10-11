import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../cubit/trips_cubit.dart';
import '../cubit/trips_state.dart';
import '../models/trip.dart';
import '../widgets/empty_trips.dart';
import '../widgets/trip_card.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int bottomIndex = 1; // Trips
  bool _remoteRequested = false;

  static const List<String> tabLabels = ['Upcoming', 'Completed'];

  static const List<TripStatus> tabValues = [
    TripStatus.upcoming,
    TripStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    // Remote reads stay OFF until backend deploy + emulator proof
    // ([TripsCubit.useRemote]); mocks render meanwhile with no extra UI.
    if (TripsCubit.useRemote) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRemote());
    }
  }

  /// Best-effort remote refresh. Guarded so rebuilds never duplicate it;
  /// only explicit navigation/tab taps trigger a request. On failure the
  /// mock list stays with an explicit offline notice (never presented as
  /// live data).
  Future<void> _refreshRemote() async {
    if (!mounted || _remoteRequested) return;
    _remoteRequested = true;
    try {
      final ok = await context.read<TripsCubit>().loadRemote();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't refresh trips — showing sample trips."),
          ),
        );
      }
    } finally {
      _remoteRequested = false;
    }
  }

  void _openDetails(Trip trip) {
    Navigator.of(context).push(AppRoutes.tripDetails(trip));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
              child: Row(
                children: [
                  const CircleBackButton(),
                  const SizedBox(width: 12),
                  Text('Trips', style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Text(
                'Your Egypt journey, tracked',
                style: AppTextStyles.screenSubtitle,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.tabUnselectedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BlocBuilder<TripsCubit, TripsState>(
                  builder: (context, state) {
                    return Row(
                      children: List.generate(tabValues.length, (i) {
                        final selected = tabValues[i] == state.selectedTab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.read<TripsCubit>().selectTab(
                                tabValues[i],
                              );
                              if (TripsCubit.useRemote) _refreshRemote();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.tabSelectedBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tabLabels[i],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.background
                                      : AppColors.subtitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<TripsCubit, TripsState>(
                builder: (context, state) {
                  final trips = state.trips;
                  if (trips.isEmpty) {
                    return EmptyTrips(
                      tabName: tabLabels[tabValues.indexOf(state.selectedTab)],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: trips.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return TripCard(
                        trip: trip,
                        onTap: () => _openDetails(trip),
                        onViewDetails: () => _openDetails(trip),
                        // Chat: placeholder — no chat screen exists yet.
                        onChat: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

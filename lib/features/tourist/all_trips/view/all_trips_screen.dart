import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../popular/cubit/popular_cubit.dart';
import '../../popular/view/popular_trips_screen.dart';

/// The full catalogue of approved trips.
///
/// The Popular Trips section on Home only shows a short preview; this screen
/// opens the same trip list without the preview limit. It reuses the
/// popular-trips layout and card, and starts on the "All" category so a
/// filter left over from a previous visit never hides available trips.
class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  @override
  void initState() {
    super.initState();
    // Only reset once the trips are loaded: during the first read the
    // cubit is already loading every trip.
    final cubit = context.read<PopularCubit>();
    final current = cubit.state;
    if (current is PopularSuccess && current.selectedCategory != 'All') {
      cubit.selectCategory('All');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const PopularTripsScreen(title: 'All Trips');
  }
}

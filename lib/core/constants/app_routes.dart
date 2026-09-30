import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/trip_details/model/trip_details.dart';
import '../../features/trips/cubit/trips_cubit.dart';
import '../../features/trips/models/trip.dart';
import '../../features/trips/view/trips_screen.dart';
import '../../features/trip_details/cubit/trip_details_cubit.dart';
import '../../features/trip_details/view/trip_details_screen.dart';
import '../../features/booking/cubit/booking_cubit.dart';
import '../../features/booking/view/booking_screen.dart';
import '../../features/booking/view/booking_confirmed_screen.dart';
import '../../features/my_trips/cubit/my_trips_cubit.dart';
import '../../features/my_trips/view/my_trips_screen.dart';
import '../../features/popular/cubit/popular_cubit.dart';
import '../../features/popular/view/popular_trips_screen.dart';

/// Single route table. Views navigate via these builders —
/// never inline MaterialPageRoute (fixes competing main.dart edits).
class AppRoutes {
  AppRoutes._();

  static Route<void> trips() {
    return MaterialPageRoute(
      builder: (_) =>
          BlocProvider(create: (_) => TripsCubit(), child: const TripsScreen()),
    );
  }

  static Route<void> popular() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => PopularCubit(),
        child: const PopularTripsScreen(),
      ),
    );
  }

  static Route<void> tripDetails(Trip trip, {bool isBooked = false}) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => TripDetailsCubit()..loadTrip(trip),
        child: TripDetailsScreen(trip: trip, isBooked: isBooked),
      ),
    );
  }

  static Route<void> booking(Trip trip) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BookingCubit(),
        child: BookingScreen(trip: trip),
      ),
    );
  }

  static Route<void> myTrips() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => MyTripsCubit(),
        child: const MyTripsScreen(),
      ),
    );
  }

  /// Post-booking destination: always lands on My Trips, where the
  /// fresh cubit reads the booking store — the booked trip is visible.
  static void goToMyTrips(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(myTrips());
  }

  static Route<void> bookingConfirmed({
    required Trip trip,
    required TripDetails details,
    required int seats,
    required double total,
  }) {
    return MaterialPageRoute(
      builder: (_) => BookingConfirmedScreen(
        trip: trip,
        details: details,
        seats: seats,
        total: total,
      ),
    );
  }

  /// Deterministic "Back to Trip": always lands on THIS trip's details,
  /// no matter how the user arrived at confirmation.
  static void backToTrip(BuildContext context, Trip trip) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(tripDetails(trip));
  }
}

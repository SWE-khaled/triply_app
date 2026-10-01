import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/booking_public/cubit/booking_public_cubit.dart';
import '../../features/booking_public/view/booking_confirmed_screen.dart';
import '../../features/booking_public/view/booking_public_screen.dart';
import '../../features/trip_details/model/trip_details.dart';
import '../../features/trips/cubit/trips_cubit.dart';
import '../../features/trips/models/trip.dart';
import '../../features/trips/view/trips_screen.dart';
import '../../features/trip_details/cubit/trip_details_cubit.dart';
import '../../features/trip_details/view/trip_details_screen.dart';
import '../../features/my_trips/cubit/my_trips_cubit.dart';
import '../../features/my_trips/view/my_trips_screen.dart';
import '../../features/popular/cubit/popular_cubit.dart';
import '../../features/popular/view/popular_trips_screen.dart';

/// Single route table: named routes (String constants) + route builders.
/// Views navigate via these builders, never inline MaterialPageRoute.
class AppRoutes {
  AppRoutes._();

  // ---- Named routes ----
  static const String home = '/home';
  // static const String map = '/map';
  // static const String community = '/community';
  // static const String trip = '/trip';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String passwordResetSuccess = '/password-reset-success';
  static const String profile = '/profile';
  static const String privacySecurity = '/privacy-security';
  static const String emergency = '/emergency';

  // ---- Route builders ----
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
        create: (_) => BookingPublicCubit(),
        child: BookingPublicScreen(trip: trip),
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

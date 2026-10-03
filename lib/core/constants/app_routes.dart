import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/tourist/booking_public/cubit/booking_public_cubit.dart';
import '../../features/tourist/booking_public/view/booking_confirmed_screen.dart';
import '../../features/tourist/booking_public/view/booking_public_screen.dart';
import '../../features/tourist/trip_details/model/trip_details.dart';
import '../../features/tourist/trips/cubit/trips_cubit.dart';
import '../../features/tourist/trips/models/trip.dart';
import '../../features/tourist/trips/view/trips_screen.dart';
import '../../features/tourist/trip_details/cubit/trip_details_cubit.dart';
import '../../features/tourist/trip_details/view/trip_details_screen.dart';
import '../../features/tourist/my_trips/cubit/my_trips_cubit.dart';
import '../../features/tourist/my_trips/view/my_trips_screen.dart';
import '../../features/tourist/popular/cubit/popular_cubit.dart';
import '../../features/tourist/popular/view/popular_trips_screen.dart';
import '../../features/tour_guide/my_trips/view/guide_trips_screen.dart';
import '../../features/tour_guide/create_trip/view/create_trip_screen.dart';
import '../../features/tour_guide/trip_details/model/guide_trip_details.dart';
import '../../features/tour_guide/profile/view/profile_screen.dart';
import '../../features/tour_guide/trip_details/view/guide_trip_details_screen.dart';
import '../../features/tour_guide/my_trips/model/guide_trip.dart';
import '../../features/tour_guide/travelers/view/travelers_screen.dart';

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

  static Route<void> guideTrips() {
    // Screen self-provides its cubit; route adds no provider.
    return MaterialPageRoute(builder: (_) => const GuideTripsScreen());
  }

  static Route<void> guideTripDetails(GuideTrip trip) {
    // Screen self-provides its cubit; route adds no provider.
    return MaterialPageRoute(
      builder: (_) => GuideTripDetailsScreen(trip: trip),
    );
  }

  static Route<void> travelers(GuideTrip trip) {
    // Screen self-provides its cubit; route adds no provider.
    return MaterialPageRoute(builder: (_) => TravelersScreen(trip: trip));
  }

  static Route<void> guideProfile() {
    return MaterialPageRoute(builder: (_) => const GuideProfileScreen());
  }

  static Route<bool?> createTrip() {
    // Screen self-provides its cubit.
    return MaterialPageRoute<bool?>(builder: (_) => const CreateTripScreen());
  }

  static Route<bool?> editTrip({
    required GuideTrip trip,
    required GuideTripDetails details,
  }) {
    // Same form in edit mode (pre-filled); saves persist for the session.
    return MaterialPageRoute<bool?>(
      builder: (_) => CreateTripScreen(
        initialDetails: details,
        initialTrip: trip,
        formTitle: 'Edit Trip',
        submitLabel: 'Save Changes',
      ),
    );
  }

  static Route<bool?> manageTrip({
    required GuideTrip trip,
    required GuideTripDetails details,
  }) {
    // Same form as edit (Figma-identical); saves persist for the session.
    return MaterialPageRoute<bool?>(
      builder: (_) => CreateTripScreen(
        initialDetails: details,
        initialTrip: trip,
        formTitle: 'Manage Trip',
        submitLabel: 'Save Changes',
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

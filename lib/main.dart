import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/trips/cubit/trips_cubit.dart';
import 'features/trips/view/trips_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triply',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home:
      //todo
      // BlocProvider(
      //   create: (_) => PopularCubit(),
      //   child: const PopularTripsScreen(),
      // ),
      BlocProvider(
        create: (_) => TripsCubit(),
        child: const TripsScreen(),
      ),
    );
  }
}

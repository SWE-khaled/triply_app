import 'package:flutter/material.dart';

import '../../../../core/widgets/app_header.dart';
import '../widget/location_category_chip.dart';
import '../widget/location_place_row.dart';

/// Category used to group Egypt locations in the picker.
enum LocationCategory { historical, nature, activities, food }

extension LocationCategoryX on LocationCategory {
  String get label {
    switch (this) {
      case LocationCategory.historical:
        return 'Historical';
      case LocationCategory.nature:
        return 'Nature';
      case LocationCategory.activities:
        return 'Activities';
      case LocationCategory.food:
        return 'Food';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationCategory.historical:
        return Icons.account_balance_outlined;
      case LocationCategory.nature:
        return Icons.landscape_outlined;
      case LocationCategory.activities:
        return Icons.hiking_outlined;
      case LocationCategory.food:
        return Icons.restaurant_outlined;
    }
  }
}

/// Static data source for Egypt locations, grouped by category.
/// Replace/extend this map with real data or an API later.
const Map<LocationCategory, List<String>> egyptLocations = {
  LocationCategory.historical: [
    'Pyramids of Giza',
    'Khan El Khalili',
    'Karnak Temple',
    'Citadel of Qaitbay',
    'Valley of the Kings',
    'Abu Simbel Temples',
  ],
  LocationCategory.nature: [
    'Siwa Oasis',
    'Red Sea Coast',
    'White Desert',
    'Nile River',
    'Ras Mohammed National Park',
  ],
  LocationCategory.activities: [
    'Hurghada Diving',
    'Desert Safari',
    'Camel Riding, Giza',
    'Nile Felucca Ride',
    'Hot Air Balloon, Luxor',
  ],
  LocationCategory.food: [
    'Alexandria Seafood',
    'Cairo Street Food',
    'Nile-view Restaurants',
    'Khan El Khalili Food Market',
  ],
};

/// Screen that lets the user pick one location, grouped by category.
/// Pops with the selected location string, or null if cancelled.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LocationCategory selectedCategory = LocationCategory.historical;

  @override
  Widget build(BuildContext context) {
    final places = egyptLocations[selectedCategory] ?? const [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: AppHeader(
                title: 'Add Location',
                onBack: () => Navigator.of(context).pop(),
              ),
            ),

            // Category chips row.
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: LocationCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = LocationCategory.values[index];
                  final selected = category == selectedCategory;
                  return LocationCategoryChip(
                    label: category.label,
                    icon: category.icon,
                    selected: selected,
                    onTap: () => setState(() => selectedCategory = category),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Places list for the selected category.
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return LocationPlaceRow(
                    place: place,
                    onTap: () => Navigator.of(context).pop(place),
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

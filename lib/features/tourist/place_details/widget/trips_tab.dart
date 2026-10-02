import 'package:flutter/material.dart';

import '../model/trip.dart';
import 'trip_card.dart';

class TripsTab extends StatelessWidget {
  final List<Trip> trips;
  final void Function(Trip trip)? onViewDetails;
  final void Function(Trip trip)? onChat;

  const TripsTab({
    super.key,
    required this.trips,
    this.onViewDetails,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: trips
          .map(
            (t) => TripCard(
              trip: t,
              onViewDetails:
                  onViewDetails == null ? null : () => onViewDetails!(t),
              onChat: onChat == null ? null : () => onChat!(t),
            ),
          )
          .toList(),
    );
  }
}

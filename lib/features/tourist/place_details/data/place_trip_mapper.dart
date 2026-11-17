import 'package:triply/core/data/mock/tourist/mock_place_trips.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/models/public_trip.dart';

import '../../map/model/place.dart';
import '../../trips/models/trip.dart' as trips_model;
import '../model/trip.dart';

/// Maps public trips to the cards the place screen shows and back to the
/// public-trip model used by Trip Details / Public Booking.
class PlaceTripMapper {
  /// The card of a trip, in the shape the place screen shows.
  Trip toCard(PublicTrip trip, Place place) {
    return Trip(
      id: trip.id,
      placeId: place.id,
      title: trip.title,
      dateTime: trip.dateLabel,
      guideName: trip.guideName,
      peopleCount: trip.bookedSeats,
      price: trip.priceEgp,
      currency: 'EGP',
      imageUrl: trip.imageUrl,
      capacity: trip.capacity,
    );
  }

  /// Approved trips whose free-text location matches this place's Firestore
  /// `name` (substring in either direction). Trips without a location never
  /// match; an empty result is shown as empty, never replaced by everything.
  List<Trip> cardsForPlace(List<PublicTrip> trips, Place place) {
    final name = place.name.trim().toLowerCase();
    if (name.isEmpty) return const <Trip>[];
    return trips.where((trip) {
      final location = trip.location.trim().toLowerCase();
      if (location.isEmpty) return false;
      return location.contains(name) || name.contains(location);
    }).map((trip) => toCard(trip, place)).toList();
  }

  /// The bundled trips, used when the Firestore read cannot be reached.
  List<Trip> mockCardsForPlace(String placeId) => mockPlaceTrips
      .where((e) => e['place_id'] == placeId)
      .map((e) => Trip.fromJson(e))
      .toList();

  /// Resolves a place trip to the existing public-trip model so it can open
  /// Trip Details / Public Booking. A bundled trip is looked up by id only —
  /// a Firestore trip must never fall back to another trip of the dataset.
  trips_model.Trip publicTripFor(Trip trip) {
    for (final e in mockTripsJson) {
      if (e['id'] == trip.id) {
        return trips_model.Trip.fromJson(e);
      }
    }
    return trips_model.Trip(
      id: trip.id,
      title: trip.title,
      dateLabel: trip.dateTime,
      guideName: trip.guideName,
      peopleCount: trip.peopleCount,
      priceEgp: trip.price,
      imageUrl: trip.imageUrl,
      status: trips_model.TripStatus.upcoming,
      category: 'historical',
      capacity: trip.capacity,
    );
  }
}

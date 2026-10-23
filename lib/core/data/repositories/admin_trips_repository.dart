import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../remote/firestore_service.dart';
import 'guide_notifications_repository.dart';
import 'guide_trips_repository.dart';

/// One trip as the admin dashboard sees it.
class AdminTrip {
  final String tripId;
  final String title;
  final String guideName;
  final String guideId;
  final String location;

  /// The approval state: pending | approved | rejected | cancelled.
  final String approvalStatus;

  /// When the trip starts, as a readable label.
  final String scheduleLabel;

  /// Seats booked out of the capacity.
  final int bookedSeats;
  final int capacity;

  /// Price per person, in EGP.
  final double priceEgp;

  /// Why the admin rejected it (empty otherwise).
  final String rejectionReason;

  /// The long-form description of the trip.
  final String about;

  /// The itinerary stops, as readable lines.
  final List<String> itinerary;

  /// The cover image of the trip.
  final String imageUrl;

  const AdminTrip({
    required this.tripId,
    required this.title,
    required this.guideName,
    required this.guideId,
    required this.location,
    required this.approvalStatus,
    required this.scheduleLabel,
    required this.bookedSeats,
    required this.capacity,
    required this.priceEgp,
    this.rejectionReason = '',
    this.about = '',
    this.itinerary = const [],
    this.imageUrl = '',
  });

  /// Whether the trip is still waiting for a decision.
  bool get isPending => approvalStatus == 'pending';

  /// The travellers the trip currently carries.
  int get travelers => bookedSeats;

  /// The price, formatted the way the admin tables show it.
  String get priceLabel => 'EGP ${priceEgp.toInt()}';
}

/// Reads and decides the trips of every guide, for the admin dashboard.
///
/// The admin is the only role allowed to move a trip out of `pending` —
/// the security rules enforce that, so a guide can never approve their
/// own trip.
class AdminTripsRepository {
  AdminTripsRepository({
    FirestoreService? firestore,
    this.auth,
    GuideNotificationsRepository? notifications,
  }) : _firestore = firestore ?? FirestoreService(),
       _notifications = notifications ?? GuideNotificationsRepository();

  final FirestoreService _firestore;
  final GuideNotificationsRepository _notifications;

  /// The auth client to read the signed-in admin from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in admin's uid, or null when signed out.
  String? get currentAdminId => _firebaseAuth.currentUser?.uid;

  /// Every trip of every guide, newest first.
  Future<List<AdminTrip>> fetchTrips() async {
    try {
      final snapshot = await _firestore
          .collection(GuideTripsRepository.tripsCollection)
          .get();
      final trips = snapshot.docs.map(_toAdminTrip).toList();
      trips.sort((a, b) => b.scheduleLabel.compareTo(a.scheduleLabel));
      return trips;
    } catch (_) {
      return const [];
    }
  }

  /// Real-time view of every guide's trip, newest first.
  ///
  /// Re-emits the full trip list whenever the trips collection changes,
  /// so the admin dashboard stays in sync without a refresh.
  Stream<List<AdminTrip>> watchTrips() async* {
    await for (final _ in _firestore
        .collection(GuideTripsRepository.tripsCollection)
        .snapshots()) {
      yield await fetchTrips();
    }
  }

  /// The trips waiting for a review.
  Future<List<AdminTrip>> fetchPendingTrips() async {
    final trips = await fetchTrips();
    return trips.where((trip) => trip.isPending).toList();
  }

  /// Approves or rejects a trip, and tells the guide about it.
  ///
  /// Returns false when the write was refused (the caller is not an
  /// admin, or the trip vanished).
  Future<bool> decide({
    required String tripId,
    required bool approve,
    String rejectionReason = '',
  }) async {
    try {
      await _firestore.writeDoc(GuideTripsRepository.tripsCollection, tripId, {
        'approvalStatus': approve ? 'approved' : 'rejected',
        'rejectionReason': approve ? '' : rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      return false;
    }

    // Tell the guide. A failed notification never fails the decision.
    final trip = await _fetchTrip(tripId);
    final guideId = trip?['guideId'] as String?;
    final title = (trip?['title'] as String?) ?? 'Your trip';
    if (guideId == null || guideId.isEmpty) return true;
    await _notifications.create(
      userId: guideId,
      title: approve ? 'Trip approved' : 'Trip rejected',
      message: approve
          ? '"$title" is now live and visible to tourists.'
          : '"$title" was rejected: $rejectionReason',
      type: 'trip_decided',
      relatedEntityId: tripId,
      relatedCollection: 'trips',
    );
    return true;
  }

  /// Cancels a trip and tells the guide.
  ///
  /// Returns false when the write was refused.
  Future<bool> cancel(String tripId) async {
    try {
      await _firestore.writeDoc(GuideTripsRepository.tripsCollection, tripId, {
        'approvalStatus': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      return false;
    }

    final trip = await _fetchTrip(tripId);
    final guideId = trip?['guideId'] as String?;
    final title = (trip?['title'] as String?) ?? 'Your trip';
    if (guideId == null || guideId.isEmpty) return true;
    await _notifications.create(
      userId: guideId,
      title: 'Trip cancelled',
      message: '"$title" was cancelled by the admin team.',
      type: 'trip_decided',
      relatedEntityId: tripId,
      relatedCollection: 'trips',
    );
    return true;
  }

  Future<Map<String, dynamic>?> _fetchTrip(String tripId) async {
    try {
      return await _firestore.readDoc(
        GuideTripsRepository.tripsCollection,
        tripId,
      );
    } catch (_) {
      return null;
    }
  }

  AdminTrip _toAdminTrip(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawItinerary = (data['itinerary'] as List?) ?? const [];
    return AdminTrip(
      tripId: doc.id,
      title: (data['title'] as String?) ?? '',
      guideName: (data['guideName'] as String?) ?? '',
      guideId: (data['guideId'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      approvalStatus: (data['approvalStatus'] as String?) ?? 'pending',
      scheduleLabel: (data['scheduleLabel'] as String?) ?? '',
      bookedSeats: (data['bookedSeats'] as num?)?.toInt() ?? 0,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      priceEgp: ((data['priceEgp'] as num?) ?? 0).toDouble(),
      rejectionReason: (data['rejectionReason'] as String?) ?? '',
      about: (data['about'] as String?) ?? '',
      itinerary: rawItinerary.map((stop) {
        if (stop is! Map) return '$stop';
        final time = stop['time'] ?? '';
        final title = stop['title'] ?? '';
        return time.isEmpty ? '$title' : '$time — $title';
      }).toList(),
      imageUrl:
          (data['coverUrl'] as String?) ?? (data['imageUrl'] as String?) ?? '',
    );
  }
}

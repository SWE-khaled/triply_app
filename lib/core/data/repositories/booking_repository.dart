import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/tourist_booking.dart';
import '../remote/firestore_service.dart';
import 'guide_notifications_repository.dart';

/// Why a booking could not be created.
class BookingException implements Exception {
  final String message;

  const BookingException(this.message);

  @override
  String toString() => message;
}

/// The result of a successful booking.
class BookingReceipt {
  final String bookingId;
  final String tripId;
  final int seats;
  final double totalPrice;

  const BookingReceipt({
    required this.bookingId,
    required this.tripId,
    required this.seats,
    required this.totalPrice,
  });
}

/// Creates the bookings of the tourists.
///
/// A public booking runs inside a Firestore transaction: the trip is read
/// and its seats are reserved in the very same transaction, so two
/// tourists can never book the last seat at the same time.
class BookingRepository {
  BookingRepository({
    FirestoreService? firestore,
    this.auth,
    GuideNotificationsRepository? notifications,
  }) : _firestore = firestore ?? FirestoreService(),
       _notifications = notifications ?? GuideNotificationsRepository();

  /// Firestore collection holding the bookings.
  static const String bookingsCollection = 'bookings';

  /// Firestore collection holding the trips.
  static const String tripsCollection = 'trips';

  /// Firestore collection holding the user profiles.
  static const String usersCollection = 'users';

  final FirestoreService _firestore;
  final GuideNotificationsRepository _notifications;

  /// The auth client to read the signed-in tourist from. Null means the
  /// default [FirebaseAuth] instance.
  final FirebaseAuth? auth;

  /// Resolved lazily so building the repository never requires a running
  /// Firebase app (which keeps it usable in plain unit tests).
  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  /// The signed-in tourist's uid, or null when signed out.
  String? get currentTouristId => _firebaseAuth.currentUser?.uid;

  /// Books [seats] seats of a public trip.
  ///
  /// Reserves the seats inside a transaction and tells the guide about
  /// it. Throws a [BookingException] when the trip is full, not approved
  /// or gone.
  String _avatarFor(Map<String, dynamic>? guest) {
    final saved = guest?['photoUrl'];
    if (saved is String && saved.trim().isNotEmpty) return saved.trim();
    return _firebaseAuth.currentUser?.photoURL ?? '';
  }

  Future<BookingReceipt> createPublicBooking({
    required String tripId,
    required int seats,
    required double unitPrice,
    required String paymentMethod,
    String specialRequests = '',
  }) async {
    final uid = currentTouristId;
    if (uid == null) {
      throw const BookingException('Sign in before booking a trip.');
    }
    if (seats <= 0) {
      throw const BookingException('Choose at least one seat.');
    }
    if (paymentMethod != 'card' && paymentMethod != 'wallet') {
      throw const BookingException('Choose a payment method.');
    }

    final db = _firestore.instance;
    final tripRef = db.collection(tripsCollection).doc(tripId);
    final bookingRef = db.collection(bookingsCollection).doc();
    final serviceFee = unitPrice * seats * 0.05;
    final total = unitPrice * seats + serviceFee;

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 30));

    // The guest of the booking is the tourist who books — not the guide
    // who owns the trip.
    final guest = await _readGuestProfile(uid);

    await db.runTransaction((tx) async {
      final tripSnapshot = await tx.get(tripRef);
      if (!tripSnapshot.exists) {
        throw const BookingException('This trip is no longer available.');
      }
      final trip = tripSnapshot.data() ?? const <String, dynamic>{};
      if (trip['approvalStatus'] != 'approved') {
        throw const BookingException('This trip is not open for booking.');
      }
      // A trip without a real start moment cannot be booked yet — the
      // guide still has to set the date and time (and end time) on it.
      if (trip['startAt'] == null) {
        throw const BookingException(
          'This trip has no date or time set yet and cannot be booked.',
        );
      }
      final capacity = (trip['capacity'] as num?)?.toInt() ?? 0;
      final booked = (trip['bookedSeats'] as num?)?.toInt() ?? 0;
      final free = capacity - booked;
      if (free < seats) {
        throw BookingException(
          free <= 0
              ? 'This trip is fully booked.'
              : 'Only $free seat${free == 1 ? '' : 's'} left.',
        );
      }

      // Reserve the seats and write the booking in the same transaction.
      tx.update(tripRef, {
        'bookedSeats': booked + seats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(bookingRef, {
        'tripId': tripId,
        'touristId': uid,
        'guideId': trip['guideId'] ?? '',
        'tour_title': trip['title'] ?? '',
        'guest_name': guest?['name'] ?? guest?['fullName'] ?? '',
        'country': '',
        'traveler_count': seats,
        'seats': seats,
        'avatar_url': _avatarFor(guest),
        'is_private': false,
        'unitPrice': unitPrice,
        'serviceFee': serviceFee,
        'totalPrice': total,
        'price_label': 'EGP ${total.toStringAsFixed(0)}',
        'detail_label': '$seats traveler${seats == 1 ? '' : 's'}',
        'datetime_label': trip['scheduleLabel'] ?? '',
        'location': trip['location'] ?? '',
        'booking_code': bookingRef.id,
        'specialRequests': specialRequests,
        // Payment is confirmed by the Paymob WebView; until then the
        // booking stays pending so its seats can be released on expiry.
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': paymentMethod,
        'refundStatus': 'none',
        // The trip's real start moment (public trips carry startAt;
        // endAt is filled in once trips require it, see S2).
        'startAt': trip['startAt'],
        'endAt': null,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    final trip = await _readTrip(tripId);
    final guideId = trip?['guideId'] as String?;
    final tripTitle = (trip?['title'] as String?) ?? 'your trip';
    if (guideId != null && guideId.isNotEmpty) {
      await _notifications.create(
        userId: guideId,
        title: 'New booking',
        message:
            'A tourist booked "$tripTitle" for $seats '
            'traveler${seats == 1 ? '' : 's'}.',
        type: 'booking',
        relatedEntityId: bookingRef.id,
        relatedCollection: 'bookings',
      );
    }

    return BookingReceipt(
      bookingId: bookingRef.id,
      tripId: tripId,
      seats: seats,
      totalPrice: total,
    );
  }

  /// The bookings of the signed-in tourist.
  ///
  /// Returns null when the read failed — the caller falls back to the
  /// session store then.
  Future<List<TouristBooking>?> fetchMyBookings() async {
    final uid = currentTouristId;
    if (uid == null) return null;
    try {
      final snapshot = await _firestore
          .collection(bookingsCollection)
          .where('touristId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => TouristBooking.fromDocument(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Books a guide directly, without a published trip.
  Future<BookingReceipt> createPrivateBooking({
    required String guideId,
    required String guideName,
    required String title,
    required int travelers,
    required double totalPrice,
    required String paymentMethod,
    DateTime? startAt,
    DateTime? endAt,
    String meetingPoint = '',
    String notes = '',
    String specialRequests = '',
  }) async {
    final uid = currentTouristId;
    if (uid == null) {
      throw const BookingException('Sign in before booking a guide.');
    }
    if (travelers <= 0) {
      throw const BookingException('Choose at least one traveler.');
    }
    if (paymentMethod != 'card' && paymentMethod != 'wallet') {
      throw const BookingException('Choose a payment method.');
    }

    final db = _firestore.instance;
    final bookingRef = db.collection(bookingsCollection).doc();
    // The guest of the booking is the tourist who books — not the guide
    // who is booked.
    final guest = await _readGuestProfile(uid);
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 30));
    await bookingRef.set({
      'tripId': '',
      'touristId': uid,
      'guideId': guideId,
      'tour_title': title,
      'guest_name': guest?['name'] ?? guest?['fullName'] ?? '',
      'country': '',
      'traveler_count': travelers,
      'seats': travelers,
      'avatar_url':
          guest?['photoUrl'] ??
          FirebaseAuth.instance.currentUser?.photoURL ??
          '',
      'is_private': true,
      'totalPrice': totalPrice,
      'price_label': 'EGP ${totalPrice.toStringAsFixed(0)}',
      'detail_label': '$travelers traveler${travelers == 1 ? '' : 's'}',
      'datetime_label': '',
      'location': meetingPoint,
      'booking_code': bookingRef.id,
      'notes': notes,
      'specialRequests': specialRequests,
      // Payment is confirmed by the Paymob WebView; until then the
      // booking stays pending so it can be released on expiry.
      'status': 'pending',
      'paymentStatus': 'pending',
      'paymentMethod': paymentMethod,
      'refundStatus': 'none',
      'startAt': startAt != null ? Timestamp.fromDate(startAt) : null,
      'endAt': endAt != null ? Timestamp.fromDate(endAt) : null,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _notifications.create(
      userId: guideId,
      title: 'New private booking',
      message:
          'A tourist booked you privately for $travelers '
          'traveler${travelers == 1 ? '' : 's'}.',
      type: 'booking',
      relatedEntityId: bookingRef.id,
      relatedCollection: 'bookings',
    );

    return BookingReceipt(
      bookingId: bookingRef.id,
      tripId: '',
      seats: travelers,
      totalPrice: totalPrice,
    );
  }

  /// Confirms a pending booking after the Paymob WebView reports success.
  ///
  /// Sets `status: 'confirmed'`, `paymentStatus: 'paid'` and records the
  /// `paymentId` returned by Paymob. Only the owning tourist may run this,
  /// and only while the booking is still `pending`.
  Future<void> confirmPayment({
    required String bookingId,
    required String paymentId,
  }) async {
    final uid = currentTouristId;
    if (uid == null) {
      throw const BookingException('Sign in before confirming a booking.');
    }
    final db = _firestore.instance;
    final bookingRef = db.collection(bookingsCollection).doc(bookingId);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(bookingRef);
      if (!snapshot.exists) {
        throw const BookingException('This booking no longer exists.');
      }
      final data = snapshot.data() ?? const <String, dynamic>{};
      if (data['touristId'] != uid) {
        throw const BookingException('This booking is not yours.');
      }
      if (data['status'] != 'pending' || data['paymentStatus'] != 'pending') {
        throw const BookingException('This booking cannot be confirmed.');
      }
      tx.update(bookingRef, {
        'status': 'confirmed',
        'paymentStatus': 'paid',
        'paymentId': paymentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Cancels a booking the tourist owns and releases its seats.
  ///
  /// Sets `status: 'cancelled'`, `cancelledAt`, `cancelledBy: 'tourist'`
  /// and `refundStatus` (`'owed'` when paid, otherwise `'none'`). Public
  /// trip seats are released inside the same transaction (never below 0,
  /// never above the trip's capacity). Private trips have no trip to
  /// release seats on.
  Future<void> cancelBooking({
    required String bookingId,
    required bool wasPaid,
  }) async {
    final uid = currentTouristId;
    if (uid == null) {
      throw const BookingException('Sign in before cancelling a booking.');
    }
    final db = _firestore.instance;
    final bookingRef = db.collection(bookingsCollection).doc(bookingId);
    final trips = db.collection(tripsCollection);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(bookingRef);
      if (!snapshot.exists) {
        throw const BookingException('This booking no longer exists.');
      }
      final data = snapshot.data() ?? const <String, dynamic>{};
      if (data['touristId'] != uid) {
        throw const BookingException('This booking is not yours.');
      }
      final tripId = (data['tripId'] as String?) ?? '';
      final seats = (data['seats'] as num?)?.toInt() ?? 0;
      final isPrivate = data['is_private'] == true;
      tx.update(bookingRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': 'tourist',
        'refundStatus': wasPaid ? 'owed' : 'none',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Release the seats of a public trip (bounded by [0, capacity]).
      // Private trips have no published trip to release seats on.
      if (tripId.isNotEmpty && !isPrivate && seats > 0) {
        final tripDoc = trips.doc(tripId);
        final tripSnap = await tx.get(tripDoc);
        if (tripSnap.exists) {
          final trip = tripSnap.data() ?? const <String, dynamic>{};
          final capacity = (trip['capacity'] as num?)?.toInt() ?? 0;
          final booked = (trip['bookedSeats'] as num?)?.toInt() ?? 0;
          final released = (booked - seats).clamp(0, capacity);
          tx.update(tripDoc, {
            'bookedSeats': released,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  Future<Map<String, dynamic>?> _readTrip(String tripId) async {
    try {
      return await _firestore.readDoc(tripsCollection, tripId);
    } catch (_) {
      return null;
    }
  }

  /// The profile of the tourist who books.
  ///
  /// The guide sees the guest, so the name and the photo come from the
  /// tourist's own profile document.
  Future<Map<String, dynamic>?> _readGuestProfile(String uid) async {
    try {
      return await _firestore.readDoc(usersCollection, uid);
    } catch (_) {
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../remote/firestore_service.dart';

/// One booking as seen and managed in the admin dashboard.
class AdminBooking {
  final String id;
  final String user;
  final String touristId;
  final String trip;
  final String tripId;
  final String guide;
  final String guideId;
  final String date;
  final String status;
  final String price;
  final double totalPrice;
  final String type;
  final String location;
  final int travelers;
  final String bookingCode;
  final DateTime? createdAt;

  const AdminBooking({
    required this.id,
    required this.user,
    this.touristId = '',
    required this.trip,
    this.tripId = '',
    required this.guide,
    this.guideId = '',
    required this.date,
    required this.status,
    required this.price,
    this.totalPrice = 0.0,
    required this.type,
    this.location = '',
    this.travelers = 1,
    this.bookingCode = '',
    this.createdAt,
  });

  factory AdminBooking.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final user = (data['guest_name'] as String?) ??
        (data['userName'] as String?) ??
        (data['touristName'] as String?) ??
        'Tourist';
    final trip = (data['tour_title'] as String?) ??
        (data['tripTitle'] as String?) ??
        (data['title'] as String?) ??
        'Trip';
    final guide = (data['guideName'] as String?) ??
        (data['guide_name'] as String?) ??
        'Guide';
    final status = (data['status'] as String?) ?? 'pending';
    final isPrivate = data['is_private'] == true;
    final total = (data['totalPrice'] as num?)?.toDouble() ??
        (data['price'] as num?)?.toDouble() ??
        0.0;
    final priceLabel = (data['price_label'] as String?) ??
        (data['price'] is String
            ? data['price'] as String
            : 'EGP ${total.toInt()}');

    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    String dateLabel = (data['datetime_label'] as String?) ??
        (data['scheduleLabel'] as String?) ??
        '';
    if (dateLabel.isEmpty && createdAt != null) {
      dateLabel = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (dateLabel.isEmpty) {
      dateLabel = 'Recently';
    }

    return AdminBooking(
      id: doc.id,
      user: user.trim().isNotEmpty ? user : 'Tourist',
      touristId: (data['touristId'] as String?) ?? '',
      trip: trip.trim().isNotEmpty ? trip : 'Trip',
      tripId: (data['tripId'] as String?) ?? '',
      guide: guide.trim().isNotEmpty ? guide : 'Guide',
      guideId: (data['guideId'] as String?) ?? '',
      date: dateLabel,
      status: status,
      price: priceLabel,
      totalPrice: total,
      type: isPrivate ? 'Private' : 'Public',
      location: (data['location'] as String?) ?? '',
      travelers: (data['traveler_count'] as num?)?.toInt() ??
          (data['seats'] as num?)?.toInt() ??
          1,
      bookingCode: (data['booking_code'] as String?) ?? doc.id,
      createdAt: createdAt,
    );
  }
}

/// Repository for reading and managing bookings in the admin dashboard.
class AdminBookingsRepository {
  AdminBookingsRepository({FirestoreService? firestore})
      : _firestore = firestore ?? FirestoreService();

  static const String bookingsCollection = 'bookings';
  final FirestoreService _firestore;

  /// Real-time stream of all bookings from Firestore.
  Stream<List<AdminBooking>> watchBookings() {
    return _firestore
        .collection(bookingsCollection)
        .snapshots()
        .map((snapshot) {
          final bookings =
              snapshot.docs.map((doc) => AdminBooking.fromDoc(doc)).toList();
          bookings.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return -1;
            if (b.createdAt == null) return 1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return bookings;
        });
  }

  /// Fetches all bookings once.
  Future<List<AdminBooking>> fetchBookings() async {
    try {
      final snapshot = await _firestore.collection(bookingsCollection).get();
      final bookings =
          snapshot.docs.map((doc) => AdminBooking.fromDoc(doc)).toList();
      bookings.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return bookings;
    } catch (_) {
      return const [];
    }
  }

  /// Updates the status of a booking in Firestore.
  Future<bool> updateStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.writeDoc(bookingsCollection, bookingId, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}


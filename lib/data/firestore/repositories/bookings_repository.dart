import 'package:cloud_functions/cloud_functions.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/booking_pricing.dart';
import 'package:triply/data/firestore/datasources/bookings_datasource.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/payments_datasource.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/payment_doc.dart';

/// Booking writes go through the `createBooking` callable Function
/// (capacity transaction + trusted pricing). Reads/cancellation use the
/// datasource directly. Display totals in cubits stay as-is; the Function
/// is authoritative.
///
/// If Functions are unreachable (emulator down / offline), [createPublic]
/// throws with a friendly message — cubits must NOT silently fall back to
/// a local-only booking and present it as confirmed.
class BookingsRepository {
  BookingsDatasource? _bookingsDS;
  PaymentsDatasource? _paymentsDS;
  FirebaseFunctions? _functionsSvc;

  BookingsRepository({
    BookingsDatasource? bookings,
    PaymentsDatasource? payments,
    FirebaseFunctions? functions,
  }) : _bookingsDS = bookings,
       _paymentsDS = payments,
       _functionsSvc = functions;

  // Lazy: constructing the repository must not touch Firebase (keeps
  // widget/unit tests and offline startup free of Firebase initialization).
  // Same pattern as TripsRepository/PlacesRepository.
  BookingsDatasource get _bookings => _bookingsDS ??= BookingsDatasource();
  PaymentsDatasource get _payments => _paymentsDS ??= PaymentsDatasource();
  FirebaseFunctions get _functions =>
      _functionsSvc ??= FirebaseFunctions.instance;

  Future<FirestoreResult<List<BookingDoc>>> myBookings(
    String touristId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _bookings.listByTourist(
        touristId,
        limit: limit,
        startAfter: startAfter,
      );
      if (page.items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(page.items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  Future<FirestoreResult<List<BookingDoc>>> guideBookings(
    String guideId, {
    int limit = 20,
    Object? startAfter,
  }) async {
    try {
      final page = await _bookings.listByGuide(
        guideId,
        limit: limit,
        startAfter: startAfter,
      );
      if (page.items.isEmpty) return const FirestoreEmpty();
      return FirestoreOk(page.items);
    } catch (e) {
      return FirestoreFailure(FirestoreQueryHelper.friendlyError(e), e);
    }
  }

  /// Public trip booking via Function. [idempotencyKey] must be stable per
  /// user action (e.g. `uid_tripId_date_seats`) to prevent double charges
  /// on retry. Returns the authoritative [BookingDoc] (with server totals).
  /// A retry with the same key returns the original booking (dedupe);
  /// a key owned by another user surfaces a permission error (no disclosure).
  /// [tripDate] is optional metadata (the backend accepts an omitted field);
  /// pass null when the trip carries no parseable date — never a guess.
  Future<BookingDoc> createPublic({
    required String tripId,
    DateTime? tripDate,
    required int seats,
    required String idempotencyKey,
    String specialRequests = '',
  }) async {
    try {
      final callable = _functions.httpsCallable('createBooking');
      final res = await callable.call({
        'bookingType': 'public',
        'tripId': tripId,
        if (tripDate != null) 'tripDate': tripDate.toUtc().toIso8601String(),
        'seats': seats,
        'specialRequests': specialRequests,
        'idempotencyKey': idempotencyKey,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return BookingDoc.fromMap(data, (data['id'] ?? '').toString());
    } on FirebaseFunctionsException catch (e) {
      final deduped = await _fetchDeduped(e);
      if (deduped != null) return deduped;
      throw Exception(_functionMessage(e));
    } catch (e) {
      throw Exception(FirestoreQueryHelper.friendlyError(e));
    }
  }

  /// Private guide booking via Function (price = pricePerHour × hours ×
  /// travelers + fee, recomputed server-side).
  Future<BookingDoc> createPrivate({
    required String guideId,
    String? placeId,
    required DateTime appointmentAt,
    required String timeSlot,
    required int travelers,
    required int durationHours,
    String meetingPoint = '',
    String specialRequests = '',
    required String idempotencyKey,
  }) async {
    final err = BookingPricing.validatePrivate(travelers: travelers);
    if (err != null) throw Exception(err);
    try {
      final callable = _functions.httpsCallable('createBooking');
      final payload = <String, dynamic>{
        'bookingType': 'private',
        'guideId': guideId,
        'appointmentAt': appointmentAt.toUtc().toIso8601String(),
        'timeSlot': timeSlot,
        'travelers': travelers,
        'durationHours': durationHours,
        'meetingPoint': meetingPoint,
        'specialRequests': specialRequests,
        'idempotencyKey': idempotencyKey,
        // ignore: use_null_aware_elements
        if (placeId != null) 'placeId': placeId,
      };
      final res = await callable.call(payload);
      final data = Map<String, dynamic>.from(res.data as Map);
      return BookingDoc.fromMap(data, (data['id'] ?? '').toString());
    } on FirebaseFunctionsException catch (e) {
      final deduped = await _fetchDeduped(e);
      if (deduped != null) return deduped;
      throw Exception(_functionMessage(e));
    } catch (e) {
      throw Exception(FirestoreQueryHelper.friendlyError(e));
    }
  }

  /// Resolves an `already-exists` conflict to the caller's own booking.
  /// Returns null when the error is anything else (caller rethrows).
  /// Ownership is enforced server-side first; the fetch only succeeds for
  /// bookings the caller is allowed to read, so nothing leaks cross-user.
  /// NOTE (dormant fallback): the server now returns the original booking
  /// directly on same-key retries, so this path only triggers if a future
  /// server version surfaces `already-exists` again. Kept as a safety net.
  Future<BookingDoc?> _fetchDeduped(FirebaseFunctionsException e) async {
    if (e.code != 'already-exists') return null;
    final bookingId = (e.message ?? '').trim();
    if (bookingId.isEmpty) return null;
    try {
      final doc = await _bookings.getById(bookingId);
      return doc;
    } catch (_) {
      return null;
    }
  }

  /// Direct owner cancel for UNPAID bookings (rules reject paid ones).
  Future<void> cancelByTourist(String bookingId, {String reason = ''}) =>
      _bookings.cancelByTourist(bookingId, reason: reason);

  /// Server-side cancel for any active booking (the ONLY path for paid
  /// bookings). Records `refundStatus: owed` when money was captured so
  /// refunds are handled manually; capacity release stays trigger-owned.
  /// Returns the refund status (`owed` or `none`).
  Future<String> cancelViaServer(String bookingId, {String reason = ''}) async {
    try {
      final callable = _functions.httpsCallable('cancelBooking');
      final res = await callable.call({
        'bookingId': bookingId,
        'reason': reason,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return (data['refundStatus'] ?? 'none').toString();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(_functionMessage(e));
    } catch (e) {
      throw Exception(FirestoreQueryHelper.friendlyError(e));
    }
  }

  /// Creates the `pending` Paymob reconciliation record before opening the
  /// iframe. Amount comes from the authoritative booking (never the UI).
  Future<String> createPendingPayment({
    required String bookingId,
    required String touristId,
    required double amount,
    required String providerReference,
  }) {
    return _payments.createPending(
      PaymentDoc(
        id: '',
        bookingId: bookingId,
        touristId: touristId,
        providerReference: providerReference,
        amount: amount,
      ),
    );
  }

  /// Verifies a payment through the trusted `verifyPaymobTransaction`
  /// callable and returns the server verdict. Only `succeeded` proves
  /// payment — `pending` (with a reason) and every error mean the booking
  /// must NOT be treated as paid. Throws with a user-facing message when
  /// the server rejects the request.
  Future<({String status, String? reason, bool deduped})> verifyPayment(
    String paymentId,
  ) async {
    try {
      final callable = _functions.httpsCallable('verifyPaymobTransaction');
      final res = await callable.call({'paymentId': paymentId});
      final data = Map<String, dynamic>.from(res.data as Map);
      return parseVerifyPayload(data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(_functionMessage(e, action: 'verify payment'));
    } catch (e) {
      throw Exception(FirestoreQueryHelper.friendlyError(e));
    }
  }

  /// Pure mapping of a verify-callable response. `succeeded` is the only
  /// paid verdict; anything else keeps the booking unpaid.
  static ({String status, String? reason, bool deduped}) parseVerifyPayload(
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] ?? '').toString();
    if (status == 'succeeded') {
      return (status: status, reason: null, deduped: data['_deduped'] == true);
    }
    return (
      status: status.isEmpty ? 'pending' : status,
      reason: (data['reason'] ?? '').toString().isEmpty
          ? null
          : (data['reason'] ?? '').toString(),
      deduped: false,
    );
  }

  String _functionMessage(FirebaseFunctionsException e, {String? action}) {
    switch (e.code) {
      case 'unauthenticated':
        return action == null
            ? 'Please sign in to book.'
            : 'Please sign in to $action.';
      case 'invalid-argument':
        return e.message ?? 'Invalid booking details.';
      case 'already-exists':
        return 'This booking was already submitted.';
      case 'failed-precondition':
        return e.message ?? 'Booking is no longer available.';
      case 'not-found':
        return e.message ?? 'Requested trip or guide was not found.';
      case 'permission-denied':
        return e.message ?? 'You are not allowed to perform this action.';
      case 'unavailable':
        return 'Booking service unavailable. Please try again.';
      case 'internal':
        // Functions v2 scrubs uncaught errors to code=internal/message=INTERNAL.
        // Never surface raw "INTERNAL" — fail closed with an actionable message.
        if (e.message == null ||
            e.message!.isEmpty ||
            e.message!.toUpperCase() == 'INTERNAL') {
          return 'Booking service unavailable. Please try again.';
        }
        return e.message!;
      default:
        // Same guard for any future scrubbed code carrying "INTERNAL".
        if (e.message == null ||
            e.message!.isEmpty ||
            e.message!.toUpperCase() == 'INTERNAL') {
          return action == null
              ? 'Booking failed. Please try again.'
              : 'Could not $action. Please try again.';
        }
        return e.message!;
    }
  }
}

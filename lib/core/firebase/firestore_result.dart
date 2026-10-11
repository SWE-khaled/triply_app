/// Lightweight result wrapper so repositories can return typed
/// loading/success/empty/error outcomes without throwing across cubits.
sealed class FirestoreResult<T> {
  const FirestoreResult();
}

class FirestoreOk<T> extends FirestoreResult<T> {
  final T data;
  const FirestoreOk(this.data);
}

class FirestoreEmpty<T> extends FirestoreResult<T> {
  const FirestoreEmpty();
}

class FirestoreFailure<T> extends FirestoreResult<T> {
  final String message;
  final Object? cause;
  const FirestoreFailure(this.message, [this.cause]);
}

/// Paginated query page. Cubits keep emitting their existing states;
/// they read `items`, `hasMore`, and pass `lastDocSnapshot` back for
/// the next page. Uses raw snapshots to avoid importing Firestore in UI.
class FirestorePage<T> {
  final List<T> items;
  final Object? lastSnapshot;
  final bool hasMore;

  const FirestorePage({
    required this.items,
    required this.lastSnapshot,
    required this.hasMore,
  });
}

/// Shared status vocabularies. These are the ONLY values clients and
/// Cloud Functions may write; rules + functions reject anything else.
/// Tourist GuideTrip.status (`active`) is a display state, not a Firestore
/// approval state — see TripDoc.approvalStatus mapping.
class FirestoreStatuses {
  FirestoreStatuses._();

  // trips.approvalStatus
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
  static const Set<String> tripApproval = {
    pending,
    approved,
    rejected,
    cancelled,
  };

  // bookings.status
  static const String bPending = 'pending';
  static const String bConfirmed = 'confirmed';
  static const String bCompleted = 'completed';
  static const String bCancelled = 'cancelled';
  static const Set<String> booking = {
    bPending,
    bConfirmed,
    bCompleted,
    bCancelled,
  };

  // bookings.bookingType
  static const String publicBooking = 'public';
  static const String privateBooking = 'private';

  // payments.status / provider
  static const String payPending = 'pending';
  static const String paySucceeded = 'succeeded';
  static const String payFailed = 'failed';
  static const String payRefunded = 'refunded';
  static const String providerPaymob = 'paymob';

  // guideVerifications.status
  static const String vPending = 'pending';
  static const String vApproved = 'approved';
  static const String vRejected = 'rejected';
  static const Set<String> verification = {vPending, vApproved, vRejected};

  // users.role — never client-writable to `admin` (enforced by rules).
  static const String roleTourist = 'tourist';
  static const String roleGuide = 'guide';
  static const String roleAdmin = 'admin';
}

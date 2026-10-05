/// Session-only record of confirmed bookings (mock phase, no backend).
/// TripsCubit-style consumers read this; BookingCubits write it.
/// Later: replaced by API orders — Views/Cubits keep the same calls.
///
/// Every record starts with status 'pending' so the admin can later
/// approve/reject it from the Admin Dashboard. `kind` distinguishes
/// public trips from private guide bookings.
class MyBookingsPublic {
  MyBookingsPublic._();

  static const String statusPending = 'pending';

  static final Map<String, _BookingEntry> _entries = <String, _BookingEntry>{};

  /// Public trip booking. Keeps the original positional signature.
  static void record(
    String tripId,
    int seats, {
    double totalPaid = 0,
    String status = statusPending,
  }) {
    final prev = _entries[tripId];
    _entries[tripId] = _BookingEntry(
      seats: seats,
      totalPaid: totalPaid,
      kind: 'public',
      status: status,
      guideId: prev?.guideId,
      title: prev?.title,
      imageUrl: prev?.imageUrl,
      dateLabel: prev?.dateLabel,
      guideName: prev?.guideName,
    );
  }

  /// Private guide booking. Returns the generated booking key, which doubles
  /// as the synthetic trip id shown in My Trips.
  static String recordPrivate({
    required String guideId,
    required String guideName,
    required String title,
    required String imageUrl,
    required String dateLabel,
    required int travelers,
    required double totalPaid,
    String status = statusPending,
  }) {
    final key =
        'pvt-${guideId}_${DateTime.now().millisecondsSinceEpoch}';
    _entries[key] = _BookingEntry(
      seats: travelers,
      totalPaid: totalPaid,
      kind: 'private',
      status: status,
      guideId: guideId,
      title: title,
      imageUrl: imageUrl,
      dateLabel: dateLabel,
      guideName: guideName,
    );
    return key;
  }

  static bool isBooked(String tripId) => _entries.containsKey(tripId);

  static Set<String> get bookedIds => Set.unmodifiable(_entries.keys);

  static int seatsFor(String tripId) => _entries[tripId]?.seats ?? 0;

  static double totalPaidFor(String tripId) =>
      _entries[tripId]?.totalPaid ?? 0;

  /// 'public' or 'private'. Defaults to 'public' for legacy records.
  static String kindFor(String tripId) =>
      _entries[tripId]?.kind ?? 'public';

  static bool isPrivate(String tripId) => kindFor(tripId) == 'private';

  static String statusFor(String tripId) =>
      _entries[tripId]?.status ?? statusPending;

  static bool isPending(String tripId) =>
      statusFor(tripId) == statusPending;

  static _BookingEntry? entryFor(String tripId) => _entries[tripId];

  /// Total number of bookings (public + private). Drives the Profile
  /// "Trips" counter.
  static int get count => _entries.length;

  /// Synthetic-trip fields for private bookings (MyTripsCubit builds the
  /// public Trip models from these; no data is duplicated).
  static Iterable<_BookingEntry> get privateEntries =>
      _entries.entries.where((e) => e.value.kind == 'private').map((e) => e.value);

  static Iterable<MapEntry<String, _BookingEntry>> get privateRecords =>
      _entries.entries.where((e) => e.value.kind == 'private');
}

class _BookingEntry {
  final int seats;
  final double totalPaid;
  final String kind;
  final String status;
  final String? guideId;
  final String? title;
  final String? imageUrl;
  final String? dateLabel;
  final String? guideName;

  const _BookingEntry({
    required this.seats,
    required this.totalPaid,
    required this.kind,
    required this.status,
    this.guideId,
    this.title,
    this.imageUrl,
    this.dateLabel,
    this.guideName,
  });
}

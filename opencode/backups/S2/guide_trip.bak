import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// The admin approval state of a trip — exactly what Firestore stores.
///
/// This is the workflow field: only the admin dashboard moves a trip
/// from [pending] to [approved] or [rejected]. A guide publishes a trip
/// as [pending] and can never approve it themselves.
enum GuideTripApproval {
  /// Published, waiting for the admin to review it.
  pending,

  /// Approved and visible to tourists.
  approved,

  /// Rejected by the admin, with a reason.
  rejected,

  /// Withdrawn by the guide or the admin.
  cancelled,
}

/// The tab a trip belongs to in "My Trips".
enum GuideTripStatus { active, pending, rejected, completed, cancelled }

/// Reads a date that may arrive as a Firestore [Timestamp], a plain ISO
/// string (the mock dataset) or a [DateTime].
DateTime? parseGuideDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class GuideTrip {
  final String id;
  final String title;
  final String location;
  final String scheduleLabel;
  final double priceEgp;
  final String imageUrl;

  /// The admin approval state of the trip.
  final GuideTripApproval approval;

  /// How many travelers the trip accepts.
  final int capacity;

  /// How many seats are already booked.
  final int bookedSeats;

  /// Guide contact number for this trip (entered in Add/Edit Trip).
  final String phone;

  /// Rejected-state extras (null for all other states).
  final String? duration;
  final String? rejectionReason;

  /// The real moment the trip starts. `scheduleLabel` is only its
  /// human-readable form; Firestore stores this one and sorts on it.
  final DateTime? startAt;

  /// Wide cover image (details screen). Falls back to [imageUrl].
  final String coverUrl;

  /// Owner of the trip — the signed-in guide's uid in Firestore.
  final String guideId;

  const GuideTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.scheduleLabel,
    required this.priceEgp,
    required this.imageUrl,
    this.approval = GuideTripApproval.pending,
    this.capacity = 0,
    this.bookedSeats = 0,
    this.phone = '',
    this.duration,
    this.rejectionReason,
    this.startAt,
    this.coverUrl = '',
    this.guideId = '',
  });

  /// The tab this trip belongs to.
  ///
  /// Derived from the approval state: an approved trip is *active* until
  /// its date has passed and *completed* afterwards.
  GuideTripStatus get status {
    switch (approval) {
      case GuideTripApproval.pending:
        return GuideTripStatus.pending;
      case GuideTripApproval.rejected:
        return GuideTripStatus.rejected;
      case GuideTripApproval.cancelled:
        return GuideTripStatus.cancelled;
      case GuideTripApproval.approved:
        final start = startAt;
        if (start != null && start.isBefore(DateTime.now())) {
          return GuideTripStatus.completed;
        }
        return GuideTripStatus.active;
    }
  }

  /// Seats still available for booking.
  int get availableSeats => capacity - bookedSeats;

  /// Reads a trip document.
  ///
  /// Every field falls back to a default, so a document written by an
  /// older version of the app never breaks the whole list.
  factory GuideTrip.fromJson(Map<String, dynamic> json) {
    return GuideTrip(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      scheduleLabel: json['scheduleLabel'] as String? ?? '',
      priceEgp: (json['priceEgp'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      approval: GuideTripApproval.values.firstWhere(
        (e) => e.name == json['approvalStatus'],
        orElse: () => GuideTripApproval.pending,
      ),
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      bookedSeats: (json['bookedSeats'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      duration: json['duration'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      startAt: parseGuideDate(json['startAt']),
      coverUrl:
          json['coverUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      guideId: json['guideId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'scheduleLabel': scheduleLabel,
      'priceEgp': priceEgp,
      'imageUrl': imageUrl,
      'approvalStatus': approval.name,
      'capacity': capacity,
      'bookedSeats': bookedSeats,
      'phone': phone,
      'duration': duration,
      'rejectionReason': rejectionReason,
      'startAt': startAt?.toIso8601String(),
      'coverUrl': coverUrl,
      'guideId': guideId,
    };
  }
}

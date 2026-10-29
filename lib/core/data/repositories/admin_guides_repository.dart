import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../remote/firestore_service.dart';
import 'guide_trips_repository.dart';

/// One guide as the admin dashboard sees them.
class AdminGuide {
  /// The Firestore id of the guide (their `users/{uid}` document).
  final String uid;

  final String name;
  final String email;
  final String phone;

  /// The city the guide wrote in their profile.
  final String city;

  /// The kind of document they sent for the verification.
  final String document;

  /// `pending` | `approved` | `suspended`.
  final String status;

  /// When they submitted the documents.
  final String submitted;

  /// The name of the uploaded file.
  final String docFileName;

  /// The trips the guide published.
  final List<AdminGuideTrip> uploadedTrips;

  const AdminGuide({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.document,
    required this.status,
    required this.submitted,
    required this.docFileName,
    required this.uploadedTrips,
  });
}

/// One trip of a guide, as the admin dashboard lists it.
class AdminGuideTrip {
  final String title;
  final String status;

  const AdminGuideTrip({required this.title, required this.status});
}

/// Reads and decides the verification of the tour guides.
///
/// The guide submits their documents from the app; this is the other
/// half of that flow — the admin approves or rejects them, and the
/// decision is written back to the guide's document so the guide's
/// dashboard and profile pick it up.
class AdminGuidesRepository {
  AdminGuidesRepository({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  /// Firestore collection holding the users (and therefore the guides).
  static const String usersCollection = 'users';

  /// Firestore collection holding the verification submissions.
  static const String verificationsCollection = 'guideVerifications';

  /// Firestore collection holding the public guide profiles.
  static const String guidesCollection = 'guides';

  final FirestoreService _firestore;

  /// Every guide account, with their verification state.
  Future<List<AdminGuide>> fetchGuides() async {
    try {
      final users = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: 'guide')
          .get();
      final verifications = await _firestore
          .collection(verificationsCollection)
          .get();
      final trips = await _firestore
          .collection(GuideTripsRepository.tripsCollection)
          .get();
      final tripsByGuide = <String, List<AdminGuideTrip>>{};
      for (final doc in trips.docs) {
        final data = doc.data();
        final guideId = (data['guideId'] as String?) ?? '';
        if (guideId.isEmpty) continue;
        tripsByGuide
            .putIfAbsent(guideId, () => [])
            .add(
              AdminGuideTrip(
                title: (data['title'] as String?) ?? '',
                status: _tripStatus(
                  (data['approvalStatus'] as String?) ?? 'pending',
                ),
              ),
            );
      }
      final verificationByGuide = <String, Map<String, dynamic>>{};
      for (final doc in verifications.docs) {
        final data = doc.data();
        final rawGuideId = data['guideId'] as String?;
        final guideId = (rawGuideId != null && rawGuideId.isNotEmpty)
            ? rawGuideId
            : doc.id;
        final existing = verificationByGuide[guideId];
        // If an approved verification doc already exists, never overwrite it with a pending doc
        if (existing != null && existing['status'] == 'approved' && data['status'] != 'approved') {
          continue;
        }
        verificationByGuide[guideId] = data;
      }
      return users.docs
          .map(
            (doc) => _toGuide(
              doc,
              verificationByGuide[doc.id] ?? const {},
              tripsByGuide[doc.id] ?? const [],
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Real-time view of every guide account and its verification state.
  ///
  /// Re-emits the full guide list whenever the verifications OR users
  /// collection changes, so the admin dashboard stays in sync without a refresh.
  Stream<List<AdminGuide>> watchGuides() async* {
    final controller = StreamController<List<AdminGuide>>();

    void refresh() async {
      try {
        final guides = await fetchGuides();
        if (!controller.isClosed) {
          controller.add(guides);
        }
      } catch (_) {}
    }

    final subVerifications = _firestore
        .collection(verificationsCollection)
        .snapshots()
        .listen((_) => refresh());

    final subUsers = _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: 'guide')
        .snapshots()
        .listen((_) => refresh());

    refresh();

    controller.onCancel = () {
      subVerifications.cancel();
      subUsers.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  /// Approves or rejects a guide's verification documents.
  ///
  /// Writes the decision on the submission and the `isApproved` flag on
  /// the guide's profile, so the guide's dashboard and profile always
  /// agree and remain permanently in sync.
  Future<bool> decideVerification({
    required String guideId,
    required bool approve,
    String rejectionReason = '',
  }) async {
    try {
      final statusStr = approve ? 'approved' : 'rejected';

      // 1. Primary write: Update the user account in users/{guideId}
      // This is the persistent source of truth for auth, role, and approval.
      await _firestore.writeDoc(usersCollection, guideId, {
        'isApproved': approve,
        'status': statusStr,
        'isActive': approve,
        'verification': {
          'reviewStatus': statusStr,
        },
      });

      // 2. Update the public profile in guides/{guideId}
      try {
        await _firestore.writeDoc(guidesCollection, guideId, {
          'isApproved': approve,
          'status': statusStr,
          'isActive': approve,
        });
      } catch (_) {}

      // 3. Update the verification submission in guideVerifications/{guideId}
      try {
        await _firestore.writeDoc(verificationsCollection, guideId, {
          'guideId': guideId,
          'status': statusStr,
          'rejectionReason': approve ? '' : rejectionReason,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Non-fatal if guideVerifications document does not exist yet
        // or has restricted creation rules for non-guide actors.
      }

      // 4. Update any other submission docs matching this guideId
      try {
        final otherDocs = await _firestore
            .collection(verificationsCollection)
            .where('guideId', isEqualTo: guideId)
            .get();
        for (final doc in otherDocs.docs) {
          if (doc.id != guideId) {
            await _firestore.writeDoc(verificationsCollection, doc.id, {
              'status': statusStr,
              'rejectionReason': approve ? '' : rejectionReason,
              'reviewedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (_) {}

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Suspends a guide (they can no longer publish or be booked).
  Future<bool> suspendGuide(String guideId) async {
    try {
      await _firestore.writeDoc(usersCollection, guideId, {
        'isApproved': false,
        'isActive': false,
        'status': 'suspended',
        'verification': {
          'reviewStatus': 'rejected',
        },
      });

      try {
        await _firestore.writeDoc(guidesCollection, guideId, {
          'isApproved': false,
          'isActive': false,
          'status': 'suspended',
        });
      } catch (_) {}

      try {
        await _firestore.writeDoc(verificationsCollection, guideId, {
          'guideId': guideId,
          'status': 'rejected',
          'rejectionReason': 'Account suspended by admin',
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      return true;
    } catch (_) {
      return false;
    }
  }

  AdminGuide _toGuide(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> verification,
    List<AdminGuideTrip> trips,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final userIsApproved = (data['isApproved'] as bool?) == true ||
        (data['status'] as String?) == 'approved' ||
        (data['verification'] is Map &&
            data['verification']['reviewStatus'] == 'approved');

    final verStatus = (verification['status'] as String?)?.toLowerCase();

    // If either users collection or verification says approved, guide is permanently approved!
    final String status;
    if (userIsApproved || verStatus == 'approved') {
      status = 'approved';
    } else if (verStatus == 'rejected' ||
        (data['status'] as String?) == 'rejected' ||
        (data['status'] as String?) == 'suspended') {
      status = 'suspended';
    } else {
      status = 'pending';
    }

    final idUrl = (verification['idDocumentUrl'] as String?) ?? '';
    final licenseUrl = (verification['licenseDocumentUrl'] as String?) ?? '';

    return AdminGuide(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      city: (data['location'] as String?) ?? '',
      document: idUrl.isNotEmpty ? 'Tour Guide ID' : 'Syndicate Membership',
      status: _guideStatus(status, data['isActive'] as bool?),
      submitted: _submittedLabel(verification['submittedAt']),
      docFileName: _fileName(idUrl.isNotEmpty ? idUrl : licenseUrl),
      uploadedTrips: trips,
    );
  }

  /// The dashboard shows `suspended` for a rejected or blocked guide.
  String _guideStatus(String status, bool? isActive) {
    if (isActive == false) return 'suspended';
    switch (status) {
      case 'approved':
        return 'approved';
      case 'rejected':
      case 'suspended':
        return 'suspended';
      default:
        return 'pending';
    }
  }

  String _tripStatus(String approvalStatus) {
    switch (approvalStatus) {
      case 'approved':
        return 'Active';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending Review';
    }
  }

  /// The file name at the end of the uploaded URL.
  String _fileName(String url) {
    if (url.isEmpty) return '';
    final name = url.split('/').last.split('?').first;
    return name.isEmpty ? '' : name;
  }

  /// A readable "when they submitted" label.
  String _submittedLabel(Object? submittedAt) {
    if (submittedAt is Timestamp) {
      final value = submittedAt.toDate();
      final now = DateTime.now();
      final sameDay =
          value.year == now.year &&
          value.month == now.month &&
          value.day == now.day;
      if (sameDay) {
        final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
        final minute = value.minute.toString().padLeft(2, '0');
        return 'Today, $hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
      }
      return '${value.day}/${value.month}/${value.year}';
    }
    return '';
  }
}

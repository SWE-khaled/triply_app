import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:triply/core/firebase/firestore_converters.dart';

/// Canonical `guideVerifications/{verificationId}` document.
///
/// Stores Cloudinary document *references* (URLs + metadata), never bytes.
/// Only the owning guide may create/read; only admin (Functions) may decide.
class GuideVerificationDoc {
  final String id;
  final String guideId;
  final String idDocumentUrl;
  final String licenseDocumentUrl;
  final String status; // pending | approved | rejected
  final DateTime? submittedAt;
  final String? reviewerId;
  final DateTime? reviewedAt;
  final String rejectionReason;

  const GuideVerificationDoc({
    required this.id,
    required this.guideId,
    required this.idDocumentUrl,
    required this.licenseDocumentUrl,
    this.status = 'pending',
    this.submittedAt,
    this.reviewerId,
    this.reviewedAt,
    this.rejectionReason = '',
  });

  factory GuideVerificationDoc.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return GuideVerificationDoc.fromMap(d, doc.id);
  }

  factory GuideVerificationDoc.fromMap(Map<String, dynamic> d, String id) {
    // Backward compat: legacy `users/{uid}.verification{...}` map shape.
    final nested = d['verification'];
    final src = nested is Map ? Map<String, dynamic>.from(nested) : d;
    return GuideVerificationDoc(
      id: FirestoreConverters.toStr(d['id'], id),
      guideId: FirestoreConverters.toStr(
        d['guideId'] ?? d['userId'] ?? d['uid'],
      ),
      idDocumentUrl: FirestoreConverters.toStr(
        d['idDocumentUrl'] ?? src['idDocumentUrl'],
      ),
      licenseDocumentUrl: FirestoreConverters.toStr(
        d['licenseDocumentUrl'] ?? src['licenseDocumentUrl'],
      ),
      status: FirestoreConverters.toStr(
        d['status'] ?? src['reviewStatus'] ?? src['status'],
        'pending',
      ),
      submittedAt: FirestoreConverters.toDateTime(
        d['submittedAt'] ?? src['submittedAt'],
      ),
      reviewerId: d['reviewerId'] as String? ?? src['reviewerId'] as String?,
      reviewedAt: FirestoreConverters.toDateTime(
        d['reviewedAt'] ?? src['reviewedAt'],
      ),
      rejectionReason: FirestoreConverters.toStr(
        d['rejectionReason'] ?? src['rejectionReason'],
      ),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'guideId': guideId,
      'idDocumentUrl': idDocumentUrl,
      'licenseDocumentUrl': licenseDocumentUrl,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'rejectionReason': '',
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guideId': guideId,
      'idDocumentUrl': idDocumentUrl,
      'licenseDocumentUrl': licenseDocumentUrl,
      'status': status,
      'submittedAt': submittedAt,
      'reviewerId': reviewerId,
      'reviewedAt': reviewedAt,
      'rejectionReason': rejectionReason,
    };
  }
}

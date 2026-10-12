import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/mappers/firestore_mappers.dart';
import 'package:triply/data/firestore/models/app_settings_doc.dart';
import 'package:triply/data/firestore/models/app_user_doc.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/guide_profile_doc.dart';
import 'package:triply/data/firestore/models/guide_verification_doc.dart';
import 'package:triply/data/firestore/models/notification_doc.dart';
import 'package:triply/data/firestore/models/payment_doc.dart';
import 'package:triply/data/firestore/models/place_doc.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/models/review_doc.dart';
import 'package:triply/data/firestore/models/story_doc.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/features/tour_guide/my_trips_tg/model/guide_trip.dart';
import 'package:triply/features/tourist/guides/model/guide.dart' as guides_ui;
import 'package:triply/features/tourist/trips/models/trip.dart';

void main() {
  group('TripDoc', () {
    test('fromMap tolerates legacy mock keys + Timestamp dates', () {
      final doc = TripDoc.fromMap({
        'tripName': 'Nile Day',
        'price': 1000,
        'maxTravelers': '8',
        'status': 'approved',
        'imageUrl': 'http://img',
        'languages': 'English',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      }, 't1');
      expect(doc.id, 't1');
      expect(doc.title, 'Nile Day');
      expect(doc.priceEgp, 1000);
      expect(doc.capacity, 8);
      expect(doc.approvalStatus, 'approved');
      expect(doc.languages, ['English']);
      expect(doc.availableSeats, 8);
    });

    test('status mapping to both UI Trip models', () {
      // Default TripDoc() is `pending` → guide sees Pending, tourist sees
      // Upcoming (tourists only ever receive approved trips in queries).
      const pending = TripDoc(id: 'x', guideId: 'g', title: 'T');
      expect(
        FirestoreMappers.tripDocToTouristTrip(pending).status,
        TripStatus.upcoming,
      );
      expect(
        FirestoreMappers.tripDocToGuideTrip(pending).status,
        GuideTripStatus.pending,
      );
      const approved = TripDoc(
        id: 'x',
        guideId: 'g',
        title: 'T',
        approvalStatus: 'approved',
      );
      expect(
        FirestoreMappers.tripDocToGuideTrip(approved).status,
        GuideTripStatus.active,
      );
      const cancelled = TripDoc(
        id: 'x',
        guideId: 'g',
        title: 'T',
        approvalStatus: 'cancelled',
      );
      expect(
        FirestoreMappers.tripDocToTouristTrip(cancelled).status,
        TripStatus.cancelled,
      );
      expect(
        FirestoreMappers.tripDocToGuideTrip(
          const TripDoc(
            id: 'x',
            guideId: 'g',
            title: 'T',
            approvalStatus: 'pending',
          ),
        ).status,
        GuideTripStatus.pending,
      );
    });
    test('booking provenance: Firestore cards remote, mock JSON not', () {
      // Remote-mapped cards carry the exact server id and may be booked;
      // mock/offline JSON has no provenance flag and defaults to false, so
      // booking cubits refuse it early instead of hitting `not-found`.
      expect(
        FirestoreMappers.tripDocToTouristTrip(
          const TripDoc(id: 't9', guideId: 'g', title: 'T'),
        ).isRemote,
        isTrue,
      );
      expect(
        FirestoreMappers.guideProfileToGuide(
          const GuideProfileDoc(userId: 'g9'),
          displayName: 'G',
        ).isRemote,
        isTrue,
      );
      expect(
        Trip.fromJson({
          'id': 't1',
          'title': 'T',
          'dateLabel': 'x',
          'guideName': 'G',
          'peopleCount': 0,
          'priceEgp': 1,
          'imageUrl': '',
          'status': 'upcoming',
        }).isRemote,
        isFalse,
      );
      expect(
        guides_ui.Guide.fromJson({
          'id': 'g1',
          'name': 'G',
          'specialty': 'S',
          'languages': <String>[],
          'rating': 5,
          'review_count': 1,
          'price_per_hour': 1,
        }).isRemote,
        isFalse,
      );
    });
    test('SECURITY: client create payload excludes server-owned fields', () {
      const doc = TripDoc(
        id: 'x',
        guideId: 'g',
        title: 'T',
        bookedSeats: 99,
        approvalStatus: 'approved',
        rejectionReason: 'x',
      );
      final payload = doc.toCreateMap();
      expect(payload.containsKey('bookedSeats'), isFalse);
      expect(payload.containsKey('approvalStatus'), isFalse);
      expect(payload.containsKey('rejectionReason'), isFalse);
      expect(payload['guideId'], 'g');
    });

    test('rating aggregates carried (onReviewWritten) + mapped to details', () {
      final doc = TripDoc.fromMap({
        'title': 'Nile Day',
        'approvalStatus': 'approved',
        'rating': 4.5,
        'reviewsCount': 12,
      }, 't1');
      expect(doc.rating, 4.5);
      expect(doc.reviewsCount, 12);
      final details = FirestoreMappers.tripDocToTripDetails(doc);
      expect(details.tripId, 't1');
      expect(details.rating, 4.5);
      expect(details.reviewsCount, 12);
      // Absent until the first review: honest zeros, not invented ratings.
      const unrated = TripDoc(id: 'u', guideId: 'g', title: 'T');
      final unratedDetails = FirestoreMappers.tripDocToTripDetails(unrated);
      expect(unratedDetails.rating, 0);
      expect(unratedDetails.reviewsCount, 0);
    });

    test('tripDocToPlaceTrip keeps the real trip id for Details', () {
      const doc = TripDoc(
        id: 'trip-9',
        guideId: 'g',
        guideName: 'Omar',
        placeId: 'giza_pyramids',
        title: 'Dawn Tour',
        dateLabel: 'Oct 15',
        priceEgp: 6000,
        capacity: 10,
        bookedSeats: 6,
        coverImageUrl: 'http://img',
      );
      final mapped = FirestoreMappers.tripDocToPlaceTrip(doc);
      expect(mapped.id, 'trip-9');
      expect(mapped.placeId, 'giza_pyramids');
      expect(mapped.title, 'Dawn Tour');
      expect(mapped.dateTime, 'Oct 15');
      expect(mapped.guideName, 'Omar');
      expect(mapped.peopleCount, 6);
      expect(mapped.price, 6000);
      expect(mapped.currency, 'EGP');
      expect(mapped.imageUrl, 'http://img');
    });
  });

  group('PlaceDoc', () {
    test('GeoPoint preferred; nameLower/cityLower written', () {
      final doc = PlaceDoc.fromMap({
        'name': 'Giza Pyramids',
        'city': 'Giza',
        'geo': const GeoPoint(29.97, 31.13),
        'rating': 4,
        'image_url': 'http://img',
      }, 'giza_pyramids');
      expect(doc.latitude, 29.97);
      final map = doc.toMap();
      expect(map['geo'], isA<GeoPoint>());
      expect(map['nameLower'], 'giza pyramids');
      expect(FirestoreMappers.placeDocToMapPlace(doc).id, 'giza_pyramids');
    });
  });

  group('BookingDoc', () {
    test('distinguishes created date from trip date; legacy keys read', () {
      final doc = BookingDoc.fromMap({
        'touristId': 'u1',
        'bookingType': 'public',
        'tripId': 't1',
        'guideId': 'g1',
        'travelers': 3,
        'totalPaid': 500,
        'dateLabel': '2026-11-02',
      }, 'b1');
      expect(doc.isPublic, isTrue);
      expect(doc.seats, 3);
      expect(doc.totalAmount, 500);
      expect(doc.tripDate, DateTime(2026, 11, 2));
      expect(doc.createdAt, isNull);
    });

    test('SECURITY: client payload carries no totals or status', () {
      const doc = BookingDoc(
        id: 'b',
        touristId: 'u',
        bookingType: 'public',
        guideId: 'g',
        totalAmount: 9999,
        status: 'confirmed',
      );
      final payload = doc.toCreateMap();
      expect(payload.containsKey('totalAmount'), isFalse);
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('paymentStatus'), isFalse);
    });
  });

  group('GuideVerificationDoc', () {
    test('reads legacy users/{uid}.verification map shape', () {
      final doc = GuideVerificationDoc.fromMap({
        'verification': {
          'idDocumentUrl': 'http://id',
          'licenseDocumentUrl': 'http://lic',
          'reviewStatus': 'pending',
        },
      }, 'g1');
      expect(doc.status, 'pending');
      expect(doc.idDocumentUrl, 'http://id');
      expect(doc.toCreateMap()['status'], 'pending');
    });
  });

  group('AppUserDoc + GuideProfileDoc security', () {
    test('user client payload excludes role/isActive', () {
      const doc = AppUserDoc(
        uid: 'u',
        fullName: 'N',
        email: 'e',
        phone: 'p',
        role: 'admin',
      );
      final payload = doc.toClientMap();
      expect(payload.containsKey('role'), isFalse);
      expect(payload.containsKey('isActive'), isFalse);
    });

    test('guide client payload excludes verification + ratings', () {
      const doc = GuideProfileDoc(
        userId: 'g',
        isVerified: true,
        canPublishTrips: true,
        ratingAvg: 5,
        ratingCount: 9,
      );
      final payload = doc.toClientMap();
      expect(payload.containsKey('isVerified'), isFalse);
      expect(payload.containsKey('canPublishTrips'), isFalse);
      expect(payload.containsKey('ratingAvg'), isFalse);
      expect(payload.containsKey('ratingCount'), isFalse);
    });
  });

  group('PaymentDoc', () {
    test('SECURITY: client create forces pending; no card fields exist', () {
      const doc = PaymentDoc(
        id: 'p',
        bookingId: 'b',
        touristId: 'u',
        status: 'succeeded',
      );
      final payload = doc.toCreateMap();
      expect(payload['status'], 'pending');
      final keys = payload.keys.join(',');
      expect(keys.contains('card'), isFalse);
      expect(keys.contains('cvv'), isFalse);
      expect(keys.contains('pan'), isFalse);
    });
  });

  group('Posts / stories / notifications', () {
    test('post merges legacy image keys; like counts never client-written', () {
      final doc = PostDoc.fromMap({
        'authorId': 'u',
        'image_url': 'http://i',
        'text': 'hi',
      }, 'p1');
      expect(doc.imageUrls, ['http://i']);
      expect(doc.toCreateMap().containsKey('likesCount'), isFalse);
      final post = FirestoreMappers.postDocToPost(doc, currentUid: 'u');
      expect(post.isMine, isTrue);
    });

    test('story expiry helper; recipient-only notification mapping', () {
      final expired = StoryDoc(
        id: 's',
        userId: 'u',
        mediaUrl: 'm',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expired.isExpired, isTrue);
      final item = FirestoreMappers.notificationDocToItem(
        const NotificationDoc(
          id: 'n',
          userId: 'u',
          title: 'T',
          message: 'M',
          isRead: false,
        ),
      );
      expect(item.isRead, isFalse);
      expect(item.body, 'M');
    });

    test('story toCreateMap writes Timestamp expiry (query-compatible)', () {
      // Regression test for the string-vs-Timestamp expiry break: readers
      // and the scheduled cleanup compare `expiresAt` against
      // Timestamp.now(), and cross-type comparisons never match.
      final before = DateTime.now().toUtc();
      final payload = const StoryDoc(
        id: '',
        userId: 'u',
        mediaUrl: 'm',
      ).toCreateMap();
      expect(payload['expiresAt'], isA<Timestamp>());
      final expiry = (payload['expiresAt'] as Timestamp).toDate();
      expect(expiry.isAfter(before.add(const Duration(hours: 23))), isTrue);
      expect(expiry.isBefore(before.add(const Duration(hours: 25))), isTrue);
    });

    test('story fromMap still reads legacy ISO-string expiries', () {
      final doc = StoryDoc.fromMap({
        'userId': 'u',
        'mediaUrl': 'm',
        'expiresAt': '2026-11-02T10:00:00.000Z',
      }, 's1');
      expect(doc.expiresAt, DateTime.utc(2026, 11, 2, 10));
    });

    test(
      'guide profile carries public contact fields; server flags excluded',
      () {
        final doc = GuideProfileDoc.fromMap({
          'userId': 'g1',
          'displayName': 'Omar',
          'contactPhone': '+2010',
          'isVerified': true,
        }, 'g1');
        expect(doc.displayName, 'Omar');
        expect(doc.contactPhone, '+2010');
        final payload = doc.toClientMap();
        expect(payload['displayName'], 'Omar');
        expect(payload['contactPhone'], '+2010');
        expect(payload.containsKey('isVerified'), isFalse);
        expect(payload.containsKey('ratingAvg'), isFalse);
      },
    );
  });

  group('Reviews + settings (roadmap)', () {
    test('review id is tripId_touristId; rating clamped 1..5', () {
      expect(ReviewDoc.docIdFor('t', 'u'), 't_u');
      expect(ReviewDoc.fromMap({'rating': 99}, 't_u').rating, 5);
      expect(ReviewDoc.fromMap({'rating': -2}, 't_u').rating, 1);
    });

    test('operational settings fall back to safe defaults', () {
      const s = OperationalSettings();
      expect(s.serviceFeeRate, 0.05);
      expect(s.currency, 'EGP');
      final fromDocs = OperationalSettings.fromDocs([
        const AppSettingsDoc(id: 'serviceFeeRate', value: 0.07),
      ]);
      expect(fromDocs.serviceFeeRate, 0.07);
      expect(fromDocs.currency, 'EGP');
    });
  });

  group('status vocabularies', () {
    test('only known values accepted by convention', () {
      expect(
        FirestoreStatuses.tripApproval,
        containsAll(['pending', 'approved', 'rejected', 'cancelled']),
      );
      expect(
        FirestoreStatuses.booking,
        containsAll(['pending', 'confirmed', 'completed', 'cancelled']),
      );
    });
  });
}

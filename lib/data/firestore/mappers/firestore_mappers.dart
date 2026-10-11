import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/models/guide_profile_doc.dart';
import 'package:triply/data/firestore/models/notification_doc.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/model/guide_notification.dart';
import 'package:triply/data/firestore/models/place_doc.dart';
import 'package:triply/data/firestore/models/post_doc.dart';
import 'package:triply/data/firestore/models/story_doc.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/features/tourist/booking_public/model/booking_public.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';
import 'package:triply/features/tourist/guides/model/guide.dart' as guides_ui;
import 'package:triply/features/tourist/map/model/place.dart' as map_ui;
import 'package:triply/features/tourist/notifications/model/notification_item.dart';
import 'package:triply/features/tourist/place_details/model/trip.dart'
    as place_ui;
import 'package:triply/features/tourist/trip_details/model/trip_details.dart';
import 'package:triply/features/tourist/trips/models/trip.dart' as trips_ui;
import 'package:triply/features/tour_guide/my_trips_tg/model/guide_trip.dart'
    as guide_ui;

/// Pure mappers: canonical Firestore docs → existing UI models.
///
/// No Firestore I/O here. Cubits keep consuming the SAME UI models, so no
/// View changes are needed. Status mapping is explicit:
/// - Firestore `approvalStatus` pending/approved/rejected/cancelled
/// - Tourist `TripStatus` upcoming/ongoing/completed/cancelled (tourists only
///   ever receive approved trips → upcoming unless cancelled)
/// - Guide `GuideTripStatus` active/pending/rejected/completed/cancelled
///   (approved → active; mirrors the current mock `active` tab).
class FirestoreMappers {
  FirestoreMappers._();

  // ── Trips ──

  static trips_ui.Trip tripDocToTouristTrip(TripDoc d) {
    return trips_ui.Trip(
      id: d.id,
      title: d.title,
      dateLabel: d.dateLabel,
      guideName: d.guideName,
      peopleCount: d.bookedSeats,
      priceEgp: d.priceEgp,
      imageUrl: d.coverImageUrl.isNotEmpty
          ? d.coverImageUrl
          : (d.imageUrls.isNotEmpty ? d.imageUrls.first : ''),
      status: d.approvalStatus == 'cancelled'
          ? trips_ui.TripStatus.cancelled
          : trips_ui.TripStatus.upcoming,
      category: d.category,
      capacity: d.capacity,
    );
  }

  static guide_ui.GuideTrip tripDocToGuideTrip(TripDoc d) {
    return guide_ui.GuideTrip(
      id: d.id,
      title: d.title,
      location: d.location,
      scheduleLabel: d.dateLabel.isEmpty ? 'To be announced' : d.dateLabel,
      priceEgp: d.priceEgp,
      imageUrl: d.coverImageUrl,
      status: switch (d.approvalStatus) {
        'pending' => guide_ui.GuideTripStatus.pending,
        'rejected' => guide_ui.GuideTripStatus.rejected,
        'cancelled' => guide_ui.GuideTripStatus.cancelled,
        'completed' => guide_ui.GuideTripStatus.completed,
        _ => guide_ui.GuideTripStatus.active,
      },
      duration: d.duration.isEmpty ? null : d.duration,
      rejectionReason: d.rejectionReason.isEmpty ? null : d.rejectionReason,
    );
  }

  static TripDetails tripDocToTripDetails(TripDoc d) {
    return TripDetails(
      id: 'details-${d.id}',
      tripId: d.id,
      tag: d.category,
      title: d.title,
      // Aggregates written by `onReviewWritten`; 0/0 until the first review.
      // Guide card stays zeroed: guide rating/avatar live in `guideProfiles`
      // (separate collection) and are enriched in a later phase.
      rating: d.rating < 0 ? 0 : d.rating,
      reviewsCount: d.reviewsCount < 0 ? 0 : d.reviewsCount,
      location: d.location,
      duration: d.duration,
      groupType: d.capacity > 1 ? 'Group' : 'Private',
      languages: d.languages.isEmpty ? 'English' : d.languages.join(', '),
      about: d.description,
      highlights: d.highlights,
      itinerary: d.itinerary
          .map(
            (e) => ItineraryStop(
              time: (e['time'] ?? '').toString(),
              title: (e['title'] ?? e['activity'] ?? '').toString(),
            ),
          )
          .toList(),
      notes: d.notes,
      meetingPoint: d.meetingPoint,
      priceEgp: d.priceEgp,
      guideName: d.guideName,
      guideAvatarUrl: '',
      guideRating: 0,
      guideReviews: 0,
      topRatedGuide: false,
      imageUrl: d.coverImageUrl,
    );
  }

  // ── Place Details Trips tab ──

  /// `trips/` doc → Place Details tab model. Same trip record tourists open
  /// from the Trips feed (real id flows through `publicTripFor` to Details).
  static place_ui.Trip tripDocToPlaceTrip(TripDoc d) {
    return place_ui.Trip(
      id: d.id,
      placeId: d.placeId,
      title: d.title,
      dateTime: d.dateLabel,
      guideName: d.guideName,
      peopleCount: d.bookedSeats,
      price: d.priceEgp,
      currency: d.currency,
      imageUrl: d.coverImageUrl.isNotEmpty
          ? d.coverImageUrl
          : (d.imageUrls.isNotEmpty ? d.imageUrls.first : ''),
    );
  }

  // ── Places ──

  static map_ui.Place placeDocToMapPlace(PlaceDoc d) {
    return map_ui.Place(
      id: d.id,
      name: d.name,
      city: d.city,
      category: d.category,
      type: d.type,
      address: d.address,
      latitude: d.latitude,
      longitude: d.longitude,
      rating: d.rating,
      reviewsCount: d.reviewsCount,
      shortDescription: d.shortDescription,
      about: d.about,
      highlights: d.highlights,
      imageUrl: d.imageUrl,
    );
  }

  // ── Guides ──

  static guides_ui.Guide guideProfileToGuide(
    GuideProfileDoc p, {
    required String displayName,
    String avatarUrl = '',
  }) {
    return guides_ui.Guide(
      id: p.userId,
      name: displayName,
      specialty: p.specialty,
      avatarUrl: avatarUrl,
      coverUrl: p.coverUrl,
      location: p.location,
      about: p.about,
      languages: p.languages,
      rating: p.ratingAvg,
      reviewCount: p.ratingCount,
      pricePerHour: p.pricePerHour,
      currency: p.currency,
      isVerified: p.isVerified,
    );
  }

  // ── Community ──

  static CommunityPost postDocToPost(PostDoc d, {required String currentUid}) {
    return CommunityPost(
      id: d.id,
      authorName: d.authorName,
      authorAvatarUrl: d.authorAvatarUrl,
      timeAgo: _timeAgo(d.createdAt),
      location: d.location,
      imageUrl: d.imageUrls.isEmpty ? '' : d.imageUrls.first,
      imageUrls: d.imageUrls,
      text: d.text,
      likesCount: d.likesCount,
      commentsCount: d.commentsCount,
      isMine: d.authorId == currentUid,
    );
  }

  static CommunityStory storyDocToStory(
    StoryDoc d, {
    required String currentUid,
  }) {
    return CommunityStory(
      id: d.id,
      userId: d.userId,
      userName: d.userId == currentUid ? 'You' : d.userName,
      imageUrl: d.mediaUrl,
      isMine: d.userId == currentUid,
    );
  }

  // ── Notifications ──

  static NotificationItem notificationDocToItem(NotificationDoc d) {
    return NotificationItem(
      id: d.id,
      type: d.type,
      title: d.title,
      body: d.message,
      timeLabel: _timeAgo(d.createdAt),
      isRead: d.isRead,
      section: _sectionFor(d.createdAt),
    );
  }

  /// Same server record for the guide list (which uses its own card
  /// model). Read state + relative time carry over so badges stay honest.
  static GuideNotification notificationDocToGuideNotification(
    NotificationDoc d,
  ) {
    return GuideNotification(
      id: d.id,
      type: d.type,
      title: d.title,
      body: d.message,
      isRead: d.isRead,
      timeLabel: _timeAgo(d.createdAt),
    );
  }

  // ── Bookings ──

  /// Synthetic public-booking confirmation for the existing
  /// `BookingConfirmedScreen` flow (seats/total only; authoritative record
  /// lives in `bookings/{id}`).
  static BookingPublic bookingDocToBookingPublic(BookingDoc d) {
    return BookingPublic(
      tripId: d.tripId ?? d.id,
      seats: d.seats,
      specialRequests: d.specialRequests,
      unitPrice: d.unitPrice,
      serviceFee: d.serviceFee,
      total: d.totalAmount,
    );
  }

  static String _timeAgo(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Today/Earlier bucketing for the notifications screen sections.
  /// Missing timestamps land in 'earlier' (visible, never dropped).
  static String _sectionFor(DateTime? t) {
    if (t == null) return 'earlier';
    final now = DateTime.now();
    final local = t.toLocal();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'today';
    }
    return 'earlier';
  }
}

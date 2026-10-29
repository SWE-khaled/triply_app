import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/data/guide_trip_details_source.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../../../../core/helper/schedule_format.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../../trip_details_tg/model/guide_trip_details.dart';
import '../model/guide_trip_draft.dart';

part 'create_trip_state.dart';

/// The text the guide typed in the static fields of the form.
///
/// The View owns the controllers and hands this snapshot to the cubit
/// when it previews or submits. Every value is already trimmed.
class TripFormData {
  final String name;
  final String about;
  final String location;
  final String label;

  /// `d/m/yyyy`, as the date picker writes it.
  final String date;

  /// `h:mm AM/PM`, as the time picker writes it.
  final String time;
  final String endTime;
  final String duration;
  final String price;
  final String maxTravelers;
  final String meeting;
  final String included;
  final String notes;
  final String languages;
  final String phone;

  const TripFormData({
    required this.name,
    required this.about,
    required this.location,
    required this.label,
    required this.date,
    required this.time,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.maxTravelers,
    required this.meeting,
    required this.included,
    required this.notes,
    required this.languages,
    required this.phone,
  });

  /// The moment the trip starts, parsed from the date + time fields.
  ///
  /// Returns null when the guide did not pick a date.
  DateTime? get startAt {
    if (date.isEmpty) return null;
    final parts = date.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0].trim());
    final month = int.tryParse(parts[1].trim());
    final year = int.tryParse(parts[2].trim());
    if (day == null || month == null || year == null) return null;

    final parsed = _parseTime(time);
    final hour = parsed?.$1 ?? 0;
    final minute = parsed?.$2 ?? 0;
    return DateTime(year, month, day, hour, minute);
  }

  DateTime? get endAt {
    final starts = startAt;
    final parsed = _parseTime(endTime);
    if (starts == null || parsed == null) return null;
    return DateTime(
      starts.year,
      starts.month,
      starts.day,
      parsed.$1,
      parsed.$2,
    );
  }

  String? get durationLabel {
    final starts = startAt;
    final ends = endAt;
    if (starts == null || ends == null) return null;
    final hours = ends.difference(starts).inHours;
    if (hours <= 0) return null;
    if (hours == 8) return 'Full Day';
    return '$hours hours';
  }

  static (int hour, int minute)? _parseTime(String text) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM|ص|م)$',
      caseSensitive: false,
    ).firstMatch(text.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final marker = match.group(3)!.toUpperCase();
    final isPm = marker == 'PM' || marker == 'م';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return (hour, minute);
  }

  /// The notes, one per line, without the empty ones.
  List<String> get noteLines => notes
      .split('\n')
      .map((n) => n.trim())
      .where((n) => n.isNotEmpty)
      .toList();
}

/// Owns the dynamic part of the Create Trip form: the Highlights and
/// Itinerary rows and the cover.
///
/// The text controllers of the static fields live in the View; the cubit
/// receives their content as a [TripFormData] when it needs it.
/// No validation UI here — [submitTrip] and [saveEdit] return a message
/// and the View shows it.
///
/// Submitting writes the trip to Firestore through [GuideTripsRepository]
/// and keeps a session copy so the list updates instantly.
class CreateTripCubit extends Cubit<CreateTripState>
    with SafeEmitMixin<CreateTripState> {
  int _nextId = 1;

  final GuideTripsRepository _repository;

  CreateTripCubit({GuideTripsRepository? repository})
    : _repository = repository ?? GuideTripsRepository(),
      super(const CreateTripInitial());

  /// Re-emits the current form content — the dynamic rows changed.
  void _emitForm() {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
  }

  void updateHighlight(String id, String v) {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights
            .map((h) => h.id == id ? h.copyWith(text: v) : h)
            .toList(),
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
  }

  void addHighlight() {
    safeEmit(
      CreateTripSuccess(
        highlights: [
          ...state.highlights,
          HighlightDraft(id: 'h${_nextId++}', text: ''),
        ],
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
  }

  void removeHighlight(String id) {
    if (state.highlights.length <= 1) return;
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights.where((h) => h.id != id).toList(),
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
  }

  void updateStopTime(String id, String v) {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: state.itinerary
            .map((s) => s.id == id ? s.copyWith(time: v) : s)
            .toList(),
        cover: state.cover,
      ),
    );
  }

  void updateStopActivity(String id, String v) {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: state.itinerary
            .map((s) => s.id == id ? s.copyWith(activity: v) : s)
            .toList(),
        cover: state.cover,
      ),
    );
  }

  void addStop() {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: [
          ...state.itinerary,
          ItineraryStopDraft(id: 's${_nextId++}', time: '', activity: ''),
        ],
        cover: state.cover,
      ),
    );
  }

  void removeStop(String id) {
    if (state.itinerary.length <= 1) return;
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: state.itinerary.where((s) => s.id != id).toList(),
        cover: state.cover,
      ),
    );
  }

  /// Picks a gallery cover for local preview only.
  Future<String?> pickCoverImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return null;
      safeEmit(
        CreateTripSuccess(
          highlights: state.highlights,
          itinerary: state.itinerary,
          cover: file.path,
        ),
      );
      return null;
    } catch (_) {
      return 'Could not open the gallery';
    }
  }

  void removeCoverImage() {
    safeEmit(
      CreateTripSuccess(
        highlights: state.highlights,
        itinerary: state.itinerary,
        cover: null,
      ),
    );
  }

  /// Pre-fills the dynamic part of the form for editing.
  ///
  /// The text fields are filled by the View. The cover the trip already
  /// has is kept, so the guide sees the current image and only replaces
  /// it by picking a new one.
  void prefill(GuideTripDetails details) {
    safeEmit(
      CreateTripSuccess(
        highlights: details.highlights
            .asMap()
            .entries
            .map((e) => HighlightDraft(id: 'h${e.key}', text: e.value))
            .toList(),
        itinerary: details.itinerary
            .asMap()
            .entries
            .map(
              (e) => ItineraryStopDraft(
                id: 's${e.key}',
                time: e.value.time,
                activity: e.value.title,
              ),
            )
            .toList(),
        cover: details.imageUrl,
      ),
    );
  }

  /// Builds the entered trip for preview/submit. Not stored.
  GuideTrip buildTrip(TripFormData form, {String? coverUrl}) {
    final price = double.tryParse(form.price) ?? 0;
    final starts = form.startAt;
    final cover =
        coverUrl ??
        state.cover ??
        'https://picsum.photos/seed/${form.name.hashCode}/300/400';
    return GuideTrip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      title: form.name,
      location: form.location.isEmpty ? 'Egypt' : form.location,
      scheduleLabel: starts == null
          ? 'To be announced'
          : formatScheduleLabel(starts),
      priceEgp: price,
      imageUrl: cover,
      coverUrl: cover,
      // A guide always publishes a trip as pending — the admin dashboard
      // is what approves it.
      approval: GuideTripApproval.pending,
      capacity: int.tryParse(form.maxTravelers) ?? 0,
      phone: form.phone,
      startAt: starts,
      endAt: form.endAt,
      duration: form.durationLabel,
    );
  }

  /// Returns an error message, or null when the draft is submittable.
  String? validate(TripFormData form) {
    if (form.name.isEmpty) {
      return 'Please enter the trip name';
    }
    if (form.price.isEmpty) {
      return 'Please enter the price per person';
    }
    // The capacity is what limits the bookings, so it has to be a real
    // number — Firestore refuses a trip with a capacity of zero.
    final capacity = int.tryParse(form.maxTravelers) ?? 0;
    if (capacity <= 0) {
      return 'Please enter the maximum number of travelers';
    }
    // A trip must have a real start and end moment so tourists can book it.
    final starts = form.startAt;
    final ends = form.endAt;
    if (starts == null) {
      return 'Please pick the trip date and start time';
    }
    if (ends == null) {
      return 'Please pick the end time';
    }
    // End time must be after the start time on the same day — never roll
    // over to the next day.
    if (!ends.isAfter(starts)) {
      return 'End time must be after the start time.';
    }
    return null;
  }

  /// Uploads the picked cover so the stored image is a real URL.
  ///
  /// A cover that is already a URL (the one the trip has) is returned as
  /// it is. A local file is uploaded, and the local path is returned when
  /// the upload is not possible — so a network problem never blocks the
  /// guide from submitting a trip.
  Future<String> _resolveCoverUrl() async {
    final cover = state.cover;
    if (cover == null || cover.isEmpty) return '';
    if (cover.startsWith('http')) return cover;
    try {
      final file = File(cover);
      if (!file.existsSync()) return cover;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      return await CloudinaryService().uploadFileAtPath(cover, uid);
    } catch (_) {
      return cover;
    }
  }

  /// Saves form edits over an existing trip+details.
  ///
  /// Writes to Firestore and keeps the session copy in sync.
  /// Returns an error message, or null on success.
  Future<String?> saveEdit({
    required TripFormData form,
    required GuideTrip existingTrip,
    required GuideTripDetails existingDetails,
  }) async {
    final error = validate(form);
    if (error != null) {
      safeEmit(
        CreateTripError(
          highlights: state.highlights,
          itinerary: state.itinerary,
          cover: state.cover,
          error: error,
        ),
      );
      return error;
    }
    final price = double.tryParse(form.price) ?? existingTrip.priceEgp;
    final starts = form.startAt;
    final ends = form.endAt;
    final duration = form.durationLabel;
    // The guide removed the cover when there is no cover left in the
    // form — the trip had one when the form opened.
    final removed = state.cover == null;
    final cover = await _resolveCoverUrl();
    final imageUrl = cover.isNotEmpty
        ? cover
        : (removed ? '' : existingTrip.imageUrl);
    // A rejected trip goes back for review when the guide edits it.
    final isResubmit = existingTrip.approval == GuideTripApproval.rejected;
    final trip = GuideTrip(
      id: existingTrip.id,
      title: form.name,
      location: form.location.isEmpty ? existingTrip.location : form.location,
      scheduleLabel: starts == null
          ? existingTrip.scheduleLabel
          : formatScheduleLabel(starts),
      priceEgp: price,
      imageUrl: imageUrl,
      coverUrl: imageUrl,
      approval: isResubmit ? GuideTripApproval.pending : existingTrip.approval,
      capacity: int.tryParse(form.maxTravelers) ?? existingTrip.capacity,
      bookedSeats: existingTrip.bookedSeats,
      phone: form.phone.isEmpty ? existingTrip.phone : form.phone,
      startAt: starts ?? existingTrip.startAt,
      endAt: ends ?? existingTrip.endAt,
      duration: duration ?? existingTrip.duration,
      rejectionReason: isResubmit ? null : existingTrip.rejectionReason,
      guideId: existingTrip.guideId,
    );
    GuideTripsStore.update(trip);
    final details = GuideTripDetails(
      id: existingDetails.id,
      tripId: existingDetails.tripId,
      tag: existingDetails.tag,
      title: form.name,
      rating: existingDetails.rating,
      reviewsCount: existingDetails.reviewsCount,
      location: form.location.isEmpty
          ? existingDetails.location
          : form.location,
      duration: duration ?? existingDetails.duration,
      groupType: existingDetails.groupType,
      languages: form.languages.isEmpty
          ? existingDetails.languages
          : form.languages,
      about: form.about,
      highlights: state.highlights
          .map((h) => h.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      itinerary: state.itinerary
          .where(
            (s) => s.time.trim().isNotEmpty || s.activity.trim().isNotEmpty,
          )
          .map(
            (s) => GuideItineraryStop(
              time: s.time.trim(),
              title: s.activity.trim(),
            ),
          )
          .toList(),
      notes: form.notes.isEmpty ? existingDetails.notes : form.noteLines,
      included: form.included.isEmpty
          ? existingDetails.included
          : form.included,
      meetingPoint: form.meeting.isEmpty
          ? existingDetails.meetingPoint
          : form.meeting,
      priceEgp: price,
      guideName: existingDetails.guideName,
      guideAvatarUrl: existingDetails.guideAvatarUrl,
      guideRating: existingDetails.guideRating,
      guideReviews: existingDetails.guideReviews,
      imageUrl: imageUrl,
    );
    GuideTripDetailsSource.save(details);
    safeEmit(
      CreateTripLoading(
        highlights: state.highlights,
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
    try {
      await _repository.updateTrip(trip: trip, details: details);
    } catch (e) {
      // Same as creating: the edit is kept in the session, but the guide
      // is told it did not reach the cloud.
      _emitForm();
      return 'Could not save the changes: ${_reason(e)}';
    }
    _emitForm();
    return null;
  }

  /// Validates, stores as pending, returns the created trip.
  ///
  /// Also saves the entered details so View/Edit read this exact trip
  /// (same source of truth, no mock fallback), and writes both to
  /// Firestore. Returns null + error message when invalid.
  Future<({GuideTrip? trip, String? error})> submitTrip(
    TripFormData form,
  ) async {
    final error = validate(form);
    if (error != null) {
      safeEmit(
        CreateTripError(
          highlights: state.highlights,
          itinerary: state.itinerary,
          cover: state.cover,
          error: error,
        ),
      );
      return (trip: null, error: error);
    }
    final cover = await _resolveCoverUrl();
    final trip = buildTrip(form, coverUrl: cover.isEmpty ? null : cover);
    GuideTripsStore.add(trip);
    final details = _buildDetails(trip, form);
    GuideTripDetailsSource.save(details);
    safeEmit(
      CreateTripLoading(
        highlights: state.highlights,
        itinerary: state.itinerary,
        cover: state.cover,
      ),
    );
    try {
      await _repository.createTrip(trip: trip, details: details);
    } catch (e) {
      // The write was refused (a rule, or no connection). Say so instead
      // of letting the trip live only in the session and vanish on the
      // next sign-out.
      _emitForm();
      return (trip: null, error: 'Could not save the trip: ${_reason(e)}');
    }
    _emitForm();
    return (trip: trip, error: null);
  }

  /// A short, readable reason for a failed write.
  String _reason(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied') ||
        text.contains('PERMISSION_DENIED')) {
      return 'the security rules refused it';
    }
    if (text.contains('unavailable') || text.contains('UNAVAILABLE')) {
      return 'no connection to the cloud';
    }
    return text;
  }

  /// Builds the trip and its details for the preview screen.
  ///
  /// The details are cached in the session, because the trip is not
  /// published yet — the preview reads them back from there.
  ({GuideTrip trip, GuideTripDetails details}) buildPreview(TripFormData form) {
    final trip = buildTrip(form);
    final details = _buildDetails(trip, form);
    GuideTripDetailsSource.save(details);
    return (trip: trip, details: details);
  }

  /// Builds the long-form details of [trip] from the form.
  GuideTripDetails _buildDetails(GuideTrip trip, TripFormData form) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return GuideTripDetails(
      id: 'details-${trip.id}',
      tripId: trip.id,
      tag: form.label,
      title: trip.title,
      rating: 0,
      reviewsCount: 0,
      location: trip.location,
      duration: form.durationLabel ?? form.duration,
      groupType: '',
      languages: form.languages,
      about: form.about,
      highlights: state.highlights
          .map((h) => h.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      itinerary: state.itinerary
          .where(
            (s) => s.time.trim().isNotEmpty || s.activity.trim().isNotEmpty,
          )
          .map(
            (s) => GuideItineraryStop(
              time: s.time.trim(),
              title: s.activity.trim(),
            ),
          )
          .toList(),
      notes: form.noteLines,
      included: form.included,
      meetingPoint: form.meeting,
      priceEgp: trip.priceEgp,
      guideName: firebaseUser?.displayName?.trim() ?? '',
      guideAvatarUrl: firebaseUser?.photoURL?.trim() ?? '',
      guideRating: 0,
      guideReviews: 0,
      imageUrl: trip.imageUrl,
    );
  }
}

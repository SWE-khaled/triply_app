import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

/// Owns the Create Trip form: static field controllers + dynamic
/// Highlights/Itinerary rows.
///
/// Controllers are created here so every section/row reads one source;
/// they are disposed in [close]. No validation UI here — [submitTrip] and
/// [saveEdit] return a message and the View shows it.
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

  final nameCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final labelCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final maxTravelersCtrl = TextEditingController();
  final meetingCtrl = TextEditingController();
  final includedCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final languagesCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  Future<void> close() {
    for (final c in [
      nameCtrl,
      aboutCtrl,
      locationCtrl,
      labelCtrl,
      dateCtrl,
      timeCtrl,
      endTimeCtrl,
      durationCtrl,
      priceCtrl,
      maxTravelersCtrl,
      meetingCtrl,
      includedCtrl,
      notesCtrl,
      languagesCtrl,
      phoneCtrl,
    ]) {
      c.dispose();
    }
    return super.close();
  }

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

  /// Pre-fills the form for editing.
  ///
  /// The cover the trip already has is kept, so the guide sees the
  /// current image and only replaces it by picking a new one.
  void prefill(GuideTripDetails details) {
    nameCtrl.text = details.title;
    aboutCtrl.text = details.about;
    locationCtrl.text = details.location;
    priceCtrl.text = details.priceEgp.toInt().toString();
    meetingCtrl.text = details.meetingPoint;
    includedCtrl.text = details.included;
    notesCtrl.text = details.notes.join('\n');
    languagesCtrl.text = details.languages;
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

  /// Parses an "h:mm AM/PM" time (Arabic meridiem also accepted) into a
  /// 24-hour (hour, minute). Returns null when the text is unreadable.
  (int hour, int minute)? _parseTime(String text) {
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

  /// The moment the trip starts, parsed from the date + time pickers.
  ///
  /// The date field holds `d/m/yyyy` and the time field holds
  /// `h:mm AM/PM`. Returns null when the guide did not pick a date.
  /// An unreadable time falls back to midnight (unchanged behaviour).
  DateTime? get startAt {
    final date = dateCtrl.text.trim();
    if (date.isEmpty) return null;
    final parts = date.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0].trim());
    final month = int.tryParse(parts[1].trim());
    final year = int.tryParse(parts[2].trim());
    if (day == null || month == null || year == null) return null;

    var hour = 0;
    var minute = 0;
    final time = timeCtrl.text.trim();
    if (time.isNotEmpty) {
      final parsed = _parseTime(time);
      if (parsed != null) {
        hour = parsed.$1;
        minute = parsed.$2;
      }
      // Unreadable time keeps the previous midnight fallback behaviour.
    }
    return DateTime(year, month, day, hour, minute);
  }

  /// The moment the trip ends, parsed from the picked date + end time.
  ///
  /// The End Time the guide picks is the single source of truth for endAt:
  /// same day as the start, at the end time. Returns null when the date or
  /// end time is missing or unreadable.
  DateTime? get endAt {
    final starts = startAt;
    if (starts == null) return null;
    final endTime = endTimeCtrl.text.trim();
    if (endTime.isEmpty) return null;
    final parsed = _parseTime(endTime);
    if (parsed == null) return null;
    return DateTime(starts.year, starts.month, starts.day, parsed.$1, parsed.$2);
  }

  /// Duration derived from start and end: "5 hours", "Full Day" for 8 h.
  /// Null when start or end is missing, or end is not after start.
  String? get durationLabel {
    final starts = startAt;
    final ends = endAt;
    if (starts == null || ends == null) return null;
    final diff = ends.difference(starts).inHours;
    if (diff <= 0) return null;
    if (diff == 8) return 'Full Day';
    return '$diff hours';
  }

  /// Builds the entered trip for preview/submit. Not stored.
  GuideTrip buildTrip({String? coverUrl}) {
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    final starts = startAt;
    final cover =
        coverUrl ??
        state.cover ??
        'https://picsum.photos/seed/${tripNameCtrlText.hashCode}/300/400';
    return GuideTrip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      title: tripNameCtrlText,
      location: locationCtrl.text.trim().isEmpty
          ? 'Egypt'
          : locationCtrl.text.trim(),
      scheduleLabel: starts == null
          ? 'To be announced'
          : formatScheduleLabel(starts),
      priceEgp: price,
      imageUrl: cover,
      coverUrl: cover,
      // A guide always publishes a trip as pending — the admin dashboard
      // is what approves it.
      approval: GuideTripApproval.pending,
      capacity: int.tryParse(maxTravelersCtrl.text.trim()) ?? 0,
      phone: phoneCtrl.text.trim(),
      startAt: starts,
      endAt: endAt,
      duration: durationLabel,
    );
  }

  String get tripNameCtrlText => nameCtrl.text.trim();

  /// Returns an error message, or null when the draft is submittable.
  String? validate() {
    if (nameCtrl.text.trim().isEmpty) {
      return 'Please enter the trip name';
    }
    if (priceCtrl.text.trim().isEmpty) {
      return 'Please enter the price per person';
    }
    // The capacity is what limits the bookings, so it has to be a real
    // number — Firestore refuses a trip with a capacity of zero.
    final capacity = int.tryParse(maxTravelersCtrl.text.trim()) ?? 0;
    if (capacity <= 0) {
      return 'Please enter the maximum number of travelers';
    }
    // A trip must have a real start and end moment so tourists can book it.
    if (startAt == null) {
      return 'Please pick the trip date and start time';
    }
    if (endAt == null) {
      return 'Please pick the end time';
    }
    // End time must be after the start time on the same day — never roll
    // over to the next day.
    if (!endAt!.isAfter(startAt!)) {
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
    required GuideTrip existingTrip,
    required GuideTripDetails existingDetails,
  }) async {
    final error = validate();
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
    final price =
        double.tryParse(priceCtrl.text.trim()) ?? existingTrip.priceEgp;
    final starts = startAt;
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
      title: nameCtrl.text.trim(),
      location: locationCtrl.text.trim().isEmpty
          ? existingTrip.location
          : locationCtrl.text.trim(),
      scheduleLabel: starts == null
          ? existingTrip.scheduleLabel
          : formatScheduleLabel(starts),
      priceEgp: price,
      imageUrl: imageUrl,
      coverUrl: imageUrl,
      approval: isResubmit ? GuideTripApproval.pending : existingTrip.approval,
      capacity:
          int.tryParse(maxTravelersCtrl.text.trim()) ?? existingTrip.capacity,
      bookedSeats: existingTrip.bookedSeats,
      phone: phoneCtrl.text.trim().isEmpty
          ? existingTrip.phone
          : phoneCtrl.text.trim(),
      startAt: starts ?? existingTrip.startAt,
      endAt: endAt ?? existingTrip.endAt,
      duration: durationLabel ?? existingTrip.duration,
      rejectionReason: isResubmit ? null : existingTrip.rejectionReason,
      guideId: existingTrip.guideId,
    );
    GuideTripsStore.update(trip);
    final details = GuideTripDetails(
      id: existingDetails.id,
      tripId: existingDetails.tripId,
      tag: existingDetails.tag,
      title: nameCtrl.text.trim(),
      rating: existingDetails.rating,
      reviewsCount: existingDetails.reviewsCount,
      location: locationCtrl.text.trim().isEmpty
          ? existingDetails.location
          : locationCtrl.text.trim(),
      duration: durationLabel ?? existingDetails.duration,
      groupType: existingDetails.groupType,
      languages: languagesCtrl.text.trim().isEmpty
          ? existingDetails.languages
          : languagesCtrl.text.trim(),
      about: aboutCtrl.text.trim(),
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
      notes: notesCtrl.text.trim().isEmpty
          ? existingDetails.notes
          : notesCtrl.text
                .split('\n')
                .map((n) => n.trim())
                .where((n) => n.isNotEmpty)
                .toList(),
      included: includedCtrl.text.trim().isEmpty
          ? existingDetails.included
          : includedCtrl.text.trim(),
      meetingPoint: meetingCtrl.text.trim().isEmpty
          ? existingDetails.meetingPoint
          : meetingCtrl.text.trim(),
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
  Future<({GuideTrip? trip, String? error})> submitTrip() async {
    final error = validate();
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
    final trip = buildTrip(coverUrl: cover.isEmpty ? null : cover);
    GuideTripsStore.add(trip);
    final details = _buildDetails(trip);
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
  ({GuideTrip trip, GuideTripDetails details}) buildPreview() {
    final trip = buildTrip();
    final details = _buildDetails(trip);
    GuideTripDetailsSource.save(details);
    return (trip: trip, details: details);
  }

  /// Builds the long-form details of [trip] from the form.
  GuideTripDetails _buildDetails(GuideTrip trip) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return GuideTripDetails(
      id: 'details-${trip.id}',
      tripId: trip.id,
      tag: labelCtrl.text.trim(),
      title: trip.title,
      rating: 0,
      reviewsCount: 0,
      location: trip.location,
      duration: durationCtrl.text.trim(),
      groupType: '',
      languages: languagesCtrl.text.trim(),
      about: aboutCtrl.text.trim(),
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
      notes: notesCtrl.text
          .split('\n')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .toList(),
      included: includedCtrl.text.trim(),
      meetingPoint: meetingCtrl.text.trim(),
      priceEgp: trip.priceEgp,
      guideName: firebaseUser?.displayName?.trim() ?? '',
      guideAvatarUrl: firebaseUser?.photoURL?.trim() ?? '',
      guideRating: 0,
      guideReviews: 0,
      imageUrl: trip.imageUrl,
    );
  }
}

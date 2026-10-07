import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/data/guide_trip_details_source.dart';
import '../../../../core/data/guide_trips_store.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../../trip_details_tg/model/guide_trip_details.dart';
import '../model/guide_trip_draft.dart';
import 'create_trip_state.dart';

/// Owns the Create Trip form: static field controllers + dynamic
/// Highlights/Itinerary rows (mock phase, local only).
/// Controllers are created here so every section/row reads one source;
/// they are disposed in [close]. No validation UI here — [submit]
/// returns a message and the View shows it.
class CreateTripCubit extends Cubit<CreateTripState> {
  int _nextId = 1;

  final nameCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final labelCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final maxTravelersCtrl = TextEditingController();
  final meetingCtrl = TextEditingController();
  final includedCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final languagesCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  CreateTripCubit() : super(CreateTripState.initial());

  @override
  Future<void> close() {
    for (final c in [
      nameCtrl,
      aboutCtrl,
      locationCtrl,
      labelCtrl,
      dateCtrl,
      timeCtrl,
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

  void updateHighlight(String id, String v) {
    emit(
      state.copyWith(
        highlights: state.highlights
            .map((h) => h.id == id ? h.copyWith(text: v) : h)
            .toList(),
      ),
    );
  }

  void addHighlight() {
    emit(
      state.copyWith(
        highlights: [
          ...state.highlights,
          HighlightDraft(id: 'h${_nextId++}', text: ''),
        ],
      ),
    );
  }

  void removeHighlight(String id) {
    if (state.highlights.length <= 1) return;
    emit(
      state.copyWith(
        highlights: state.highlights.where((h) => h.id != id).toList(),
      ),
    );
  }

  void updateStopTime(String id, String v) {
    emit(
      state.copyWith(
        itinerary: state.itinerary
            .map((s) => s.id == id ? s.copyWith(time: v) : s)
            .toList(),
      ),
    );
  }

  void updateStopActivity(String id, String v) {
    emit(
      state.copyWith(
        itinerary: state.itinerary
            .map((s) => s.id == id ? s.copyWith(activity: v) : s)
            .toList(),
      ),
    );
  }

  void addStop() {
    emit(
      state.copyWith(
        itinerary: [
          ...state.itinerary,
          ItineraryStopDraft(id: 's${_nextId++}', time: '', activity: ''),
        ],
      ),
    );
  }

  void removeStop(String id) {
    if (state.itinerary.length <= 1) return;
    emit(
      state.copyWith(
        itinerary: state.itinerary.where((s) => s.id != id).toList(),
      ),
    );
  }

  /// Picks a gallery cover for local preview only (no upload yet).
  /// Returns an error message when picking fails, else null.
  Future<String?> pickCoverImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return null;
      emit(state.copyWith(coverImagePath: file.path));
      return null;
    } catch (_) {
      return 'Could not open the gallery';
    }
  }

  void removeCoverImage() {
    emit(state.copyWith(clearCover: true));
  }

  /// Pre-fills the form for editing (cover stays empty: re-pick or keep).
  void prefill(GuideTripDetails details) {
    nameCtrl.text = details.title;
    aboutCtrl.text = details.about;
    locationCtrl.text = details.location;
    durationCtrl.text = details.duration;
    priceCtrl.text = details.priceEgp.toInt().toString();
    meetingCtrl.text = details.meetingPoint;
    includedCtrl.text = details.included;
    notesCtrl.text = details.notes.join('\n');
    languagesCtrl.text = details.languages;
    emit(
      state.copyWith(
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
      ),
    );
  }

  /// Builds the entered trip for preview/submit. Not stored.
  GuideTrip buildTrip() {
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    final when = [
      if (dateCtrl.text.trim().isNotEmpty) dateCtrl.text.trim(),
      if (timeCtrl.text.trim().isNotEmpty) timeCtrl.text.trim(),
    ].join(' · ');
    return GuideTrip(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      title: tripNameCtrlText,
      location: locationCtrl.text.trim().isEmpty
          ? 'Egypt'
          : locationCtrl.text.trim(),
      scheduleLabel: when.isEmpty ? 'To be announced' : when,
      priceEgp: price,
      imageUrl:
          state.coverImagePath ??
          'https://picsum.photos/seed/${tripNameCtrlText.hashCode}/800/600',
      status: GuideTripStatus.pending,
      phone: phoneCtrl.text.trim(),
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
    return null;
  }

  /// Saves form edits over an existing trip+details (session only).
  /// Returns an error message, or null on success.
  String? saveEdit({
    required GuideTrip existingTrip,
    required GuideTripDetails existingDetails,
  }) {
    final error = validate();
    if (error != null) return error;
    final price =
        double.tryParse(priceCtrl.text.trim()) ?? existingTrip.priceEgp;
    final when = [
      if (dateCtrl.text.trim().isNotEmpty) dateCtrl.text.trim(),
      if (timeCtrl.text.trim().isNotEmpty) timeCtrl.text.trim(),
    ].join(' · ');
    GuideTripsStore.update(
      GuideTrip(
        id: existingTrip.id,
        title: nameCtrl.text.trim(),
        location: locationCtrl.text.trim().isEmpty
            ? existingTrip.location
            : locationCtrl.text.trim(),
        scheduleLabel: when.isEmpty ? existingTrip.scheduleLabel : when,
        priceEgp: price,
        imageUrl: state.coverImagePath ?? existingTrip.imageUrl,
        status: existingTrip.status,
        phone: phoneCtrl.text.trim().isEmpty
            ? existingTrip.phone
            : phoneCtrl.text.trim(),
      ),
    );
    GuideTripDetailsSource.save(
      GuideTripDetails(
        id: existingDetails.id,
        tripId: existingDetails.tripId,
        tag: existingDetails.tag,
        title: nameCtrl.text.trim(),
        rating: existingDetails.rating,
        reviewsCount: existingDetails.reviewsCount,
        location: locationCtrl.text.trim().isEmpty
            ? existingDetails.location
            : locationCtrl.text.trim(),
        duration: durationCtrl.text.trim().isEmpty
            ? existingDetails.duration
            : durationCtrl.text.trim(),
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
        imageUrl: state.coverImagePath ?? existingDetails.imageUrl,
      ),
    );
    return null;
  }

  /// Validates, stores as pending, returns the created trip.
  /// Also saves the entered details so View/Edit read this exact trip
  /// (same source of truth, no mock fallback). Returns null + error
  /// message when invalid.
  ({GuideTrip? trip, String? error}) submitTrip() {
    final error = validate();
    if (error != null) return (trip: null, error: error);
    final trip = buildTrip();
    GuideTripsStore.add(trip);
    final price = trip.priceEgp;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    GuideTripDetailsSource.save(
      GuideTripDetails(
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
        priceEgp: price,
        guideName: firebaseUser?.displayName?.trim() ?? '',
        guideAvatarUrl: firebaseUser?.photoURL?.trim() ?? '',
        guideRating: 0,
        guideReviews: 0,
        imageUrl: trip.imageUrl,
      ),
    );
    return (trip: trip, error: null);
  }
}

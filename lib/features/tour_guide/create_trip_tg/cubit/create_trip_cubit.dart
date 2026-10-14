import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/data/firestore/datasources/firestore_query_helper.dart';
import 'package:triply/data/firestore/datasources/trip_cover_storage.dart';
import 'package:triply/data/firestore/datasources/trips_datasource.dart';
import 'package:triply/data/firestore/models/trip_doc.dart';
import 'package:triply/data/firestore/repositories/guide_trips_repository.dart';
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
  final GuideTripsRepository _repository;
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

  CreateTripCubit([GuideTripsRepository? repository])
      : _repository = repository ?? GuideTripsRepository(),
        super(CreateTripState.initial());

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

  /// Picks a gallery cover for local preview. The file is uploaded to
  /// Firebase Storage on submit/edit; until then it stays a device path.
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

  /// Persists an edit to the SAME Firestore document when one exists.
  /// Returns null when the trip is session/mock-only (no remote doc —
  /// existing session behavior applies) or when the remote update
  /// succeeded; otherwise returns a user-facing error message.
  /// Identity/status/counter keys are never sent (rules + datasource
  /// strip them); a locally re-picked cover (device path) is omitted so
  /// a valid remote URL is never overwritten with a file path.
  Future<String?> saveEditRemote({required GuideTrip existingTrip}) async {
    try {
      final doc = await TripsDatasource().getById(existingTrip.id);
      if (doc == null) return null;
      final price =
          double.tryParse(priceCtrl.text.trim()) ?? existingTrip.priceEgp;
      final capacity = int.tryParse(maxTravelersCtrl.text.trim());
      final fields = <String, dynamic>{
        'title': nameCtrl.text.trim(),
        'description': aboutCtrl.text.trim(),
        'location': locationCtrl.text.trim().isEmpty
            ? doc.location
            : locationCtrl.text.trim(),
        'dateLabel': dateCtrl.text.trim().isEmpty
            ? doc.dateLabel
            : dateCtrl.text.trim(),
        'startTime': timeCtrl.text.trim(),
        'duration': durationCtrl.text.trim(),
        'priceEgp': price,
        'meetingPoint': meetingCtrl.text.trim().isEmpty
            ? doc.meetingPoint
            : meetingCtrl.text.trim(),
        'included': includedCtrl.text.trim().isEmpty
            ? doc.included
            : [includedCtrl.text.trim()],
        'highlights': state.highlights
            .map((h) => h.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        'itinerary': state.itinerary
            .where(
              (s) => s.time.trim().isNotEmpty || s.activity.trim().isNotEmpty,
            )
            .map(
              (s) => {'time': s.time.trim(), 'title': s.activity.trim()},
            )
            .toList(),
        'notes': notesCtrl.text.trim().isEmpty
            ? doc.notes
            : notesCtrl.text
                  .split('\n')
                  .map((n) => n.trim())
                  .where((n) => n.isNotEmpty)
                  .toList(),
        'languages': languagesCtrl.text.trim().isEmpty
            ? doc.languages
            : [languagesCtrl.text.trim()],
        'category': labelCtrl.text.trim().isEmpty
            ? doc.category
            : labelCtrl.text.trim(),
      };
      if (capacity != null && capacity >= 1) fields['capacity'] = capacity;
      // Cover: upload a freshly picked device file to Storage; keep the
      // existing remote URL when there is no new local image (or the
      // upload fails, e.g. Storage rules not deployed).
      final cover = state.coverImagePath ?? existingTrip.imageUrl;
      final uploaded = await TripCoverStorage().uploadIfLocal(
        FirebaseAuth.instance.currentUser?.uid ?? '',
        cover,
      );
      if (uploaded != null && uploaded.startsWith('http')) {
        fields['coverImageUrl'] = uploaded;
      }
      await _repository.updateTrip(existingTrip.id, fields);
      return null;
    } catch (e) {
      return FirestoreQueryHelper.friendlyError(e);
    }
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

  /// Firestore-backed submit. Runs the existing session [submitTrip] first
  /// (so the UI flow is unchanged), then persists the same trip to
  /// `trips/` as `pending`. Returns the session trip + optional remote
  /// error (session success is never rolled back on remote failure).
  Future<({GuideTrip? trip, String? error, String? remoteError})>
      submitTripToFirestore({
    required String guideId,
    String guideName = '',
  }) async {
    final local = submitTrip();
    if (local.trip == null) {
      return (trip: null, error: local.error, remoteError: null);
    }
    final trip = local.trip!;
    try {
      // Upload a freshly picked device cover to Storage; keep the
      // preview URL (picsum) when there is no local image or the
      // upload fails — the trip submit never fails on storage.
      var coverUrl = trip.imageUrl;
      final localCover = state.coverImagePath;
      if (localCover != null && localCover.isNotEmpty) {
        final uploaded =
            await TripCoverStorage().uploadIfLocal(guideId, localCover);
        if (uploaded != null && uploaded.isNotEmpty) coverUrl = uploaded;
      }
      await _repository.createTrip(
        TripDoc(
          id: '',
          guideId: guideId,
          guideName: guideName,
          title: trip.title,
          description: aboutCtrl.text.trim(),
          location: trip.location,
          dateLabel: dateCtrl.text.trim().isEmpty
              ? trip.scheduleLabel
              : dateCtrl.text.trim(),
          startTime: timeCtrl.text.trim(),
          duration: durationCtrl.text.trim(),
          priceEgp: trip.priceEgp,
          capacity: int.tryParse(maxTravelersCtrl.text.trim()) ?? 12,
          meetingPoint: meetingCtrl.text.trim(),
          included: includedCtrl.text.trim().isEmpty
              ? const []
              : [includedCtrl.text.trim()],
          highlights: state.highlights
              .map((h) => h.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
          itinerary: state.itinerary
              .where(
                (s) => s.time.trim().isNotEmpty || s.activity.trim().isNotEmpty,
              )
              .map(
                (s) => {'time': s.time.trim(), 'title': s.activity.trim()},
              )
              .toList(),
          notes: notesCtrl.text.trim().isEmpty
              ? const []
              : notesCtrl.text
                  .split('\n')
                  .map((n) => n.trim())
                  .where((n) => n.isNotEmpty)
                  .toList(),
          languages: languagesCtrl.text.trim().isEmpty
              ? const []
              : [languagesCtrl.text.trim()],
          coverImageUrl: coverUrl,
          category: labelCtrl.text.trim().isEmpty
              ? 'historical'
              : labelCtrl.text.trim(),
        ),
      );
      return (trip: trip, error: null, remoteError: null);
    } catch (e) {
      return (trip: trip, error: null, remoteError: e.toString());
    }
  }
}

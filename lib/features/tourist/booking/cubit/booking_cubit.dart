import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/data/firestore/booking_pricing.dart';
import 'package:triply/data/firestore/models/booking_doc.dart';
import 'package:triply/data/firestore/repositories/bookings_repository.dart';
import 'package:triply/features/tourist/booking/model/booking.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/booking/services/price_calculator.dart';
import 'package:triply/features/tourist/map/model/place.dart';
import 'booking_state.dart';

/// Feature-focused cubit for the 4-step Booking flow.
/// Local mock state only — no backend, no delays.
class BookingCubit extends Cubit<BookingState> {
  final String guideId;

  /// Notes scratch text. Kept outside the emitted state on purpose:
  /// typing must not rebuild the whole flow.
  String _notes = '';

  BookingCubit({required this.guideId}) : super(const BookingState());

  static const List<String> timeSlots = [
    '7:00 AM',
    '9:00 AM',
    '11:00 AM',
    '1:00 PM',
    '3:00 PM',
    '5:00 PM',
  ];

  static const List<String> durations = [
    '2 hours',
    '4 hours',
    '6 hours',
    'Full Day',
  ];

  static const List<String> meetingPoints = [
    'Hotel Lobby',
    'Museum Entrance',
    'Giza Plateau Gate',
  ];

  List<Place> get places => mockPlaces.map((e) => Place.fromJson(e)).toList();

  Place? get selectedPlace => state.selectedPlace;

  void setSelectedPlace(Place? place) {
    emit(state.copyWith(selectedPlace: place));
  }

  int get stepIndex => state.stepIndex;
  DateTime? get date => state.date;
  String? get timeSlot => state.timeSlot;
  String get durationLabel => state.durationLabel;
  int get travelers => state.travelers;
  String get meetingPoint => state.meetingPoint;
  String get notes => _notes;

  Guide get guide {
    return mockGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => mockGuides.first,
    );
  }

  int get durationHours =>
      PriceCalculator.durationHoursFor(state.durationLabel);

  double get subtotal => PriceCalculator.subtotal(
    guide.pricePerHour,
    durationHours,
    state.travelers,
  );
  double get serviceFee => PriceCalculator.serviceFee(subtotal);
  double get total =>
      PriceCalculator.total(guide.pricePerHour, durationHours, state.travelers);

  bool get canContinueStep1 =>
      state.date != null &&
      state.timeSlot != null &&
      state.durationLabel.isNotEmpty;

  String get dateLabel {
    final d = state.date;
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String get travelersLabel =>
      '${state.travelers} ${state.travelers == 1 ? 'person' : 'people'}';

  void setDate(DateTime value) {
    emit(state.copyWith(date: value));
  }

  void setTimeSlot(String value) {
    if (value == state.timeSlot) return;
    emit(state.copyWith(timeSlot: value));
  }

  void setDuration(String value) {
    if (value == state.durationLabel) return;
    emit(state.copyWith(durationLabel: value));
  }

  void incrementTravelers() {
    if (state.travelers >= 10) return;
    emit(state.copyWith(travelers: state.travelers + 1));
  }

  void decrementTravelers() {
    if (state.travelers <= 1) return;
    emit(state.copyWith(travelers: state.travelers - 1));
  }

  void setMeetingPoint(String value) {
    if (value == state.meetingPoint) return;
    emit(state.copyWith(meetingPoint: value));
  }

  void setNotes(String value) {
    _notes = value;
    // No emit — notes typing should not rebuild the whole flow.
  }

  void next() {
    if (state.stepIndex >= 3) return;
    if (state.stepIndex == 0 && !canContinueStep1) return;
    emit(state.copyWith(stepIndex: state.stepIndex + 1));
  }

  void back() {
    if (state.stepIndex <= 0) return;
    emit(state.copyWith(stepIndex: state.stepIndex - 1));
  }

  /// Confirm & Pay placeholder: builds a [Booking] model locally and
  /// advances to the success step. No payment SDK.
  Booking confirm() {
    final booking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      guideId: guideId,
      dateLabel: dateLabel,
      timeSlot: state.timeSlot ?? '',
      durationLabel: state.durationLabel,
      durationHours: durationHours,
      travelers: state.travelers,
      meetingPoint: state.meetingPoint,
      notes: _notes,
      pricePerHour: guide.pricePerHour,
      serviceFee: serviceFee,
      total: total,
    );
    emit(state.copyWith(stepIndex: 3));
    return booking;
  }

  /// Client-side traveler pre-check (UX only). The Function enforces
  /// 1–10 travelers and 1–24 duration hours and is authoritative.
  String? validateTravelers() =>
      BookingPricing.validatePrivate(travelers: state.travelers);

  /// Deterministic idempotency key for one logical private request.
  /// Identical inputs (including a retry after a network failure) produce
  /// the identical key, so the server dedupes to the original booking.
  static String buildIdempotencyKey({
    required String uid,
    required String guideId,
    required DateTime appointmentAt,
    required String timeSlot,
    required int travelers,
    required int durationHours,
    required String meetingPoint,
    required String specialRequests,
    required String? placeId,
  }) {
    final a = appointmentAt.toUtc();
    final appt =
        '${a.year.toString().padLeft(4, '0')}'
        '${a.month.toString().padLeft(2, '0')}'
        '${a.day.toString().padLeft(2, '0')}';
    final req = BookingPricing.shortHash(
      '$timeSlot|$meetingPoint|${specialRequests.trim()}|${placeId ?? ''}',
    );
    return 'pvt-$uid-$guideId-$appt-$travelers-${durationHours}h-$req';
  }

  /// Creates the private booking through `createBooking` and returns the
  /// authoritative server [BookingDoc] (guide price + server fee).
  /// Returns null when a submission is already in flight (duplicate-tap
  /// guard). Throws with a user-facing message on validation/backend
  /// failure (e.g. unknown guide) — never records a local booking.
  /// NOTE: the guide id must exist in `guideProfiles/` (real guide data,
  /// wired in the guide phase); otherwise the server answers `not-found`.
  Future<BookingDoc?> submitBooking({
    required BookingsRepository repository,
    required String? uid,
  }) async {
    if (state.isSubmitting) return null;
    if (uid == null || uid.isEmpty) {
      throw Exception('Please sign in to book.');
    }
    final err = validateTravelers();
    if (err != null) throw Exception(err);
    final date = state.date;
    if (date == null) throw Exception('Select a date for your tour.');
    if (durationHours < 1) throw Exception('Select a valid duration.');
    final key = buildIdempotencyKey(
      uid: uid,
      guideId: guideId,
      appointmentAt: date,
      timeSlot: state.timeSlot ?? '',
      travelers: state.travelers,
      durationHours: durationHours,
      meetingPoint: state.meetingPoint,
      specialRequests: _notes,
      placeId: state.selectedPlace?.id,
    );
    emit(state.copyWith(isSubmitting: true));
    try {
      return await repository.createPrivate(
        guideId: guideId,
        placeId: state.selectedPlace?.id,
        appointmentAt: date,
        timeSlot: state.timeSlot ?? '',
        travelers: state.travelers,
        durationHours: durationHours,
        meetingPoint: state.meetingPoint,
        specialRequests: _notes,
        idempotencyKey: key,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(isSubmitting: false));
    }
  }
}

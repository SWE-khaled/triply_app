import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/data/repositories/booking_repository.dart';
import 'package:triply/features/tourist/booking/model/booking.dart';
import 'package:triply/features/tourist/booking/services/price_calculator.dart';
import 'package:triply/features/tourist/checkout/services/payment_service.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/map/model/place.dart';

import 'booking_state.dart';

/// Feature-focused cubit for the 4-step Booking flow.
///
/// Form state lives in private authoritative fields and is emitted as a whole
/// new snapshot; the async booking/payment write has its own state so a failure
/// cannot overwrite the form. Guide identity and pricing come from the
/// approved Firestore Guide passed into this Cubit; place options stay mock.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required this.guide,
    PaymentService? paymentService,
  }) : guideId = guide.id,
       _paymentService = paymentService ?? PaymentService(),
       super(const BookingState());

  final Guide guide;
  final String guideId;
  final PaymentService _paymentService;

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

  // Authoritative form fields. Every mutation emits a fresh BookingState.
  int _stepIndex = 0;
  DateTime? _date;
  String? _timeSlot;
  String _durationLabel = '4 hours';
  int _travelers = 2;
  String _meetingPoint = 'Hotel Lobby';
  Place? _selectedPlace;

  /// Notes scratch text. Kept outside the emitted state on purpose:
  /// typing must not rebuild the whole flow.
  String _notes = '';

  BookingRequestState _request = const BookingRequestInitial();
  String? _pendingBookingId;

  void _emit() {
    if (isClosed) return;
    emit(
      BookingState(
        stepIndex: _stepIndex,
        date: _date,
        timeSlot: _timeSlot,
        durationLabel: _durationLabel,
        travelers: _travelers,
        meetingPoint: _meetingPoint,
        selectedPlace: _selectedPlace,
        request: _request,
      ),
    );
  }

  List<Place> get places => mockPlaces.map((e) => Place.fromJson(e)).toList();

  Place? get selectedPlace => _selectedPlace;

  void setSelectedPlace(Place? place) {
    _selectedPlace = place;
    _emit();
  }

  int get stepIndex => _stepIndex;
  DateTime? get date => _date;
  String? get timeSlot => _timeSlot;
  String get durationLabel => _durationLabel;
  int get travelers => _travelers;
  String get meetingPoint => _meetingPoint;
  String get notes => _notes;

  BookingRequestState get request => _request;

  int get durationHours => PriceCalculator.durationHoursFor(_durationLabel);

  /// The start moment of the private booking, parsed from the picked date
  /// and time slot.
  DateTime? get startAt {
    final d = _date;
    if (d == null) return null;
    final slot = _timeSlot;
    if (slot == null) return null;
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM|ص|م)$',
      caseSensitive: false,
    ).firstMatch(slot);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final marker = match.group(3)!.toUpperCase();
    final isPm = marker == 'PM' || marker == 'م';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  /// The end moment of the private booking (start + selected duration).
  DateTime? get endAt => startAt?.add(Duration(hours: durationHours));

  double get subtotal => PriceCalculator.subtotal(
    guide.pricePerHour,
    durationHours,
    _travelers,
  );
  double get serviceFee => PriceCalculator.serviceFee(subtotal);
  double get total =>
      PriceCalculator.total(guide.pricePerHour, durationHours, _travelers);

  bool get canContinueStep1 =>
      _date != null && _timeSlot != null && _durationLabel.isNotEmpty;

  String get dateLabel {
    final d = _date;
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String get travelersLabel =>
      '$_travelers ${_travelers == 1 ? 'person' : 'people'}';

  void setDate(DateTime value) {
    _date = value;
    _emit();
  }

  void setTimeSlot(String value) {
    if (value == _timeSlot) return;
    _timeSlot = value;
    _emit();
  }

  void setDuration(String value) {
    if (value == _durationLabel) return;
    _durationLabel = value;
    _emit();
  }

  void incrementTravelers() {
    if (_travelers >= 10) return;
    _travelers++;
    _emit();
  }

  void decrementTravelers() {
    if (_travelers <= 1) return;
    _travelers--;
    _emit();
  }

  void setMeetingPoint(String value) {
    if (value == _meetingPoint) return;
    _meetingPoint = value;
    _emit();
  }

  void setNotes(String value) {
    _notes = value;
    // No emit — notes typing should not rebuild the whole flow.
  }

  void next() {
    if (_stepIndex >= 3) return;
    if (_stepIndex == 0 && !canContinueStep1) return;
    _stepIndex++;
    _emit();
  }

  void back() {
    if (_stepIndex <= 0) return;
    _stepIndex--;
    _emit();
  }

  /// Confirm & Pay placeholder: builds a [Booking] model locally and
  /// advances to the success step. No payment SDK.
  Booking confirm() {
    final booking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      guideId: guideId,
      dateLabel: dateLabel,
      timeSlot: _timeSlot ?? '',
      durationLabel: _durationLabel,
      durationHours: durationHours,
      travelers: _travelers,
      meetingPoint: _meetingPoint,
      notes: _notes,
      pricePerHour: guide.pricePerHour,
      serviceFee: serviceFee,
      total: total,
    );
    _stepIndex = 3;
    _emit();
    return booking;
  }

  /// Creates the pending private booking and records it in My Trips. The View
  /// only dispatches this and reacts to [BookingRequestCreated]/
  /// [BookingRequestFailed]; it never calls the repository itself.
  Future<void> startPrivateBooking() async {
    final startAt = this.startAt;
    if (startAt == null) {
      _request = const BookingRequestFailed(
        message: 'Pick a date and time before paying.',
      );
      _emit();
      return;
    }

    _request = const BookingRequestLoading();
    _emit();
    try {
      final receipt = await _paymentService.createPrivatePendingBooking(
        guideId: guideId,
        guideName: guide.name,
        guideImageUrl: guide.coverUrl.isNotEmpty
            ? guide.coverUrl
            : guide.avatarUrl,
        title: 'Private tour with ${guide.name}',
        travelers: _travelers,
        totalPrice: total,
        startAt: startAt,
        endAt: endAt,
        meetingPoint: _meetingPoint,
        dateLabel: dateLabel,
      );
      _pendingBookingId = receipt.bookingId;
      _request = BookingRequestCreated(bookingId: receipt.bookingId);
      _emit();
    } on BookingException catch (error) {
      _request = BookingRequestFailed(message: error.message);
      _emit();
    } catch (_) {
      _request = const BookingRequestFailed(
        message: 'The payment failed. Please try again.',
      );
      _emit();
    }
  }

  /// Confirms after the Paymob WebView reports success. Payment id stays the
  /// booking id (test-only demo, no real money moves).
  Future<void> completePrivatePayment() async {
    final bookingId = _pendingBookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    _request = const BookingRequestLoading();
    _emit();
    try {
      await _paymentService.confirmBooking(bookingId, paymentId: bookingId);
      _request = BookingRequestConfirmed(bookingId: bookingId);
      _emit();
    } catch (_) {
      _request = const BookingRequestFailed(
        message: 'Could not confirm your booking. Please try again.',
      );
      _emit();
    }
  }
}

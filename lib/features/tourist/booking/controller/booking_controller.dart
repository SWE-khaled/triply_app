import 'package:flutter/foundation.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/features/tourist/booking/model/booking.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/booking/services/price_calculator.dart';
import 'package:triply/features/tourist/map/model/place.dart';

/// Feature-focused controller for the 4-step Booking flow.
/// Local mock state only — no backend, no delays.
class BookingController extends ChangeNotifier {
  final String guideId;

  BookingController({required this.guideId});

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

  int _stepIndex = 0;
  DateTime? _date;
  String? _timeSlot;
  String _durationLabel = '4 hours';
  int _travelers = 2;
  String _meetingPoint = 'Hotel Lobby';
  String _notes = '';
  Place? _selectedPlace;

  List<Place> get places =>
      mockPlaces.map((e) => Place.fromJson(e)).toList();

  Place? get selectedPlace => _selectedPlace;

  void setSelectedPlace(Place? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  int get stepIndex => _stepIndex;
  DateTime? get date => _date;
  String? get timeSlot => _timeSlot;
  String get durationLabel => _durationLabel;
  int get travelers => _travelers;
  String get meetingPoint => _meetingPoint;
  String get notes => _notes;

  Guide get guide {
    return mockGuides.firstWhere(
      (g) => g.id == guideId,
      orElse: () => mockGuides.first,
    );
  }

  int get durationHours =>
      PriceCalculator.durationHoursFor(_durationLabel);

  double get subtotal => PriceCalculator.subtotal(
      guide.pricePerHour, durationHours, _travelers);
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
    notifyListeners();
  }

  void setTimeSlot(String value) {
    if (value == _timeSlot) return;
    _timeSlot = value;
    notifyListeners();
  }

  void setDuration(String value) {
    if (value == _durationLabel) return;
    _durationLabel = value;
    notifyListeners();
  }

  void incrementTravelers() {
    if (_travelers >= 10) return;
    _travelers++;
    notifyListeners();
  }

  void decrementTravelers() {
    if (_travelers <= 1) return;
    _travelers--;
    notifyListeners();
  }

  void setMeetingPoint(String value) {
    if (value == _meetingPoint) return;
    _meetingPoint = value;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    // No notifyListeners — notes typing should not rebuild the whole flow.
  }

  void next() {
    if (_stepIndex >= 3) return;
    if (_stepIndex == 0 && !canContinueStep1) return;
    _stepIndex++;
    notifyListeners();
  }

  void back() {
    if (_stepIndex <= 0) return;
    _stepIndex--;
    notifyListeners();
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
    notifyListeners();
    return booking;
  }
}

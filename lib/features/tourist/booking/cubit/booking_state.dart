import 'package:triply/features/tourist/map/model/place.dart';

class BookingState {
  final int stepIndex;
  final DateTime? date;
  final String? timeSlot;
  final String durationLabel;
  final int travelers;
  final String meetingPoint;
  final Place? selectedPlace;

  /// True while a `createBooking` submission is in flight. The Confirm
  /// button is disabled then, so duplicate taps cannot create a second
  /// booking (the in-flight request owns the idempotency key).
  final bool isSubmitting;

  const BookingState({
    this.stepIndex = 0,
    this.date,
    this.timeSlot,
    this.durationLabel = '4 hours',
    this.travelers = 2,
    this.meetingPoint = 'Hotel Lobby',
    this.selectedPlace,
    this.isSubmitting = false,
  });

  BookingState copyWith({
    int? stepIndex,
    DateTime? date,
    String? timeSlot,
    String? durationLabel,
    int? travelers,
    String? meetingPoint,
    Place? selectedPlace,
    bool? isSubmitting,
  }) {
    return BookingState(
      stepIndex: stepIndex ?? this.stepIndex,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      durationLabel: durationLabel ?? this.durationLabel,
      travelers: travelers ?? this.travelers,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

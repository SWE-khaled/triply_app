import 'package:flutter/foundation.dart';

import 'package:triply/features/tourist/map/model/place.dart';

/// Explicit states of the async booking/payment write. Keeping this separate
/// from the form snapshot means a failed confirmation never rewrites the
/// picked date, travelers or the current step.
@immutable
sealed class BookingRequestState {
  const BookingRequestState();
}

final class BookingRequestInitial extends BookingRequestState {
  const BookingRequestInitial();
}

final class BookingRequestLoading extends BookingRequestState {
  const BookingRequestLoading();
}

final class BookingRequestCreated extends BookingRequestState {
  const BookingRequestCreated({required this.bookingId});

  final String bookingId;
}

final class BookingRequestConfirmed extends BookingRequestState {
  const BookingRequestConfirmed({required this.bookingId});

  final String bookingId;
}

final class BookingRequestFailed extends BookingRequestState {
  const BookingRequestFailed({required this.message});

  final String message;
}

/// Immutable snapshot of the 4-step form. Emitted fresh by [BookingCubit]
/// from private authoritative fields — no copyWith, no state patching.
@immutable
class BookingState {
  const BookingState({
    this.stepIndex = 0,
    this.date,
    this.timeSlot,
    this.durationLabel = '4 hours',
    this.travelers = 2,
    this.meetingPoint = 'Hotel Lobby',
    this.selectedPlace,
    this.request = const BookingRequestInitial(),
  });

  final int stepIndex;
  final DateTime? date;
  final String? timeSlot;
  final String durationLabel;
  final int travelers;
  final String meetingPoint;
  final Place? selectedPlace;
  final BookingRequestState request;
}

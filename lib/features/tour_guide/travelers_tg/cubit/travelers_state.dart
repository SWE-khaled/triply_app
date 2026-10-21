part of 'travelers_cubit.dart';

@immutable
sealed class TravelersState {
  const TravelersState();
}

final class TravelersInitial extends TravelersState {
  const TravelersInitial();
}

final class TravelersLoading extends TravelersState {
  const TravelersLoading();
}

final class TravelersSuccess extends TravelersState {
  final List<Traveler> travelers;

  const TravelersSuccess({required this.travelers});
}

final class TravelersError extends TravelersState {
  final String error;

  const TravelersError({required this.error});
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/guide_trip_details_source.dart';
import '../../my_trips/model/guide_trip.dart';
import 'guide_trip_details_state.dart';

/// Owns guide trip details loading + tab selection.
class GuideTripDetailsCubit extends Cubit<GuideTripDetailsState> {
  final GuideTripDetailsSource _source;

  GuideTripDetailsCubit({GuideTripDetailsSource? source})
    : _source = source ?? const GuideTripDetailsSource(),
      super(const GuideTripDetailsState(details: null, selectedTab: 0));

  void loadTrip(GuideTrip trip) {
    emit(
      state.copyWith(
        details: _source.getByTripId(
          trip.id,
          title: trip.title,
          imageUrl: trip.imageUrl,
          priceEgp: trip.priceEgp,
        ),
      ),
    );
  }

  void selectTab(int index) => emit(state.copyWith(selectedTab: index));
}

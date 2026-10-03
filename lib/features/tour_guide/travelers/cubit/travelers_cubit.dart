import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/mock/mock_travelers.dart';
import '../model/traveler.dart';
import 'travelers_state.dart';

/// Traveler list for one guide trip (mock -> Model, static in this phase).
class TravelersCubit extends Cubit<TravelersState> {
  TravelersCubit() : super(const TravelersState(travelers: []));

  void loadTrip(String tripId) {
    emit(
      TravelersState(
        travelers: mockTravelersJson
            .map((e) => Traveler.fromJson(e))
            .where((t) => t.tripId == tripId)
            .toList(),
      ),
    );
  }
}

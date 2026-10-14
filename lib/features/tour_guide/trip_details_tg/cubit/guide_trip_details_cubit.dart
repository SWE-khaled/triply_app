import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/guide_trip_details_source.dart';
import '../../../../data/firestore/datasources/firestore_query_helper.dart';
import '../../../../data/firestore/datasources/trips_datasource.dart';
import '../../../../data/firestore/mappers/firestore_mappers.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import 'guide_trip_details_state.dart';

/// Owns guide trip details loading + tab selection.
///
/// Resolution order for [loadTrip]:
/// 1. Session override or exact mock-details match (synchronous — keeps
///    offline/mock flows working with no network).
/// 2. Otherwise the id belongs to a real Firestore `trips/` document:
///    fetched by id with loading/error states (never mock filler).
class GuideTripDetailsCubit extends Cubit<GuideTripDetailsState> {
  final GuideTripDetailsSource _source;
  TripsDatasource? _tripsDS;

  GuideTripDetailsCubit({
    GuideTripDetailsSource? source,
    TripsDatasource? trips,
  })  : _source = source ?? const GuideTripDetailsSource(),
        _tripsDS = trips,
        super(const GuideTripDetailsState(details: null, selectedTab: 0));

  // Lazy: constructing the cubit must not touch Firebase (keeps widget/unit
  // tests and offline startup free of Firebase initialization).
  TripsDatasource get _trips => _tripsDS ??= TripsDatasource();

  Future<void> loadTrip(GuideTrip trip) async {
    // Exact local match (session-saved or mock details): show at once.
    // The shared source marks non-matches with id 'fallback'.
    final local = _source.getByTripId(
      trip.id,
      title: trip.title,
      imageUrl: trip.imageUrl,
      priceEgp: trip.priceEgp,
    );
    if (local.id != 'fallback') {
      emit(state.copyWith(details: local, error: null));
      return;
    }
    // Real Firestore document: loading spinner first, then bound fields.
    emit(
      GuideTripDetailsState(details: null, selectedTab: state.selectedTab),
    );
    try {
      final doc = await _trips.getById(trip.id);
      if (doc == null) {
        emit(
          GuideTripDetailsState(
            details: null,
            selectedTab: state.selectedTab,
            error: 'Trip not found. It may have been deleted.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          details: FirestoreMappers.tripDocToGuideTripDetails(doc),
          error: null,
        ),
      );
    } catch (e) {
      emit(
        GuideTripDetailsState(
          details: null,
          selectedTab: state.selectedTab,
          error: FirestoreQueryHelper.friendlyError(e),
        ),
      );
    }
  }

  void selectTab(int index) => emit(state.copyWith(selectedTab: index));
}

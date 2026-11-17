import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/place_resolver.dart';
import 'place_detail_state.dart';

/// Owns only the place document. Guides, trips and stories have their own
/// cubits, so a failure in one section can never replace the place itself.
class PlaceInfoCubit extends Cubit<PlaceInfoState>
    with SafeEmitMixin<PlaceInfoState> {
  PlaceInfoCubit({required this.placeId, PlaceResolver? resolver})
    : _resolver = resolver ?? PlaceResolver(placeId: placeId),
      super(const PlaceInfoInitial()) {
    load();
  }

  final String placeId;
  final PlaceResolver _resolver;

  Future<void> load() async {
    safeEmit(const PlaceInfoLoading());
    try {
      final place = await _resolver.resolve();
      if (isClosed) return;
      safeEmit(PlaceInfoSuccess(place: place));
    } catch (error) {
      if (isClosed) return;
      safeEmit(PlaceInfoError(error: '$error'));
    }
  }

  void retry() => load();
}

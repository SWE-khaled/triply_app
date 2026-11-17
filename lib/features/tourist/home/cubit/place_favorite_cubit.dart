import 'package:flutter_bloc/flutter_bloc.dart';

import 'place_favorite_state.dart';

/// Keeps the session-local favorite flag of one Home place card.
///
/// There is no remote favorite write on Home, so this is a synchronous UI
/// business state: one independent instance per place id.
class PlaceFavoriteCubit extends Cubit<PlaceFavoriteState> {
  PlaceFavoriteCubit({required bool isFavorite})
    : _isFavorite = isFavorite,
      super(PlaceFavoriteReady(isFavorite: isFavorite));

  /// The authoritative value for this card.
  bool _isFavorite;

  void toggle() {
    _isFavorite = !_isFavorite;
    emit(PlaceFavoriteReady(isFavorite: _isFavorite));
  }
}

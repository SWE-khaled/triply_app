import 'package:flutter/foundation.dart';

@immutable
sealed class PlaceFavoriteState {
  const PlaceFavoriteState();

  bool get isFavorite;
}

final class PlaceFavoriteReady extends PlaceFavoriteState {
  @override
  final bool isFavorite;

  const PlaceFavoriteReady({required this.isFavorite});
}

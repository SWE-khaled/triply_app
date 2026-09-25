/// Session-only favorites store (mock phase, no backend).
/// Static so every screen sees the same set without a state package.
/// Later: replace the body with API/Firebase calls — Views keep
/// calling the same methods.
class FavoritesController {
  FavoritesController._();

  static final Set<String> _ids = <String>{};

  static bool isFavorite(String tripId) => _ids.contains(tripId);

  /// Toggles and returns the new state (true = now favorite).
  static bool toggle(String tripId) {
    if (_ids.contains(tripId)) {
      _ids.remove(tripId);
      return false;
    }
    _ids.add(tripId);
    return true;
  }
}

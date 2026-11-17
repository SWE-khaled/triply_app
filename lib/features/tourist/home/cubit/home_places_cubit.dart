import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_palces_raw.dart';
import 'package:triply/core/data/mock/tourist/mock_places.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../model/place.dart';
import 'home_places_state.dart';

/// Loads only the "Popular Places" section of Home.
class HomePlacesCubit extends Cubit<HomePlacesState>
    with SafeEmitMixin<HomePlacesState> {
  HomePlacesCubit() : super(const HomePlacesInitial());

  bool _isLoading = false;
  bool _hasLoaded = false;

  /// Reads the bundled places. Keeps the original session guard: the first
  /// load shows the shimmer, a retry after an error keeps the error view
  /// until the request resolves, and a successful load is never repeated.
  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    if (state is HomePlacesInitial) {
      safeEmit(const HomePlacesLoading());
    }
    try {
      final places = _mockPlaces();
      _hasLoaded = true;
      safeEmit(HomePlacesSuccess(places: places));
    } catch (error) {
      safeEmit(HomePlacesError(message: pageLoadErrorMessage(error)));
    } finally {
      _isLoading = false;
    }
  }

  /// The bundled places, used exactly as before while the place data moves
  /// to Firestore in a separate phase.
  List<Place> _mockPlaces() {
    const homePlaceIds = ['giza_pyramids', 'khan_el_khalili', 'philae_temple'];
    final byId = {for (final e in mockPlaces) e['id'] as String: e};
    final legacyImages = [
      for (final e in mockPlacesRaw) e['image_url'] as String,
    ];
    var places = [
      for (var i = 0; i < homePlaceIds.length; i++)
        if (byId.containsKey(homePlaceIds[i]))
          _withDisplayImage(
            Place.fromJson(byId[homePlaceIds[i]]!),
            legacyImages[i % legacyImages.length],
          ),
    ];
    if (places.isEmpty) {
      places = mockPlaces.take(3).map(Place.fromJson).toList();
    }
    return places;
  }

  /// Display-only image override: navigation still uses [place.id].
  Place _withDisplayImage(Place place, String imageUrl) {
    return Place(
      id: place.id,
      name: place.name,
      city: place.city,
      country: place.country,
      imageUrl: imageUrl,
      isFavorite: place.isFavorite,
    );
  }
}

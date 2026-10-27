import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:triply/features/tourist/home/view/home_screen.dart';

import '../../user_profile/view/profile_screen.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../model/place.dart';
import '../../community/view/community_view.dart';
import '../widget/map_filter_chips.dart';
import '../widget/map_place_marker.dart';
import '../widget/map_search_field.dart';
import '../widget/place_preview_card.dart';
import '../../place_details/view/place_details_view.dart';

/// Egypt-wide default camera used before any place is selected.
const _egyptCenter = latlng.LatLng(26.8206, 30.8025);
const _egyptZoom = 5.5;
const _focusedZoom = 12.0;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapCubit controller;
  late final TextEditingController searchController;
  final fmap.MapController _mapController = fmap.MapController();

  @override
  void initState() {
    super.initState();
    // Owned here (like the old controller) so helpers keep working
    // unchanged; provided below for BlocBuilder rebuilds.
    controller = MapCubit();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    controller.close();
    searchController.dispose();
    super.dispose();
  }

  void _openPlaceDetail(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
    );
  }

  /// Real markers driven by cubit state (lat/lng from Place model).
  List<fmap.Marker> _markersFor(List<Place> places) {
    return places.map((place) {
      return fmap.Marker(
        point: latlng.LatLng(place.latitude, place.longitude),
        width: 40,
        height: 40,
        child: MapPlaceMarker(
          onTap: () {
            controller.selectPlace(place);
          },
        ),
      );
    }).toList();
  }

  /// Moves the camera to the currently selected place (or Egypt overview).
  void _focusSelected({double? zoom}) {
    final selected = controller.selectedPlace;
    if (selected == null) {
      _mapController.move(_egyptCenter, _egyptZoom);
    } else {
      _mapController.move(
        latlng.LatLng(selected.latitude, selected.longitude),
        zoom ?? _focusedZoom,
      );
    }
  }

  void _onSearchChanged(String v) {
    controller.setSearchQuery(v);
    _focusSelected();
  }

  void _onSearchSubmitted(String v) {
    controller.submitSearch(v);
    _focusSelected();
  }

  void _onFilterSelected(MapFilter filter) {
    controller.selectFilter(filter);
    _focusSelected();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: Scaffold(
        extendBody: true, // map extends under the glass nav
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false, // <-- let the map reach the bottom of the screen
          child: BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              // Sealed states: only a ready catalog renders the map UI.
              return switch (state) {
                MapSuccessState() => _buildContent(state),
                MapErrorState(:final message) => _buildError(message),
                _ => const Center(child: CircularProgressIndicator()),
              };
            },
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.of(context).push(AppRoutes.myTrips());
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  /// The existing dashboard content, unchanged — now fed from the
  /// success state fields instead of cubit getters.
  Widget _buildContent(MapSuccessState state) {
    final selected = state.selectedPlace;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: MapSearchField(
            controller: searchController,
            searchQuery: state.searchQuery,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            onClear: () {
              searchController.clear();
              controller.clearSearch();
              _focusSelected();
            },
          ),
        ),
        MapFilterChips(
          selectedFilter: state.selectedFilter,
          onFilterSelected: _onFilterSelected,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              fmap.FlutterMap(
                mapController: _mapController,
                options: fmap.MapOptions(
                  initialCenter: selected != null
                      ? latlng.LatLng(selected.latitude, selected.longitude)
                      : _egyptCenter,
                  initialZoom: selected != null ? _focusedZoom : _egyptZoom,
                ),
                children: [
                  fmap.TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.triply_app',
                  ),
                  fmap.MarkerLayer(markers: _markersFor(state.visiblePlaces)),
                ],
              ),
              if (selected != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100, // keeps the card above the nav
                  child: PlacePreviewCard(
                    place: selected,
                    onTap: () => _openPlaceDetail(selected),
                    onViewDetails: () => _openPlaceDetail(selected),
                  ),
                ),
              if (state.visiblePlaces.isEmpty)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 100,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No places found in Egypt.'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Catalog empty on both sources; [controller.retry] restarts the load.
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

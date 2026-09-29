import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:triply/features/UserProfile/view/profile_screen.dart';
import 'package:triply/features/home/view/home_screen.dart';

import '../controller/map_controller.dart';
import '../../../core/widgets/app_bottom_nav.dart';
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
  late final MapController controller;
  late final TextEditingController searchController;
  final fmap.MapController _mapController = fmap.MapController();

  @override
  void initState() {
    super.initState();
    controller = MapController();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openPlaceDetail(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
    );
  }

  /// Real markers driven by controller state (lat/lng from Place model).
  List<fmap.Marker> get _markers {
    return controller.visiblePlaces.map((place) {
      return fmap.Marker(
        point: latlng.LatLng(place.latitude, place.longitude),
        width: 40,
        height: 40,
        child: MapPlaceMarker(
          onTap: () {
            setState(() => controller.selectPlace(place));
          },
        ),
      );
    }).toList();
  }

  latlng.LatLng get _initialCenter {
    final selected = controller.selectedPlace;
    if (selected != null) {
      return latlng.LatLng(selected.latitude, selected.longitude);
    }
    return _egyptCenter;
  }

  double get _initialZoom {
    return controller.selectedPlace != null ? _focusedZoom : _egyptZoom;
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
    setState(() => controller.setSearchQuery(v));
    _focusSelected();
  }

  void _onSearchSubmitted(String v) {
    setState(() => controller.submitSearch(v));
    _focusSelected();
  }

  void _onFilterSelected(MapFilter filter) {
    setState(() => controller.selectFilter(filter));
    _focusSelected();
  }

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedPlace;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: MapSearchField(
                controller: searchController,
                searchQuery: controller.searchQuery,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                onClear: () {
                  searchController.clear();
                  setState(() => controller.clearSearch());
                  _focusSelected();
                },
              ),
            ),
            MapFilterChips(
              selectedFilter: controller.selectedFilter,
              onFilterSelected: _onFilterSelected,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  fmap.FlutterMap(
                    mapController: _mapController,
                    options: fmap.MapOptions(
                      initialCenter: _initialCenter,
                      initialZoom: _initialZoom,
                    ),
                    children: [
                      fmap.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.triply_app',
                      ),
                      fmap.MarkerLayer(markers: _markers),
                    ],
                  ),
                  if (selected != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: PlacePreviewCard(
                        place: selected,
                        onTap: () => _openPlaceDetail(selected),
                        onViewDetails: () => _openPlaceDetail(selected),
                      ),
                    ),
                  if (controller.visiblePlaces.isEmpty)
                    const Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
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
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
          Navigator.push(context,MaterialPageRoute(builder: ((context)=>HomeScreen())));
          }
          //else if (index == 1) {
          //Navigator.push(context,MaterialPageRoute(builder: ((context)=>MapScreen())));  trips
          //} 
          else if (index == 3) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>CommunityScreen()))); 
          }
           else if (index == 4) {
            Navigator.push(context,MaterialPageRoute(builder: ((context)=>ProfileScreen())));
         }           

        },
      ),
    );
  }
}

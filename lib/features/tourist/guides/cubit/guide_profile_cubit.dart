import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/mock/tourist/mock_trips.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'package:triply/features/tourist/guides/model/trip.dart';

part 'guide_profile_state.dart';

/// The profile of one tour guide.
///
/// The guide and its trips come from Firestore — the approved ones. The
/// guide is addressed by its uid, the very same key the trip documents
/// carry, so the trips are found without matching names.
class GuideProfileCubit extends Cubit<GuideProfileState>
    with SafeEmitMixin<GuideProfileState> {
  GuideProfileCubit({
    required this.guideId,
    PublicGuidesRepository? guidesRepository,
    PublicTripsRepository? tripsRepository,
  }) : _guidesRepository = guidesRepository ?? PublicGuidesRepository(),
       _tripsRepository = tripsRepository ?? PublicTripsRepository(),
       super(const GuideProfileInitial()) {
    load();
  }

  final String guideId;
  final PublicGuidesRepository _guidesRepository;
  final PublicTripsRepository _tripsRepository;

  Guide _guide = _mockGuide();
  List<Trip> _trips = const [];
  bool _isBookmarked = false;

  Guide get guide => _guide;
  List<Trip> get trips => _trips;
  bool get isBookmarked => _isBookmarked;

  /// Reads the guide and its trips.
  Future<void> load() async {
    safeEmit(const GuideProfileLoading());
    try {
      final remote = await _guidesRepository.fetchGuide(guideId);
      if (remote != null) {
        _guide = Guide.fromPublicGuide(remote);
      }

      final remoteTrips = await _tripsRepository.fetchApprovedTripsOfGuide(
        guideId,
      );
      _trips = remoteTrips == null
          ? _mockTrips()
          : remoteTrips.map(Trip.fromPublicTrip).toList();

      safeEmit(
        GuideProfileSuccess(
          guide: _guide,
          trips: _trips,
          isBookmarked: _isBookmarked,
        ),
      );
    } catch (e) {
      safeEmit(GuideProfileError(error: e.toString()));
    }
  }

  void toggleBookmark() {
    _isBookmarked = !_isBookmarked;
    final current = state;
    if (current is! GuideProfileSuccess) return;
    safeEmit(
      GuideProfileSuccess(
        guide: current.guide,
        trips: current.trips,
        isBookmarked: _isBookmarked,
      ),
    );
  }

  /// The bundled guide, used when Firestore cannot be reached.
  static Guide _mockGuide() {
    final found = mockGuides.firstWhere(
      (g) => g.id == '',
      orElse: () => mockGuides.first,
    );
    return found;
  }

  /// The bundled trips, used when Firestore cannot be reached.
  static List<Trip> _mockTrips() => mockTripsForGuide(mockGuides.first.id);
}

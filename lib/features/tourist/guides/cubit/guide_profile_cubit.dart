import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  bool _isBookmarked = false;

  bool get isBookmarked => _isBookmarked;

  /// Reads the guide and its trips.
  Future<void> load() async {
    safeEmit(const GuideProfileLoading());
    try {
      final remote = await _guidesRepository.fetchGuide(guideId);
      if (remote == null || !remote.isApproved) {
        throw StateError('This guide is unavailable or not approved.');
      }
      final guide = Guide.fromPublicGuide(remote);

      final remoteTrips = await _tripsRepository.fetchApprovedTripsOfGuide(
        guideId,
      );
      if (remoteTrips == null) {
        throw StateError('Could not load this guide’s trips.');
      }
      final trips = remoteTrips.map(Trip.fromPublicTrip).toList();

      safeEmit(
        GuideProfileSuccess(
          guide: guide,
          trips: trips,
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
}

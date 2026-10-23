import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/safe_emit_mixin.dart';

import '../../../../core/data/repositories/guide_trips_repository.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../model/guide_trip_details.dart';

part 'guide_trip_details_state.dart';

/// Owns guide trip details loading + tab selection.
///
/// The details come from Firestore through [GuideTripsRepository], with
/// the mock dataset as fallback.
class GuideTripDetailsCubit extends Cubit<GuideTripDetailsState>
    with SafeEmitMixin<GuideTripDetailsState> {
  GuideTripDetailsCubit({GuideTripsRepository? repository})
    : _repository = repository ?? GuideTripsRepository(),
      super(const GuideTripDetailsInitial());

  final GuideTripsRepository _repository;

  /// The tab the details are showing.
  int _selectedTab = 0;

  /// Loads the details of [trip].
  Future<void> loadTrip(GuideTrip trip) async {
    safeEmit(const GuideTripDetailsLoading());
    try {
      final stored = await _repository.fetchDetails(trip.id);
      if (stored == null) {
        safeEmit(const GuideTripDetailsError(error: 'Trip not found.'));
        return;
      }
      safeEmit(
        GuideTripDetailsSuccess(
          details: _withLiveGuideIdentity(stored),
          selectedTab: _selectedTab,
        ),
      );
    } catch (e) {
      safeEmit(GuideTripDetailsError(error: e.toString()));
    }
  }

  /// Overlays the signed-in guide's live identity (name + photo from
  /// Firebase Auth) on the details.
  ///
  /// A trip document freezes the guide's name and photo at creation time,
  /// so a photo added to the profile afterwards would never appear on
  /// trips made before. Reading the identity from the signed-in account on
  /// every load keeps every trip in sync — no migration needed. There is
  /// no [copyWith] on the details, so the merge goes through the model's
  /// own [GuideTripDetails.toJson] / [GuideTripDetails.fromJson].
  GuideTripDetails _withLiveGuideIdentity(GuideTripDetails details) {
    String name = '';
    String photo = '';
    try {
      name = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
      photo = FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? '';
    } catch (_) {
      // No Firebase app (plain unit test) — keep the stored identity.
      return details;
    }
    if (name.isEmpty && photo.isEmpty) return details;
    final json = details.toJson();
    if (name.isNotEmpty) json['guideName'] = name;
    if (photo.isNotEmpty) json['guideAvatarUrl'] = photo;
    return GuideTripDetails.fromJson(json);
  }

  /// Switches the details tab. No reload — the details are already in.
  void selectTab(int index) {
    _selectedTab = index;
    final current = state;
    if (current is GuideTripDetailsSuccess) {
      safeEmit(
        GuideTripDetailsSuccess(details: current.details, selectedTab: index),
      );
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../map/model/place.dart';
import '../data/place_resolver.dart';
import '../model/guide.dart';
import 'place_guides_state.dart';

/// Owns the approved guides whose profile location matches this place.
/// Guide read failures are surfaced here instead of substituting mock guides.
class PlaceGuidesCubit extends Cubit<PlaceGuidesState>
    with SafeEmitMixin<PlaceGuidesState> {
  PlaceGuidesCubit({
    required this.resolver,
    PublicGuidesRepository? guidesRepository,
  }) : _repository = guidesRepository ?? PublicGuidesRepository(),
       super(const PlaceGuidesInitial()) {
    load();
  }

  final PlaceResolver resolver;
  final PublicGuidesRepository _repository;

  Future<void> load() async {
    safeEmit(const PlaceGuidesLoading());
    try {
      final place = await resolver.resolve();
      final remote = await _repository.fetchApprovedGuides();
      final guides = _guidesOfPlace(remote, place).map(_toGuide).toList();
      if (isClosed) return;
      safeEmit(PlaceGuidesSuccess(guides: guides));
    } catch (error) {
      if (isClosed) return;
      safeEmit(PlaceGuidesError(error: '$error'));
    }
  }

  void retry() => load();

  /// A guide with an empty or unrelated location is never shown for this
  /// place. The match follows the trips' tolerance (substring in either
  /// direction) but stays strict: no "show everything" fallback.
  List<PublicGuide> _guidesOfPlace(List<PublicGuide> guides, Place place) {
    final needles = [
      place.city.trim().toLowerCase(),
      place.name.trim().toLowerCase(),
    ].where((e) => e.isNotEmpty).toList();
    return guides.where((guide) {
      final location = guide.location.trim().toLowerCase();
      if (location.isEmpty) return false;
      return needles.any(
        (needle) => location.contains(needle) || needle.contains(location),
      );
    }).toList();
  }

  /// The card of a guide, in the shape the place screen shows. The id is the
  /// guide's auth uid (the Firestore document id), not a mock id.
  Guide _toGuide(PublicGuide guide) {
    return Guide(
      id: guide.id,
      name: guide.name,
      specialty: guide.specialty,
      rating: guide.rating,
      reviewsCount: guide.reviewCount,
      pricePerHour: guide.pricePerHour,
      avatarUrl: guide.avatarUrl,
      // The query only returns approved guides.
      verified: guide.isApproved,
    );
  }
}

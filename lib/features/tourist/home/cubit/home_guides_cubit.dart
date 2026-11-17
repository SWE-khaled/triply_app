import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../model/guide.dart';
import 'home_guides_state.dart';

/// Loads only the "Local Guides" section of Home.
class HomeGuidesCubit extends Cubit<HomeGuidesState>
    with SafeEmitMixin<HomeGuidesState> {
  HomeGuidesCubit({PublicGuidesRepository? guidesRepository})
    : _guidesRepository = guidesRepository ?? PublicGuidesRepository(),
      super(const HomeGuidesInitial());

  final PublicGuidesRepository _guidesRepository;

  bool _isLoading = false;
  bool _hasLoaded = false;

  /// Reads approved guides, keeping the same query, mapping, `take(2)` limit
  /// and session guard as the old aggregate Home load.
  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    if (state is HomeGuidesInitial) {
      safeEmit(const HomeGuidesLoading());
    }
    try {
      final remoteGuides = await _guidesRepository.fetchApprovedGuides();
      final guides = remoteGuides
          .map(Guide.fromPublicGuide)
          .take(2)
          .toList(growable: false);
      _hasLoaded = true;
      safeEmit(HomeGuidesSuccess(guides: guides));
    } catch (error) {
      safeEmit(HomeGuidesError(message: pageLoadErrorMessage(error)));
    } finally {
      _isLoading = false;
    }
  }
}

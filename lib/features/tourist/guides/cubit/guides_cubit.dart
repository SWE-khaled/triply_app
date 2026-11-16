import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart'
    show mockGuideLanguageFilters;
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/utils/page_load_error.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

part 'guides_state.dart';

/// The list of the tour guides.
///
/// The guides come from Firestore — approved profiles only.
class GuidesCubit extends Cubit<GuidesState> with SafeEmitMixin<GuidesState> {
  GuidesCubit({PublicGuidesRepository? repository})
    : _repository = repository ?? PublicGuidesRepository(),
      super(const GuidesInitial()) {
    load();
  }

  final PublicGuidesRepository _repository;

  /// Every guide on offer, before the filters.
  List<Guide> _allGuides = const [];

  String _searchQuery = '';
  String _selectedLanguage = 'All';

  String get searchQuery => _searchQuery;
  String get selectedLanguage => _selectedLanguage;
  List<String> get languageFilters => mockGuideLanguageFilters;
  int get totalCount => _allGuides.length;

  /// The guides that pass the filters.
  List<Guide> get filteredGuides => _filter(_searchQuery, _selectedLanguage);

  /// True while the one initial read of this session is in flight.
  bool _isLoading = false;

  /// Reads the approved guides.
  ///
  /// The Cubit is app-session scoped, so a successful read is retained and
  /// never repeated by navigation. [load] only runs again after an error
  /// (the manual retry).
  Future<void> load() async {
    if (_isLoading || state is GuidesSuccess) return;
    _isLoading = true;
    // Only the very first read shows the shimmer; a retry after an error
    // keeps the error view instead of restarting the skeleton.
    if (state is GuidesInitial) safeEmit(const GuidesLoading());
    try {
      final remote = await _repository.fetchApprovedGuides();
      _allGuides = remote.map(Guide.fromPublicGuide).toList();
      _emitSuccess();
    } catch (e) {
      safeEmit(GuidesError(error: pageLoadErrorMessage(e)));
    } finally {
      _isLoading = false;
    }
  }

  void setSearch(String value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    _emitSuccess();
  }

  void setLanguage(String language) {
    if (language == _selectedLanguage) return;
    _selectedLanguage = language;
    _emitSuccess();
  }

  void _emitSuccess() {
    safeEmit(
      GuidesSuccess(
        searchQuery: _searchQuery,
        selectedLanguage: _selectedLanguage,
        guides: _filter(_searchQuery, _selectedLanguage),
        totalCount: _allGuides.length,
      ),
    );
  }

  List<Guide> _filter(String query, String language) {
    final q = query.trim().toLowerCase();
    return _allGuides.where((g) {
      final matchesSearch =
          q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.specialty.toLowerCase().contains(q);
      final matchesLang = language == 'All' || g.languages.contains(language);
      return matchesSearch && matchesLang;
    }).toList();
  }
}

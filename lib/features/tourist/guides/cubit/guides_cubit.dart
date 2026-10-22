import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

part 'guides_state.dart';

/// The list of the tour guides.
///
/// The guides come from Firestore — the approved ones — and the mock
/// dataset is the fallback for when the read fails (offline).
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

  /// Reads the approved guides.
  Future<void> load() async {
    safeEmit(const GuidesLoading());
    try {
      final remote = await _repository.fetchApprovedGuides();
      _allGuides = (remote ?? _mockGuides())
          .map(Guide.fromPublicGuide)
          .toList();
      _emitSuccess();
    } catch (e) {
      safeEmit(GuidesError(error: e.toString()));
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

  /// The bundled guides, used when Firestore cannot be reached.
  static List<PublicGuide> _mockGuides() => mockGuides
      .map(
        (g) => PublicGuide(
          id: g.id,
          name: g.name,
          specialty: g.specialty,
          avatarUrl: g.avatarUrl,
          coverUrl: g.coverUrl,
          location: g.location,
          about: g.about,
          languages: g.languages,
          rating: g.rating,
          reviewCount: g.reviewCount,
          pricePerHour: g.pricePerHour,
          currency: g.currency,
          isApproved: g.isVerified,
        ),
      )
      .toList();
}

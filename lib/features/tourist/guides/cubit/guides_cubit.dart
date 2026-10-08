import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_guides.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';
import 'guides_state.dart';

/// Feature-focused cubit for GuidesListScreen.
/// Holds search + language filter state, exposes filtered Models.
/// No backend, no delays — reads local mock list only.
class GuidesCubit extends Cubit<GuidesState> {
  final List<Guide> _allGuides = mockGuides;

  GuidesCubit() : super(const GuidesState());

  String get searchQuery => state.searchQuery;
  String get selectedLanguage => state.selectedLanguage;
  List<String> get languageFilters => mockGuideLanguageFilters;
  int get totalCount => _allGuides.length;

  List<Guide> get filteredGuides {
    final q = state.searchQuery.trim().toLowerCase();
    return _allGuides.where((g) {
      final matchesSearch = q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.specialty.toLowerCase().contains(q);
      final matchesLang =
          state.selectedLanguage == 'All' ||
          g.languages.contains(state.selectedLanguage);
      return matchesSearch && matchesLang;
    }).toList();
  }

  void setSearch(String value) {
    if (value == state.searchQuery) return;
    emit(state.copyWith(searchQuery: value));
  }

  void setLanguage(String language) {
    if (language == state.selectedLanguage) return;
    emit(state.copyWith(selectedLanguage: language));
  }
}

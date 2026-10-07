import 'package:flutter/foundation.dart';
import 'package:admin_dashboard/core/data/mock/tourist/mock_guides.dart';
import 'package:admin_dashboard/features/tourist/guides/model/guide.dart';

/// Feature-focused controller for GuidesListScreen.
/// Holds search + language filter state, exposes filtered Models.
/// No backend, no delays — reads local mock list only.
class GuidesController extends ChangeNotifier {
  final List<Guide> _allGuides = mockGuides;

  String _searchQuery = '';
  String _selectedLanguage = 'All';

  String get searchQuery => _searchQuery;
  String get selectedLanguage => _selectedLanguage;
  List<String> get languageFilters => mockGuideLanguageFilters;
  int get totalCount => _allGuides.length;

  List<Guide> get filteredGuides {
    final q = _searchQuery.trim().toLowerCase();
    return _allGuides.where((g) {
      final matchesSearch = q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.specialty.toLowerCase().contains(q);
      final matchesLang =
          _selectedLanguage == 'All' || g.languages.contains(_selectedLanguage);
      return matchesSearch && matchesLang;
    }).toList();
  }

  void setSearch(String value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setLanguage(String language) {
    if (language == _selectedLanguage) return;
    _selectedLanguage = language;
    notifyListeners();
  }
}


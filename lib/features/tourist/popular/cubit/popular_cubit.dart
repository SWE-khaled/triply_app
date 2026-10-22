import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/data/mock/tourist/mock_trips_public.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';
import '../../trips/models/trip.dart';

part 'popular_state.dart';

/// The trips the tourists may book.
///
/// The trips come from Firestore — the approved ones — and the mock
/// dataset is the fallback for when the read fails (offline). An empty
/// list is a real answer: no trip is approved yet.
class PopularCubit extends Cubit<PopularState>
    with SafeEmitMixin<PopularState> {
  PopularCubit({PublicTripsRepository? repository})
    : _repository = repository ?? PublicTripsRepository(),
      super(const PopularInitial()) {
    load();
  }

  static const List<String> categories = [
    'All',
    'Activities',
    'Historical',
    'Nature',
    'Food',
  ];

  final PublicTripsRepository _repository;

  /// Every trip on offer, before the category filter.
  List<PublicTrip> _all = const [];

  /// The category the list is filtered by.
  String _selectedCategory = 'All';

  /// Reads the approved trips and applies the current filter.
  Future<void> load() async {
    safeEmit(const PopularLoading());
    try {
      final remote = await _repository.fetchApprovedTrips();
      _all = remote ?? _mockTrips();
      _applyCategory(_selectedCategory);
    } catch (e) {
      safeEmit(PopularError(error: e.toString()));
    }
  }

  /// Switches the category. No reload — the trips are already loaded.
  void selectCategory(String category) => _applyCategory(category);

  void _applyCategory(String category) {
    _selectedCategory = category;
    safeEmit(
      PopularSuccess(
        selectedCategory: category,
        trips: _filter(category).map(Trip.fromPublicTrip).toList(),
      ),
    );
  }

  List<PublicTrip> _filter(String category) => category == 'All'
      ? _all
      : _all
            .where((t) => t.category.toLowerCase() == category.toLowerCase())
            .toList();

  /// The bundled trips, used when Firestore cannot be reached.
  static List<PublicTrip> _mockTrips() => mockTripsJson
      .map(
        (e) => PublicTrip(
          id: e['id'] as String,
          guideId: '',
          title: e['title'] as String,
          location: '',
          dateLabel: e['dateLabel'] as String,
          durationLabel: '',
          imageUrl: e['imageUrl'] as String,
          guideName: e['guideName'] as String,
          tag: (e['category'] as String?) ?? 'historical',
          priceEgp: ((e['priceEgp'] as num?) ?? 0).toDouble(),
          capacity: ((e['capacity'] as num?) ?? 0).toInt(),
          bookedSeats: ((e['peopleCount'] as num?) ?? 0).toInt(),
        ),
      )
      .toList();
}

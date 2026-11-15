import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/data/models/public_guide.dart';
import 'package:triply/core/data/models/public_trip.dart';
import 'package:triply/core/data/repositories/public_guides_repository.dart';
import 'package:triply/core/data/repositories/public_trips_repository.dart';
import 'package:triply/features/tourist/booking/cubit/booking_cubit.dart';
import 'package:triply/features/tourist/guides/cubit/guide_profile_cubit.dart';
import 'package:triply/features/tourist/guides/cubit/guides_cubit.dart';
import 'package:triply/features/tourist/guides/model/guide.dart';

void main() {
  group('Guide currency and booking identity', () {
    test(
      'defaults a missing currency to EGP and preserves an explicit one',
      () {
        final defaultCurrency = PublicGuide.fromDocument({
          'name': 'Nadia',
          'isApproved': true,
        }, 'guide-uid');
        final explicitCurrency = PublicGuide.fromDocument({
          'name': 'Nadia',
          'currency': 'USD',
          'isApproved': true,
        }, 'guide-uid');
        final emptyCurrency = PublicGuide.fromDocument({
          'name': 'Nadia',
          'currency': ' ',
          'isApproved': true,
        }, 'guide-uid');

        expect(defaultCurrency.currency, 'EGP');
        expect(explicitCurrency.currency, 'USD');
        expect(emptyCurrency.currency, 'EGP');
        expect(
          Guide.fromPublicGuide(defaultCurrency).formatPrice(125),
          'EGP 125',
        );
      },
    );

    test('booking uses the actual guide identity and price', () async {
      final guide = Guide.fromPublicGuide(_guide());
      final cubit = BookingCubit(guide: guide);

      expect(cubit.guideId, 'real-guide-uid');
      expect(cubit.guide.name, 'Nadia');
      expect(cubit.guide.avatarUrl, 'https://example.test/guide.png');
      expect(cubit.guide.pricePerHour, 125);
      expect(cubit.guide.formatPrice(cubit.guide.pricePerHour), 'EGP 125');

      final booking = cubit.confirm();
      expect(booking.guideId, 'real-guide-uid');
      expect(booking.pricePerHour, 125);
      expect(booking.total, 1050);
      await cubit.close();
    });
  });

  group('Guide profile availability', () {
    test('missing guide produces an error state', () async {
      final cubit = GuideProfileCubit(
        guideId: 'missing-guide',
        guidesRepository: _FakeGuidesRepository(null),
        tripsRepository: _FakeTripsRepository(const []),
      );

      final result = await cubit.stream.firstWhere(
        (state) => state is GuideProfileError,
      );

      expect(result, isA<GuideProfileError>());
      await cubit.close();
    });

    test('unapproved guide produces an error state', () async {
      final cubit = GuideProfileCubit(
        guideId: 'real-guide-uid',
        guidesRepository: _FakeGuidesRepository(_guide(isApproved: false)),
        tripsRepository: _FakeTripsRepository(const []),
      );

      final result = await cubit.stream.firstWhere(
        (state) => state is GuideProfileError,
      );

      expect(result, isA<GuideProfileError>());
      await cubit.close();
    });

    test('empty trips are success but failed trips are an error', () async {
      final emptyTripsCubit = GuideProfileCubit(
        guideId: 'real-guide-uid',
        guidesRepository: _FakeGuidesRepository(_guide()),
        tripsRepository: _FakeTripsRepository(const []),
      );
      final emptyTripsState = await emptyTripsCubit.stream.firstWhere(
        (state) => state is GuideProfileSuccess,
      );

      expect((emptyTripsState as GuideProfileSuccess).trips, isEmpty);
      await emptyTripsCubit.close();

      final failedTripsCubit = GuideProfileCubit(
        guideId: 'real-guide-uid',
        guidesRepository: _FakeGuidesRepository(_guide()),
        tripsRepository: _FakeTripsRepository(null),
      );
      final failedTripsState = await failedTripsCubit.stream.firstWhere(
        (state) => state is GuideProfileError,
      );

      expect(failedTripsState, isA<GuideProfileError>());
      await failedTripsCubit.close();
    });
  });

  group('Guides list repository results', () {
    test('a successful empty read stays an empty success', () async {
      final cubit = GuidesCubit(repository: _FakeGuideListRepository(const []));

      final result = await cubit.stream.firstWhere(
        (state) => state is GuidesSuccess,
      );

      expect((result as GuidesSuccess).guides, isEmpty);
      await cubit.close();
    });

    test('a failed read emits an error instead of mock guides', () async {
      final cubit = GuidesCubit(
        repository: _FakeGuideListRepository(const [], shouldThrow: true),
      );

      final result = await cubit.stream.firstWhere(
        (state) => state is GuidesError,
      );

      expect(result, isA<GuidesError>());
      await cubit.close();
    });
  });
}

PublicGuide _guide({bool isApproved = true}) => PublicGuide(
  id: 'real-guide-uid',
  name: 'Nadia',
  specialty: 'Egyptologist',
  avatarUrl: 'https://example.test/guide.png',
  coverUrl: 'https://example.test/cover.png',
  location: 'Cairo',
  about: 'Local guide',
  languages: const ['English'],
  rating: 4.9,
  reviewCount: 18,
  pricePerHour: 125,
  currency: 'EGP',
  isApproved: isApproved,
);

class _FakeGuidesRepository extends PublicGuidesRepository {
  _FakeGuidesRepository(this.guide);

  final PublicGuide? guide;

  @override
  Future<PublicGuide?> fetchGuide(String guideId) async => guide;
}

class _FakeGuideListRepository extends PublicGuidesRepository {
  _FakeGuideListRepository(this.guides, {this.shouldThrow = false});

  final List<PublicGuide> guides;
  final bool shouldThrow;

  @override
  Future<List<PublicGuide>> fetchApprovedGuides() async {
    if (shouldThrow) throw StateError('Guide read failed.');
    return guides;
  }
}

class _FakeTripsRepository extends PublicTripsRepository {
  _FakeTripsRepository(this.trips);

  final List<PublicTrip>? trips;

  @override
  Future<List<PublicTrip>?> fetchApprovedTripsOfGuide(String guideId) async =>
      trips;
}

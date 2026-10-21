import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/common/AuthTourguide/data/tour_guide_auth_service.dart';
import 'package:triply/features/common/AuthTourist/data/auth_repository.dart';

/// The roles are exclusive: an account is either a tourist or a tour
/// guide for its whole life.
///
/// These tests lock that in — the two halves of it are the role the
/// client writes and the rules that pin it.
void main() {
  group('the two roles are exclusive', () {
    test('a tourist account and a guide account carry different roles', () {
      expect(AuthRepository.touristRole, isNot(TourGuideProfile.guideRole));
    });

    test('the guide profile carries the guide role', () {
      const profile = TourGuideProfile(
        uid: 'g1',
        name: 'Nour Abdallah',
        email: 'nour@example.com',
        phone: '01000000000',
        licenseNumber: 'LIC-1',
        languages: ['ar', 'en'],
      );

      final map = profile.toMap();

      expect(map['role'], TourGuideProfile.guideRole);
      // The admin suspends a guide by clearing `isActive`, so the field
      // has to be there from the start.
      expect(map['isActive'], true);
      expect(map['name'], 'Nour Abdallah');
    });
  });

  group('the rules keep the roles apart', () {
    final rules = File('firestore.rules').readAsStringSync();

    test('a profile can only be created with a role', () {
      // `.get('role', '')` returns an empty string for a missing field,
      // and an empty string is in neither list — so a profile without a
      // role can never be created.
      expect(
        rules,
        contains(
          "request.resource.data.get('role', '') in ['tourist', 'guide']",
        ),
      );
    });

    test('the role of a profile is pinned on update', () {
      expect(
        rules,
        contains(
          "request.resource.data.get('role', '') == resource.data.get('role', '')",
        ),
      );
    });

    test('the rules never dot-access a field that may be missing', () {
      // Dot-access on a missing field ERRORS in the rules, and that
      // error denies the whole rule — it broke the guide profile edit and
      // the tourist sign-up twice.
      expect(
        rules,
        isNot(
          contains('request.resource.data.role == resource.data.role'),
        ),
      );
      expect(
        rules,
        isNot(
          contains(
            'request.resource.data.isActive == resource.data.isActive',
          ),
        ),
      );
      expect(
        rules,
        isNot(
          contains(
            'request.resource.data.isApproved == resource.data.isApproved',
          ),
        ),
      );
      expect(rules, contains("resource.data.get('isActive', false)"));
      expect(rules, contains("resource.data.get('isApproved', false)"));
    });

    test('the admin role can only be claimed once', () {
      expect(rules, contains("noAdminExists()"));
      expect(
        rules,
        contains("request.resource.data.get('role', '') == 'admin'"),
      );
    });
  });
}

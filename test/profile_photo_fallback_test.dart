import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tourist/user_profile/cubit/profile_details_state.dart';

void main() {
  test(
    'an explicitly cleared profile photo does not fall back to Auth photo',
    () {
      const state = ProfileDetailsReady(
        name: 'Traveler',
        photoUrl: '',
        photoWasCleared: true,
        city: '',
        country: '',
        bio: '',
      );

      expect(
        state.photoUrlWithAuthFallback('https://example.test/old-photo.jpg'),
        isNull,
      );
    },
  );

  test('uses the Auth photo for profiles without a saved photo field', () {
    const state = ProfileDetailsReady(
      name: 'Traveler',
      photoUrl: '',
      photoWasCleared: false,
      city: '',
      country: '',
      bio: '',
    );

    expect(
      state.photoUrlWithAuthFallback('https://example.test/photo.jpg'),
      'https://example.test/photo.jpg',
    );
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../../../../core/data/mock/tourist/mock_emergency_contacts.dart';
import '../../../../core/data/mock/tourist/mock_profile.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../model/emergency_contact.dart';
import 'profile_state.dart';

/// Session-level profile compatibility cubit.
///
/// Profile data, posts, editing and logout now have their own cubits. This one
/// deliberately keeps the original provider shape, the `toggleNotifications`
/// API and the `notificationsEnabled` state field used by Settings, plus the
/// in-memory language, stats and emergency contacts getters.
class ProfileCubit extends Cubit<ProfileState>
    with SafeEmitMixin<ProfileState> {
  /// [userId] is accepted so the existing provider stays unchanged. The
  /// session-only preferences below do not depend on it.
  ProfileCubit({String? userId})
    : super(
        ProfileReady(
          notificationsEnabled: true,
          selectedLanguage: mockDefaultLanguage,
        ),
      );

  List<String> get languages => mockLanguages;

  /// Trips count is driven by the real My Trips bookings; other stats stay
  /// mock, exactly as before.
  Map<String, int> get stats => {
    ...mockProfileStats,
    'trips': MyBookingsPublic.count,
  };

  List<EmergencyContact> get emergencyContacts =>
      mockEmergencyContactsRaw.map(EmergencyContact.fromJson).toList();

  void toggleNotifications(bool value) {
    safeEmit(
      ProfileReady(
        notificationsEnabled: value,
        selectedLanguage: state.selectedLanguage,
      ),
    );
  }

  void setLanguage(String language) {
    if (!mockLanguages.contains(language)) return;
    safeEmit(
      ProfileReady(
        notificationsEnabled: state.notificationsEnabled,
        selectedLanguage: language,
      ),
    );
  }
}

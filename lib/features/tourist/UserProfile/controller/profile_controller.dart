import 'package:flutter/foundation.dart';
import '../../../../core/data/mock/tourist/mock_emergency_contacts.dart';
import '../../../../core/data/mock/tourist/mock_profile.dart';
import '../../../../core/data/my_bookings_public.dart';
import '../model/emergency_contact.dart';

class ProfileController extends ChangeNotifier {
  bool notificationsEnabled = true;
  String selectedLanguage = mockDefaultLanguage;

  List<String> get languages => mockLanguages;

  /// Trips count is driven by the real My Trips bookings
  /// (increments with every added trip); other stats stay mock.
  Map<String, int> get stats => {
        ...mockProfileStats,
        'trips': MyBookingsPublic.count,
      };

  List<EmergencyContact> get emergencyContacts =>
      mockEmergencyContactsRaw.map(EmergencyContact.fromJson).toList();

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setLanguage(String language) {
    if (!mockLanguages.contains(language)) return;
    selectedLanguage = language;
    notifyListeners();
  }
}
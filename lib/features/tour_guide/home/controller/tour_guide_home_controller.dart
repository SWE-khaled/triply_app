import 'package:flutter/foundation.dart';

class TourGuideHomeController extends ChangeNotifier {
  int bottomNavIndex = 0;
  bool isVerified = false;

  void setBottomNavIndex(int index) {
    bottomNavIndex = index;
    notifyListeners();
  }

  void checkVerificationStatus() {
    // In a real app, you would check the backend for verification status
    isVerified = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:triply/features/tourist/checkout/style.dart';
import '../../../../core/theme/app_colors.dart';
import 'model/payment_data.dart';
import 'model/user_data.dart';

/// The Paymob credentials of the app.
///
/// The keys come from the `.env` file in the root of the project — the
/// file is git-ignored, so the keys never enter the repository:
///
/// ```
/// PAYMOB_API_KEY=...
/// PAYMOB_INTEGRATION_ID=...
/// PAYMOB_IFRAME_ID=...
/// ```
///
/// A value that is missing falls back to the sandbox constants below, so
/// a fresh clone still runs the whole payment flow (with the sandbox test
/// card, and without moving real money).
class PaymobSettings {
  // ----- Sandbox fallbacks (used only when the file has no value) -----
  static const String _fallbackApiKey = '';
  static const String _fallbackIntegrationId = '';
  static const String _fallbackIframeId = '';

  /// The API key of the Paymob account.
  static String get apiKey => _envValue('PAYMOB_API_KEY', _fallbackApiKey);

  /// The id of the online card integration.
  static String get integrationId =>
      _envValue('PAYMOB_INTEGRATION_ID', _fallbackIntegrationId);

  /// The id of the iframe the card form is opened in.
  static String get iframeId =>
      _envValue('PAYMOB_IFRAME_ID', _fallbackIframeId);

  /// The id of the mobile wallet integration — only when the project has
  /// one.
  static String get walletIntegrationId =>
      _envValue('PAYMOB_WALLET_INTEGRATION_ID', '');

  /// Hands the credentials — and the look — to the package.
  ///
  /// Called once when the app starts, and again after a sign-in so the
  /// billing data of the payment carries the tourist.
  static void initialize({String? name, String? email, String? phone}) {
    PaymentData.initialize(
      apiKey: apiKey,
      iframeId: iframeId,
      integrationCardId: integrationId,
      integrationMobileWalletId: walletIntegrationId,
      userData: UserData(
        name: (name ?? '').isEmpty ? 'NA' : name!,
        lastName: 'NA',
        email: (email ?? '').isEmpty ? 'NA' : email!,
        phone: (phone ?? '').isEmpty ? 'NA' : phone!,
      ),
      style: Style(
        primaryColor: AppColors.primary,
        appBarBackgroundColor: AppColors.primary,
        appBarForegroundColor: Colors.white,
        unselectedColor: AppColors.subtitle,
        scaffoldColor: Colors.white,
        circleProgressColor: AppColors.primary,
      ),
    );
  }

  /// A value of the `.env` file, or the fallback.
  ///
  /// `dotenv.env` throws when the file was never loaded, so the read
  /// must never throw — the sandbox constant is always there.
  static String _envValue(String key, String fallback) {
    try {
      final value = dotenv.env[key] ?? '';
      return value.isNotEmpty ? value : fallback;
    } catch (_) {
      return fallback;
    }
  }
}

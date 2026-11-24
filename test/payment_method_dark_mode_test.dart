import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/checkout/model/payment_data.dart';
import 'package:triply/features/tourist/checkout/style.dart';
import 'package:triply/features/tourist/checkout/view/payment_view.dart';

void main() {
  setUp(() {
    PaymentData.initialize(
      apiKey: '',
      iframeId: '',
      integrationCardId: '',
      integrationMobileWalletId: '',
      style: Style(
        primaryColor: AppColors.primary,
        appBarBackgroundColor: AppColors.primary,
        appBarForegroundColor: Colors.white,
        unselectedColor: AppColors.subtitle,
        scaffoldColor: Colors.white,
        circleProgressColor: AppColors.primary,
      ),
    );
  });

  testWidgets('payment method screen adapts to dark and retains light colors', (
    tester,
  ) async {
    await tester.pumpWidget(_app(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppThemeDark.backgroundPrimary,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).foregroundColor,
      AppThemeDark.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Pay with Visa')).style?.color,
      AppThemeDark.homeGuideName,
    );
    expect(
      tester.widget<Text>(find.text('Pay with Mobile Wallet')).style?.color,
      AppThemeDark.homeGuideSecondary,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('Confirm Payment'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      AppThemeDark.homeSeeAll,
    );

    await tester.tap(find.text('Pay with Mobile Wallet'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byType(TextField))
          .decoration
          ?.hintStyle
          ?.color,
      AppThemeDark.textDisabled,
    );

    await tester.pumpWidget(_app(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
      AppColors.primary,
    );
    expect(
      tester.widget<Text>(find.text('Pay with Mobile Wallet')).style,
      isNull,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('Confirm Payment'),
              matching: find.byType(ElevatedButton),
            ),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      AppColors.primary,
    );
  });
}

Widget _app(ThemeMode mode) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: PaymentView(
      onPaymentSuccess: () {},
      onPaymentError: () {},
      price: 250,
      flow: PaymentFlow.privateBooking,
    ),
  );
}

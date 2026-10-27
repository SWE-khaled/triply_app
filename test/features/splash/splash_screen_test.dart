import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/splash/splash_screen.dart';

void main() {
  testWidgets('replaces splash with the destination after about two seconds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          nextPageBuilder: (_) =>
              const Scaffold(body: Center(child: Text('Destination'))),
        ),
      ),
    );
    for (var frame = 0; frame < 19; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('triply-splash-screen')), findsOneWidget);

    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text('Destination'), findsOneWidget);
    expect(find.byKey(const Key('triply-splash-screen')), findsNothing);
    expect(
      await tester.state<NavigatorState>(find.byType(Navigator)).maybePop(),
      isFalse,
    );
    expect(find.text('Destination'), findsOneWidget);
  });
}

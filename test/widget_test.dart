import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:triply/features/tour_guide/role_selection/view/role_selection_screen.dart';

void main() {
  testWidgets('RoleSelectionScreen shows branding, roles and admin entry',
      (WidgetTester tester) async {
    // Phone-sized surface: the cards need more vertical room than the
    // default 800x600 test viewport provides (production layout untouched).
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoleSelectionScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Triply'), findsOneWidget);
    expect(find.text('How will you\nuse Triply?'), findsOneWidget);
    expect(find.text('Tourist'), findsOneWidget);
    expect(find.text('Tour Guide'), findsOneWidget);
    expect(find.text('Triply Admin Portal'), findsOneWidget);
  });
}

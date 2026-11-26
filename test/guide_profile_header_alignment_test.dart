import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tour_guide/profile_tg/widgets/profile_header.dart';

void main() {
  testWidgets('centers guide name, location, and phone rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            displayName: 'Guide name',
            displayAvatar: '',
            displayLocation: 'Cairo',
            displayPhone: '+20 100 000 0000',
          ),
        ),
      ),
    );
    await tester.pump();

    final centerX = tester.getCenter(find.byType(Scaffold)).dx;
    for (final label in ['Guide name', 'Cairo', '+20 100 000 0000']) {
      final row = find
          .ancestor(of: find.text(label), matching: find.byType(Row))
          .first;
      expect((tester.getCenter(row).dx - centerX).abs(), lessThan(1));
    }
  });
}

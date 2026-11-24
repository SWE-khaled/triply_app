import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/core/theme/app_colors.dart';
import 'package:triply/core/theme/app_theme_dark.dart';
import 'package:triply/features/tourist/notifications/model/notification_item.dart';
import 'package:triply/features/tourist/notifications/widget/notification_tile.dart';

void main() {
  testWidgets('Notification tile supports dark and light palettes', (
    tester,
  ) async {
    final item = NotificationItem(
      id: 'notification-1',
      type: 'message',
      title: 'New message',
      body: 'A traveler sent you a message.',
      timeLabel: 'Just now',
      isRead: false,
      section: 'today',
    );

    await tester.pumpWidget(_app(ThemeMode.dark, item));

    expect(
      tester.widget<Text>(find.text('New message')).style?.color,
      AppThemeDark.homeGuideName,
    );
    expect(
      tester
          .widget<Text>(find.text('A traveler sent you a message.'))
          .style
          ?.color,
      AppThemeDark.homeGuideSecondary,
    );
    expect(
      tester.widget<Text>(find.text('Just now')).style?.color,
      AppThemeDark.homeGuideSecondary,
    );
    expect(
      _iconContainer(tester, AppThemeDark.surfaceElevated).decoration,
      const BoxDecoration(
        color: AppThemeDark.surfaceElevated,
        shape: BoxShape.circle,
      ),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline)).color,
      AppThemeDark.homeSeeAll,
    );

    await tester.pumpWidget(_app(ThemeMode.light, item));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('New message')).style?.color,
      ThemeData.light().textTheme.bodyMedium?.color ?? Colors.black87,
    );
    expect(
      tester
          .widget<Text>(find.text('A traveler sent you a message.'))
          .style
          ?.color,
      AppColors.textGrey,
    );
    expect(
      tester.widget<Text>(find.text('Just now')).style?.color,
      AppColors.textGrey,
    );
    expect(
      _iconContainer(tester, const Color(0xFFE6F3F3)).decoration,
      const BoxDecoration(color: Color(0xFFE6F3F3), shape: BoxShape.circle),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline)).color,
      AppColors.primaryTeal,
    );
  });
}

Container _iconContainer(WidgetTester tester, Color color) {
  return tester.widget<Container>(
    find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.color == color &&
          decoration.shape == BoxShape.circle;
    }),
  );
}

Widget _app(ThemeMode mode, NotificationItem item) {
  return MaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: mode,
    home: Scaffold(body: NotificationTile(item: item)),
  );
}

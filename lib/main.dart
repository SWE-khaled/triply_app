import 'package:flutter/material.dart';
import 'core/theme/d_app_theme.dart';
import 'features/admin_dashboard/d_home/view/d_home_view.dart';

void main() {
  runApp(const TriplyAdminApp());
}

class TriplyAdminApp extends StatelessWidget {
  const TriplyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triply Admin Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeView(),
    );
  }
}

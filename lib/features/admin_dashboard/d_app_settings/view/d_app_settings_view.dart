import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';

/// App Settings screen (connected dynamically to Firestore).
class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  final TextEditingController _commissionCtrl = TextEditingController(
    text: '10',
  );
  String _approvalMode = 'Manual admin approval';
  bool _saving = false;
  StreamSubscription? _sub;

  final List<String> _approvalOptions = [
    'Manual admin approval',
    'Automatic approval',
    'Semi-automatic review',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _sub = FirebaseFirestore.instance
        .collection('appSettings')
        .doc('general')
        .snapshots()
        .listen((doc) {
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final commission = data['commission']?.toString() ?? '10';
          final mode = (data['approvalMode'] as String?) ?? 'Manual admin approval';
          if (_commissionCtrl.text != commission) {
            _commissionCtrl.text = commission;
          }
          if (_approvalOptions.contains(mode)) {
            setState(() {
              _approvalMode = mode;
            });
          }
        }
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _commissionCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      final commission = double.tryParse(_commissionCtrl.text.trim()) ?? 10.0;
      await FirebaseFirestore.instance.collection('appSettings').doc('general').set({
        'commission': commission,
        'approvalMode': _approvalMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage App Settings',
                    subtitle:
                        'Search, review, edit and control all app settings.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search row
            SearchFilterRow(hintText: 'Search app settings...'),
            const SizedBox(height: 24),

            // Settings fields row
            LayoutBuilder(
              builder: (context, constraints) {
                final isStacked = constraints.maxWidth < 600;
                final fields = [
                  // Platform commission
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platform commission',
                          style: AppTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _commissionCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.tableCell,
                          decoration: InputDecoration(
                            suffixText: '%',
                            suffixStyle: AppTextStyles.tableCell.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Guide approval mode
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guide approval', style: AppTextStyles.fieldLabel),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _approvalMode,
                          style: AppTextStyles.tableCell,
                          decoration: const InputDecoration(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted,
                          ),
                          items: _approvalOptions
                              .map(
                                (opt) => DropdownMenuItem(
                                  value: opt,
                                  child: Text(
                                    opt,
                                    style: AppTextStyles.tableCell,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _approvalMode = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ];

                if (isStacked) {
                  return Column(
                    children: [
                      fields[0],
                      const SizedBox(height: 16),
                      fields[1],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fields[0]),
                    const SizedBox(width: 16),
                    Expanded(child: fields[1]),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Save Settings button
            ElevatedButton(
              onPressed: _saving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Save Settings', style: AppTextStyles.buttonPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

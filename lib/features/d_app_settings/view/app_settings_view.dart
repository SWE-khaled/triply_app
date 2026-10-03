import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../d_home/view/home_view.dart';

/// App Settings screen.
class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  final TextEditingController _commissionCtrl =
      TextEditingController(text: '12');
  String _approvalMode = 'Manual admin approval';

  final List<String> _approvalOptions = [
    'Manual admin approval',
    'Automatic approval',
    'Semi-automatic review',
  ];

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platform commission
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Platform commission',
                            style: AppTextStyles.fieldLabel),
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
                ),
                const SizedBox(width: 16),

                // Guide approval mode
                Expanded(
                  child: Container(
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
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted),
                          items: _approvalOptions
                              .map(
                                (opt) => DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt,
                                      style: AppTextStyles.tableCell),
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
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Save Settings button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Save Settings', style: AppTextStyles.buttonPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

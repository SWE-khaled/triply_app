import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// App Settings screen (server-backed commission rate).
///
/// The platform commission persists to `appSettings/serviceFeeRate` (the
/// value the booking Functions read); the guide-approval dropdown has no
/// backend contract and stays local-only.
class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  final TextEditingController _commissionCtrl = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  String _approvalMode = 'Manual admin approval';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  final List<String> _approvalOptions = [
    'Manual admin approval',
    'Automatic approval',
    'Semi-automatic review',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commissionCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rate = await _repo.serviceFeeRate();
      if (!mounted) return;
      _commissionCtrl.text = (rate * 100).toStringAsFixed(
        rate * 100 == (rate * 100).roundToDouble() ? 0 : 2,
      );
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
    }
  }

  static String _message(Object e) {
    const prefix = 'Exception: ';
    final text = e.toString();
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Operation failed. Please try again.' : msg;
  }

  Future<void> _save() async {
    if (_saving) return;
    final parsed = double.tryParse(_commissionCtrl.text.trim());
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid commission number.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.saveServiceFeeRate(
        parsed / 100,
        updatedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Commission rate saved!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_message(e))));
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

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _commissionCtrl.text.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
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
                          Text(
                            'Guide approval',
                            style: AppTextStyles.fieldLabel,
                          ),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Save Settings button
              ElevatedButton(
                onPressed: _saving ? null : _save,
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
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Save Settings', style: AppTextStyles.buttonPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

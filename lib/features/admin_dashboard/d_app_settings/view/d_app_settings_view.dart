import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/app_settings_cubit.dart';

/// App Settings screen (connected dynamically to Firestore).
class AppSettingsView extends StatelessWidget {
  const AppSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppSettingsCubit()..start(),
      child: const _AppSettingsBody(),
    );
  }
}

class _AppSettingsBody extends StatefulWidget {
  const _AppSettingsBody();

  @override
  State<_AppSettingsBody> createState() => _AppSettingsBodyState();
}

class _AppSettingsBodyState extends State<_AppSettingsBody> {
  /// The commission input is the only local form state; everything else
  /// lives in the cubit.
  final TextEditingController _commissionCtrl = TextEditingController(
    text: '10',
  );
  String? _lastSyncedCommission;

  @override
  void dispose() {
    _commissionCtrl.dispose();
    super.dispose();
  }

  void _syncCommission(AppSettingsState state) {
    if (state is! AppSettingsSuccess) return;
    if (state.commission == _lastSyncedCommission) return;
    _lastSyncedCommission = state.commission;
    if (_commissionCtrl.text != state.commission) {
      _commissionCtrl.text = state.commission;
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<AppSettingsCubit>().save(
      _commissionCtrl.text,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(error ?? 'Settings saved successfully!'),
        backgroundColor: error == null ? null : AppColors.adminDanger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppSettingsCubit, AppSettingsState>(
      listener: (context, state) => _syncCommission(state),
      builder: (context, state) {
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

                if (state is AppSettingsInitial || state is AppSettingsLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is AppSettingsError)
                  _SettingsError(
                    message: state.message,
                    onRetry: () => context.read<AppSettingsCubit>().retry(),
                  )
                else
                  ..._buildForm(context, state as AppSettingsSuccess),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildForm(BuildContext context, AppSettingsSuccess state) {
    final fields = [
      // Platform commission
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.adminDivider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform commission', style: AppTextStyles.adminFieldLabel),
            const SizedBox(height: 10),
            TextField(
              controller: _commissionCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.adminTableCell,
              decoration: InputDecoration(
                suffixText: '%',
                suffixStyle: AppTextStyles.adminTableCell.copyWith(
                  color: AppColors.adminTextSecondary,
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
          border: Border.all(color: AppColors.adminDivider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guide approval', style: AppTextStyles.adminFieldLabel),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey(state.approvalMode),
              initialValue: state.approvalMode,
              style: AppTextStyles.adminTableCell,
              decoration: const InputDecoration(),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.adminTextMuted,
              ),
              items: AppSettingsCubit.approvalOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(option, style: AppTextStyles.adminTableCell),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<AppSettingsCubit>().setApprovalMode(value);
                }
              },
            ),
          ],
        ),
      ),
    ];

    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 600;
          if (isStacked) {
            return Column(
              children: [fields[0], const SizedBox(height: 16), fields[1]],
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
        onPressed: state.saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: state.saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text('Save Settings', style: AppTextStyles.adminButtonPrimary),
      ),
    ];
  }
}

class _SettingsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SettingsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.adminTableCellMuted,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.adminPrimary,
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

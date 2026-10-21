import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/helper/price_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../cubit/earnings_cubit.dart';

/// Guide earnings. Self-provides its cubit. Withdraw has no payout
/// backend in this phase â†’ placeholder toast.
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EarningsCubit(),
      child: const _EarningsView(),
    );
  }
}

class _EarningsView extends StatelessWidget {
  const _EarningsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<EarningsCubit, EarningsState>(
          builder: (context, state) {
            return switch (state) {
              EarningsSuccess(:final summary) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleBackButton(
                          icon: Icons.chevron_left,
                          iconColor: AppColors.titleDark,
                          backgroundColor: const Color(0xFFF6F1E7),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Earnings',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.priceTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.tabSelectedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available balance',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'EGP ${formatEgp(summary.availableBalance)}',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => showAppSnackBar(
                              context,
                              'Withdrawals are coming soon',
                              icon: Icons.info_outline,
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Withdraw earnings',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.priceTeal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Recent activity',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.priceTeal,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          summary.month,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (summary.activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'No earnings yet.\nBookings will show up here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(summary.activities.length, (i) {
                        final activity = summary.activities[i];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.priceTeal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '+ EGP ${formatEgp(activity.amountEgp)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.priceTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i != summary.activities.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }),
                  ],
                ),
              ),
              EarningsInitial() || EarningsLoading() => const AppLoadingView(),
              EarningsError(:final error) => AppErrorView(
                message: error,
                onRetry: () => context.read<EarningsCubit>().load(),
              ),
            };
          },
        ),
      ),
    );
  }
}

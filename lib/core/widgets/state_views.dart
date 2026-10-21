import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Shared "we are loading" view for the cubit screens.
///
/// Every guide screen now exposes an explicit Loading state, so they all
/// show the same spinner instead of each one inventing its own.
class AppLoadingView extends StatelessWidget {
  final String? message;

  const AppLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.priceTeal,
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.subtitle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared "something went wrong" view for the cubit screens.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: AppColors.subtitle,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tabSelectedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Try again',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

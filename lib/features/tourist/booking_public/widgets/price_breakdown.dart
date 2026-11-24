import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/app_theme_dark.dart';
import '../../../../core/helper/price_format.dart';

class PriceBreakdown extends StatelessWidget {
  final double unitPrice;
  final int seats;
  final double fee;
  final double total;

  const PriceBreakdown({
    super.key,
    required this.unitPrice,
    required this.seats,
    required this.fee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.resolve(
          context,
          light: Colors.transparent,
          dark: AppThemeDark.homeGuideSurface,
        ),
        border: Border.all(
          color: AppThemeColors.resolve(
            context,
            light: AppColors.cardBorder,
            dark: AppThemeDark.homeGuideBorder,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.title,
                dark: AppThemeDark.homeSectionTitle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _line(
            context,
            'EGP ${formatEgp(unitPrice)} × $seats seat${seats == 1 ? '' : 's'}',
            'EGP ${formatEgp(unitPrice * seats)}',
          ),
          const SizedBox(height: 6),
          _line(context, 'Service fee (5%)', 'EGP ${formatEgp(fee)}'),
          const SizedBox(height: 5),
          Divider(
            height: 24,
            color: AppThemeColors.resolve(
              context,
              light: Theme.of(context).dividerColor,
              dark: AppThemeDark.borderSubtle,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeSectionTitle,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'EGP ${formatEgp(total)}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.resolve(
                    context,
                    light: AppColors.title,
                    dark: AppThemeDark.homeGuidePrice,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppThemeColors.resolve(
                context,
                light: AppColors.dateText,
                dark: AppThemeDark.homeGuideSecondary,
              ),
            ),
          ),
        ),
        Text(
          right,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.resolve(
              context,
              light: AppColors.title,
              dark: AppThemeDark.homeGuideName,
            ),
          ),
        ),
      ],
    );
  }
}

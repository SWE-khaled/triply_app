import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/price_format.dart';

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
        border: Border.all(color: AppColors.cardBorder),
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
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 10),
          _line('EGP ${formatEgp(unitPrice)} × $seats seat${seats == 1 ? '' : 's'}',
              'EGP ${formatEgp(unitPrice * seats)}'),
          const SizedBox(height: 6),
          _line('Service fee (5%)', 'EGP ${formatEgp(fee)}'),
          const SizedBox(height: 5),
          const Divider(height: 24),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
              const Spacer(),
              Text(
                'EGP ${formatEgp(total)}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.title,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.dateText,
            ),
          ),
        ),
        Text(
          right,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/booking_controller.dart';
import '../../../core/constants/app_colors.dart';

class SeatsStepper extends StatelessWidget {
  final int seats;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const SeatsStepper({
    super.key,
    required this.seats,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final personWord = seats == 1 ? 'person' : 'persons';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Seats',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stepBtn(Icons.remove, onDecrement),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$seats',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.title,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      personWord,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              _stepBtn(Icons.add, onIncrement,
                  iconColor: AppColors.tabSelectedBg),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${BookingController.spotsAvailable} spots available',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap,
      {Color iconColor = AppColors.dateText}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F4F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

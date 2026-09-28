import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../model/emergency_contact.dart';

class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final IconData icon;
  final VoidCallback? onCopy;
  final VoidCallback? onCall;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.icon,
    this.onCopy,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: AppColors.guidesName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.guidesName,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.number,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            tooltip: 'Copy number',
            icon: const Icon(Icons.copy_outlined,
                color: AppColors.textGrey),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: onCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.guidesName,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
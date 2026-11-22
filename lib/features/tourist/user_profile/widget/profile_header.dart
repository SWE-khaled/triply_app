import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.name,
    this.photoUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 33, 16, 48),
      decoration:  BoxDecoration(
        //  image: DecorationImage(image: NetworkImage("https://hips.hearstapps.com/hmg-prod/images/horse-replace-002-64945a222f108.jpg?crop=0.670xw:1.00xh;0.114xw,0&resize=640:*"),fit:BoxFit.cover),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.actionSecondary, AppColors.guidesName],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'My profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onEdit,
                  icon:  Icon(
                    Icons.edit_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderStrong, width: 3),
              image: photoUrl != null && photoUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null || photoUrl!.isEmpty
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style:  TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style:  TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

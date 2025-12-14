import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;

  const ProfileAvatar({
    super.key,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: AppShadows.sharpXL,
      ),
      child: CircleAvatar(
        radius: 44,
        backgroundColor: Colors.white,
        child: Text(
          initials,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


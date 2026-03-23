import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileViewSectionHeader extends StatelessWidget {
  final String title;

  final IconData icon;

  final bool isDark;

  const ProfileViewSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandPrimary.withValues(alpha: 0.2),
                AppColors.accentRose.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.brandPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.brandPrimaryDark,
          ),
        ),
      ],
    );
  }
}

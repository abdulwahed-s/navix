import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class SettingsVersionBadge extends StatelessWidget {
  final String version;

  const SettingsVersionBadge({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        version,
        style: TextStyle(
          color: AppColors.successDark,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

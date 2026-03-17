import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ConversationBackground extends StatelessWidget {
  final bool isDark;

  const ConversationBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.darkSurface.withValues(alpha: 0.95),
                ]
              : [
                  AppColors.brandCream,
                  AppColors.brandCream.withValues(alpha: 0.95),
                ],
        ),
      ),
    );
  }
}

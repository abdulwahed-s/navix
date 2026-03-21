import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileEditAnimatedBackground extends StatelessWidget {
  final Animation<double> floatingAnimation;

  final bool isDark;

  const ProfileEditAnimatedBackground({
    super.key,
    required this.floatingAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.12),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentGold.withValues(alpha: 0.1),
                      AppColors.brandCream,
                    ],
            ),
          ),
        );
      },
    );
  }
}

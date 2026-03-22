import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileViewAnimatedBackground extends StatelessWidget {
  final Animation<double> floatingAnimation;

  final bool isDark;

  const ProfileViewAnimatedBackground({
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
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.15),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentLavender.withValues(alpha: 0.12),
                      AppColors.brandCream,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import 'login_background_pattern_painter.dart';

class LoginAnimatedBackground extends StatelessWidget {
  final bool isDark;

  final Size size;

  final Animation<double> floatingAnimation;

  const LoginAnimatedBackground({
    super.key,
    required this.isDark,
    required this.size,
    required this.floatingAnimation,
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
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.3),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.lightPrimaryContainer.withValues(alpha: 0.5),
                      AppColors.brandCream,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: LoginBackgroundPatternPainter(
              isDark: isDark,
              animationValue: floatingAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

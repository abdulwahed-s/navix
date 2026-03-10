import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import 'register_background_pattern_painter.dart';

class RegisterAnimatedBackground extends StatelessWidget {
  final bool isDark;

  final Size size;

  final Animation<double> floatingAnimation;

  const RegisterAnimatedBackground({
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
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.3),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentMint.withValues(alpha: 0.3),
                      AppColors.brandCream,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: RegisterBackgroundPatternPainter(
              isDark: isDark,
              animationValue: floatingAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

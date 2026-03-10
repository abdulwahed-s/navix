import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class LoginFloatingDecorations extends StatelessWidget {
  final bool isDark;

  final Size size;

  final Animation<double> floatingAnimation;

  const LoginFloatingDecorations({
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
        return Stack(
          children: [
            Positioned(
              top: -50 + floatingAnimation.value,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentLavender.withValues(alpha: 0.3),
                      AppColors.accentLavender.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -80 - floatingAnimation.value,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(alpha: 0.25),
                      AppColors.accentMint.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.3 + floatingAnimation.value * 0.5,
              right: -100,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                          .withValues(alpha: 0.15),
                      (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                          .withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

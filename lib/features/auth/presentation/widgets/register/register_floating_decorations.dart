import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class RegisterFloatingDecorations extends StatelessWidget {
  final bool isDark;

  final Size size;

  final Animation<double> floatingAnimation;

  const RegisterFloatingDecorations({
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
              top: -60 + floatingAnimation.value,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.25),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -100 - floatingAnimation.value,
              right: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentRose.withValues(alpha: 0.2),
                      AppColors.accentRose.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.4 - floatingAnimation.value * 0.5,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentLavender.withValues(alpha: 0.2),
                      AppColors.accentLavender.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.15 + floatingAnimation.value * 0.3,
              right: -60,
              child: Container(
                width: 140,
                height: 140,
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

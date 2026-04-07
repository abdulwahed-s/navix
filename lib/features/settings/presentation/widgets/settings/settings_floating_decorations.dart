import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class SettingsFloatingDecorations extends StatelessWidget {
  final bool isDark;
  final Size size;
  final Animation<double> floatingAnimation;

  const SettingsFloatingDecorations({
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
                width: 200,
                height: 200,
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
              bottom: 50 - floatingAnimation.value,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.18),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.35 + floatingAnimation.value * 0.5,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(alpha: 0.15),
                      AppColors.accentMint.withValues(alpha: 0.0),
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

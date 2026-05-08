import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FloatingDecorations extends StatelessWidget {
  final Animation<double> floatingAnimation;

  final bool isDark;

  final Size size;

  const FloatingDecorations({
    super.key,
    required this.floatingAnimation,
    required this.isDark,
    required this.size,
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
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.2),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100 - floatingAnimation.value,
              left: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(alpha: 0.2),
                      AppColors.accentMint.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.4 + floatingAnimation.value * 0.5,
              right: -90,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentRose.withValues(alpha: 0.15),
                      AppColors.accentRose.withValues(alpha: 0.0),
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

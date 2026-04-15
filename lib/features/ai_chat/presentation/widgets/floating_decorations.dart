import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AIChatFloatingDecorations extends StatelessWidget {
  final bool isDark;
  final Size size;
  final Animation<double> floatingAnimation;

  const AIChatFloatingDecorations({
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
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(
                        alpha: isDark ? 0.15 : 0.2,
                      ),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150 - floatingAnimation.value,
              left: -70,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(
                        alpha: isDark ? 0.15 : 0.2,
                      ),
                      AppColors.accentMint.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.4 + floatingAnimation.value * 0.5,
              right: -80,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentRose.withValues(
                        alpha: isDark ? 0.1 : 0.15,
                      ),
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

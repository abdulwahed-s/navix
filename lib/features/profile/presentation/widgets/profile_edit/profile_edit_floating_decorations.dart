import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileEditFloatingDecorations extends StatelessWidget {
  final Animation<double> floatingAnimation;

  final bool isDark;

  final Size size;

  const ProfileEditFloatingDecorations({
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
              top: -40 + floatingAnimation.value,
              left: -60,
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
              bottom: 150 - floatingAnimation.value * 0.8,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentRose.withValues(alpha: 0.18),
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

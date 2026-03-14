import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CalendarFloatingDecorations extends StatelessWidget {
  final bool isDark;

  final Size size;

  final double animationValue;

  const CalendarFloatingDecorations({
    super.key,
    required this.isDark,
    required this.size,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40 + animationValue,
          right: -60,
          child: Container(
            width: 180,
            height: 180,
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
          bottom: 80 - animationValue,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
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
          top: size.height * 0.25 + animationValue * 0.5,
          right: -70,
          child: Container(
            width: 140,
            height: 140,
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
  }
}

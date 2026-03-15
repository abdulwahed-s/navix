import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ChatListFloatingDecorations extends StatelessWidget {
  final bool isDark;

  final Size size;

  final double animationValue;

  const ChatListFloatingDecorations({
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
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentLavender.withValues(alpha: 0.25),
                  AppColors.accentLavender.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 100 - animationValue,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
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
          top: size.height * 0.4 + animationValue * 0.5,
          right: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                      .withValues(alpha: 0.12),
                  (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                      .withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

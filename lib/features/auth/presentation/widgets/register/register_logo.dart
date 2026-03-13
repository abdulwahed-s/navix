import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class RegisterLogo extends StatelessWidget {
  final bool isDark;

  final Animation<double> floatingAnimation;

  const RegisterLogo({
    super.key,
    required this.isDark,
    required this.floatingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value * 0.3),
          child: Container(
            height: 100,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark
                                ? AppColors.darkPrimary
                                : AppColors.brandPrimary)
                            .withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                isDark
                    ? 'assets/images/logoWhite.png'
                    : 'assets/images/logoBlack.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

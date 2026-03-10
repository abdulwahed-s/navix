import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class LoginWelcomeText extends StatelessWidget {
  final String title;

  final String subtitle;

  const LoginWelcomeText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? [AppColors.darkPrimary, AppColors.accentGold]
                : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
          ).createShader(bounds),
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

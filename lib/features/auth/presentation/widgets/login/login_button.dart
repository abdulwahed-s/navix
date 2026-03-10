import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class LoginButton extends StatelessWidget {
  final String label;

  final bool isLoading;

  final VoidCallback? onPressed;

  const LoginButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isLoading
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.5),
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                ]
              : isDark
              ? [AppColors.darkPrimary, AppColors.accentRose]
              : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
        ),
        boxShadow: isLoading
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isDark ? AppColors.darkOnPrimary : Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkOnPrimary
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark
                              ? AppColors.darkOnPrimary
                              : Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

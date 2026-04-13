import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isSelected;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = color ?? AppColors.brandPrimary;

    final needsContrastFix = _needsContrastFix(cardColor, isDark);
    final iconBgColor = needsContrastFix
        ? (isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.8))
        : cardColor.withValues(alpha: 0.2);
    final iconColor = needsContrastFix
        ? (isDark ? Colors.white : cardColor)
        : cardColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? cardColor.withValues(alpha: 0.4)
                  : cardColor.withValues(alpha: 0.2),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          cardColor.withValues(alpha: isDark ? 0.5 : 0.3),
                          cardColor.withValues(alpha: isDark ? 0.3 : 0.15),
                        ]
                      : [
                          cardColor.withValues(alpha: isDark ? 0.3 : 0.15),
                          cardColor.withValues(alpha: isDark ? 0.15 : 0.05),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? cardColor
                      : cardColor.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _needsContrastFix(Color color, bool isDark) {
    final luminance = color.computeLuminance();

    return luminance > 0.4 && !isDark;
  }
}

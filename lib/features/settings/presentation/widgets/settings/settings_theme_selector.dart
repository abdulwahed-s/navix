import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class SettingsThemeSelector extends StatelessWidget {
  final String currentTheme;
  final String lightLabel;
  final String darkLabel;
  final String systemLabel;
  final bool isDark;
  final ValueChanged<String> onThemeChanged;

  const SettingsThemeSelector({
    super.key,
    required this.currentTheme,
    required this.lightLabel,
    required this.darkLabel,
    required this.systemLabel,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _ThemeOption(
            value: 'light',
            currentValue: currentTheme,
            label: lightLabel,
            icon: Icons.light_mode_rounded,
            isDark: isDark,
            isFirst: true,
            onTap: () => onThemeChanged('light'),
          ),
          _ThemeOption(
            value: 'dark',
            currentValue: currentTheme,
            label: darkLabel,
            icon: Icons.dark_mode_rounded,
            isDark: isDark,
            onTap: () => onThemeChanged('dark'),
          ),
          _ThemeOption(
            value: 'system',
            currentValue: currentTheme,
            label: systemLabel,
            icon: Icons.settings_brightness_rounded,
            isDark: isDark,
            isLast: true,
            onTap: () => onThemeChanged('system'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String value;
  final String currentValue;
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.value,
    required this.currentValue,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? [AppColors.darkPrimary, AppColors.accentRose]
                        : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
                  )
                : null,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(15) : Radius.zero,
              right: isLast ? const Radius.circular(15) : Radius.zero,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

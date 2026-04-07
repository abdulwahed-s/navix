import 'package:flutter/material.dart';

class SettingsRadioTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String title;
  final IconData icon;
  final Color activeColor;
  final ValueChanged<T?> onChanged;

  const SettingsRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.icon,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: activeColor,
      title: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? activeColor
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? activeColor : null,
            ),
          ),
        ],
      ),
    );
  }
}

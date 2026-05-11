import 'package:flutter/material.dart';

class GlassIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onPressed;

  final bool isDark;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.colorScheme.onSurface),
        onPressed: onPressed,
      ),
    );
  }
}

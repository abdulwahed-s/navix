import 'package:flutter/material.dart';

class LoginRegisterLink extends StatelessWidget {
  final String promptText;

  final String linkText;

  final bool enabled;

  final VoidCallback? onPressed;

  const LoginRegisterLink({
    super.key,
    required this.promptText,
    required this.linkText,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            linkText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

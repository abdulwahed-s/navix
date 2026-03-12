import 'package:flutter/material.dart';

class RegisterEmailField extends StatelessWidget {
  final TextEditingController controller;

  final FocusNode focusNode;

  final bool hasFocus;

  final bool enabled;

  final String labelText;

  final String hintText;

  final String emailRequiredError;

  final String emailInvalidError;

  final VoidCallback? onFocusChange;

  const RegisterEmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.enabled,
    required this.labelText,
    required this.hintText,
    required this.emailRequiredError,
    required this.emailInvalidError,
    this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      onFocusChange: (_) => onFocusChange?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasFocus
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: enabled,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.email_outlined,
                color: hasFocus
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return emailRequiredError;
            }
            if (!_isValidEmail(value)) {
              return emailInvalidError;
            }
            return null;
          },
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

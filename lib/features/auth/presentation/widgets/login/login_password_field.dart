import 'package:flutter/material.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;

  final FocusNode focusNode;

  final bool hasFocus;

  final bool obscurePassword;

  final bool enabled;

  final String labelText;

  final String hintText;

  final String passwordRequiredError;

  final String passwordTooShortError;

  final VoidCallback onToggleVisibility;

  final VoidCallback onSubmitted;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.obscurePassword,
    required this.enabled,
    required this.labelText,
    required this.hintText,
    required this.passwordRequiredError,
    required this.passwordTooShortError,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
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
        obscureText: obscurePassword,
        textInputAction: TextInputAction.done,
        enabled: enabled,
        onFieldSubmitted: (_) => onSubmitted(),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.lock_outlined,
              color: hasFocus
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey(obscurePassword),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onPressed: onToggleVisibility,
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
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return passwordRequiredError;
          }
          if (value.length < 6) {
            return passwordTooShortError;
          }
          return null;
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RegisterConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;

  final FocusNode focusNode;

  final bool hasFocus;

  final bool enabled;

  final bool obscurePassword;

  final String labelText;

  final String hintText;

  final String confirmPasswordRequiredError;

  final String passwordsDoNotMatchError;

  final String originalPassword;

  final VoidCallback onToggleVisibility;

  final VoidCallback? onFocusChange;

  final VoidCallback? onFieldSubmitted;

  const RegisterConfirmPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.enabled,
    required this.obscurePassword,
    required this.labelText,
    required this.hintText,
    required this.confirmPasswordRequiredError,
    required this.passwordsDoNotMatchError,
    required this.originalPassword,
    required this.onToggleVisibility,
    this.onFocusChange,
    this.onFieldSubmitted,
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
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: enabled,
          onFieldSubmitted: (_) => onFieldSubmitted?.call(),
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.shield_outlined,
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
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return confirmPasswordRequiredError;
            }
            if (value != originalPassword) {
              return passwordsDoNotMatchError;
            }
            return null;
          },
        ),
      ),
    );
  }
}

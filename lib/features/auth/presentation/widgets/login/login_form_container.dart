import 'dart:ui';

import 'package:flutter/material.dart';

import 'login_button.dart';
import 'login_email_field.dart';
import 'login_password_field.dart';

class LoginFormContainer extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController emailController;

  final TextEditingController passwordController;

  final FocusNode emailFocusNode;

  final FocusNode passwordFocusNode;

  final bool emailHasFocus;

  final bool passwordHasFocus;

  final bool obscurePassword;

  final bool isLoading;

  final String emailLabel;

  final String emailHint;

  final String emailRequiredError;

  final String emailInvalidError;

  final String passwordLabel;

  final String passwordHint;

  final String passwordRequiredError;

  final String passwordTooShortError;

  final String loginButtonLabel;

  final VoidCallback onTogglePasswordVisibility;

  final VoidCallback onSubmit;

  const LoginFormContainer({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.emailHasFocus,
    required this.passwordHasFocus,
    required this.obscurePassword,
    required this.isLoading,
    required this.emailLabel,
    required this.emailHint,
    required this.emailRequiredError,
    required this.emailInvalidError,
    required this.passwordLabel,
    required this.passwordHint,
    required this.passwordRequiredError,
    required this.passwordTooShortError,
    required this.loginButtonLabel,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                LoginEmailField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  hasFocus: emailHasFocus,
                  enabled: !isLoading,
                  labelText: emailLabel,
                  hintText: emailHint,
                  emailRequiredError: emailRequiredError,
                  emailInvalidError: emailInvalidError,
                ),
                const SizedBox(height: 20),

                LoginPasswordField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  hasFocus: passwordHasFocus,
                  obscurePassword: obscurePassword,
                  enabled: !isLoading,
                  labelText: passwordLabel,
                  hintText: passwordHint,
                  passwordRequiredError: passwordRequiredError,
                  passwordTooShortError: passwordTooShortError,
                  onToggleVisibility: onTogglePasswordVisibility,
                  onSubmitted: onSubmit,
                ),
                const SizedBox(height: 28),

                LoginButton(
                  label: loginButtonLabel,
                  isLoading: isLoading,
                  onPressed: onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

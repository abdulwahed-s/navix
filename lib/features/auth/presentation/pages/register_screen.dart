import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/register/register_animated_background.dart';
import '../widgets/register/register_button.dart';
import '../widgets/register/register_confirm_password_field.dart';
import '../widgets/register/register_email_field.dart';
import '../widgets/register/register_floating_decorations.dart';
import '../widgets/register/register_form_container.dart';
import '../widgets/register/register_login_link.dart';
import '../widgets/register/register_logo.dart';
import '../widgets/register/register_password_field.dart';
import '../widgets/register/register_password_strength_indicator.dart';
import '../widgets/register/register_welcome_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthenticatedNeedsProfile) {
            context.go(AppRoutes.profileCreate);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onError),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_getLocalizedError(l10n, state.code))),
                  ],
                ),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              RegisterAnimatedBackground(
                isDark: isDark,
                size: size,
                floatingAnimation: _floatingAnimation,
              ),

              RegisterFloatingDecorations(
                isDark: isDark,
                size: size,
                floatingAnimation: _floatingAnimation,
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RegisterLogo(
                                isDark: isDark,
                                floatingAnimation: _floatingAnimation,
                              ),
                              const SizedBox(height: 32),

                              RegisterWelcomeText(
                                title: l10n.registerTitle,
                                subtitle: l10n.registerSubtitle,
                              ),
                              const SizedBox(height: 40),

                              RegisterFormContainer(
                                isDark: isDark,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      RegisterEmailField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        hasFocus: _emailFocusNode.hasFocus,
                                        enabled: !isLoading,
                                        labelText: l10n.email,
                                        hintText: l10n.emailHint,
                                        emailRequiredError: l10n.emailRequired,
                                        emailInvalidError: l10n.emailInvalid,
                                        onFocusChange: () => setState(() {}),
                                      ),
                                      const SizedBox(height: 16),

                                      RegisterPasswordField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        hasFocus: _passwordFocusNode.hasFocus,
                                        enabled: !isLoading,
                                        obscurePassword: _obscurePassword,
                                        labelText: l10n.password,
                                        hintText: l10n.passwordHint,
                                        passwordRequiredError:
                                            l10n.passwordRequired,
                                        passwordTooShortError:
                                            l10n.passwordTooShort,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        onFocusChange: () => setState(() {}),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                      const SizedBox(height: 16),

                                      RegisterConfirmPasswordField(
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocusNode,
                                        hasFocus:
                                            _confirmPasswordFocusNode.hasFocus,
                                        enabled: !isLoading,
                                        obscurePassword:
                                            _obscureConfirmPassword,
                                        labelText: l10n.confirmPassword,
                                        hintText: l10n.confirmPasswordHint,
                                        confirmPasswordRequiredError:
                                            l10n.confirmPasswordRequired,
                                        passwordsDoNotMatchError:
                                            l10n.passwordsDoNotMatch,
                                        originalPassword:
                                            _passwordController.text,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                        onFocusChange: () => setState(() {}),
                                        onFieldSubmitted: _onRegister,
                                      ),
                                      const SizedBox(height: 8),

                                      RegisterPasswordStrengthIndicator(
                                        password: _passwordController.text,
                                      ),
                                      const SizedBox(height: 24),

                                      RegisterButton(
                                        isLoading: isLoading,
                                        label: l10n.register,
                                        onPressed: _onRegister,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              RegisterLoginLink(
                                enabled: !isLoading,
                                promptText: l10n.alreadyHaveAccount,
                                linkText: l10n.signIn,
                                onPressed: () => context.go(AppRoutes.login),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLocalizedError(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'invalid-credential':
        return l10n.authErrorInvalidCredential;
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'email-already-in-use':
        return l10n.authErrorEmailAlreadyInUse;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'invalid-email':
        return l10n.authErrorInvalidEmail;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'network-request-failed':
      case 'network-error':
        return l10n.authErrorNetworkRequestFailed;
      default:
        return l10n.authErrorUnknown;
    }
  }
}

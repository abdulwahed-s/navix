import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login/login_animated_background.dart';
import '../widgets/login/login_floating_decorations.dart';
import '../widgets/login/login_form_container.dart';
import '../widgets/login/login_logo.dart';
import '../widgets/login/login_register_link.dart';
import '../widgets/login/login_welcome_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
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

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
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
              LoginAnimatedBackground(
                isDark: isDark,
                size: size,
                floatingAnimation: _floatingAnimation,
              ),

              LoginFloatingDecorations(
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
                              LoginLogo(
                                isDark: isDark,
                                floatingAnimation: _floatingAnimation,
                              ),
                              const SizedBox(height: 32),

                              LoginWelcomeText(
                                title: l10n.loginTitle,
                                subtitle: l10n.loginSubtitle,
                              ),
                              const SizedBox(height: 40),

                              LoginFormContainer(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                emailFocusNode: _emailFocusNode,
                                passwordFocusNode: _passwordFocusNode,
                                emailHasFocus: _emailFocusNode.hasFocus,
                                passwordHasFocus: _passwordFocusNode.hasFocus,
                                obscurePassword: _obscurePassword,
                                isLoading: isLoading,
                                emailLabel: l10n.email,
                                emailHint: l10n.emailHint,
                                emailRequiredError: l10n.emailRequired,
                                emailInvalidError: l10n.emailInvalid,
                                passwordLabel: l10n.password,
                                passwordHint: l10n.passwordHint,
                                passwordRequiredError: l10n.passwordRequired,
                                passwordTooShortError: l10n.passwordTooShort,
                                loginButtonLabel: l10n.login,
                                onTogglePasswordVisibility: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                onSubmit: _onLogin,
                              ),
                              const SizedBox(height: 24),

                              LoginRegisterLink(
                                promptText: l10n.dontHaveAccount,
                                linkText: l10n.signUp,
                                enabled: !isLoading,
                                onPressed: () => context.go(AppRoutes.register),
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

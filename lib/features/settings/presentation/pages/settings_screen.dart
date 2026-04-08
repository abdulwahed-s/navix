import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings/settings_animated_background.dart';
import '../widgets/settings/settings_floating_decorations.dart';
import '../widgets/settings/settings_glass_section_card.dart';
import '../widgets/settings/settings_loading_state.dart';
import '../widgets/settings/settings_logout_button.dart';
import '../widgets/settings/settings_radio_tile.dart';
import '../widgets/settings/settings_switch_tile.dart';
import '../widgets/settings/settings_theme_selector.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/settings_version_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSettings();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _loadSettings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<SettingsBloc>().add(LoadSettings(userId: userId));
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SettingsAnimatedBackground(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),

          SettingsFloatingDecorations(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),

          SafeArea(
            child: BlocConsumer<SettingsBloc, SettingsState>(
              listener: (context, state) {
                if (state is SettingsSaved) {
                  _showSuccessSnackbar(context, l10n.settingsSaved);
                } else if (state is PasswordChanged) {
                  _showSuccessSnackbar(context, l10n.passwordChanged);
                } else if (state is AccountDeleted || state is LoggedOut) {
                  context.go(AppRoutes.login);
                } else if (state is SettingsError) {
                  _showErrorSnackbar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is SettingsLoading) {
                  return const SettingsLoadingState();
                }

                if (state is SettingsLoaded ||
                    state is SettingsSaved ||
                    state is PasswordChanged ||
                    state is SettingsError && state.previousState != null) {
                  final settings = state is SettingsLoaded
                      ? state.settings
                      : state is SettingsSaved
                      ? state.settings
                      : state is PasswordChanged
                      ? state.previousState.settings
                      : (state as SettingsError).previousState!.settings;
                  return _buildSettings(settings, l10n, theme, isDark);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.riskHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSettings(
    dynamic settings,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsGlassSectionCard(
          icon: Icons.person_rounded,
          title: l10n.accountSettings,
          isDark: isDark,
          accentColor: AppColors.brandPrimary,
          children: [
            SettingsTile(
              icon: Icons.edit_rounded,
              iconColor: AppColors.accentLavender,
              title: l10n.editProfile,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                context.push(AppRoutes.profileEdit);
              },
            ),
            SettingsTile(
              icon: Icons.lock_rounded,
              iconColor: AppColors.accentGold,
              title: l10n.changePassword,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showChangePasswordDialog(context, l10n, isDark),
            ),
            SettingsTile(
              icon: Icons.delete_rounded,
              iconColor: AppColors.riskHigh,
              title: l10n.deleteAccount,
              titleColor: AppColors.riskHigh,
              onTap: () => _showDeleteAccountDialog(context, l10n, isDark),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SettingsGlassSectionCard(
          icon: Icons.notifications_rounded,
          title: l10n.notificationSettings,
          isDark: isDark,
          accentColor: AppColors.accentMint,
          children: [
            SettingsSwitchTile(
              title: l10n.taskAssignments,
              subtitle: l10n.taskAssignmentsDesc,
              value:
                  settings.notificationPreferences['taskAssignments'] ?? true,
              activeColor: AppColors.accentMint,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  UpdateNotificationPreference(
                    key: 'taskAssignments',
                    value: value,
                  ),
                );
              },
            ),
            SettingsSwitchTile(
              title: l10n.projectUpdates,
              subtitle: l10n.projectUpdatesDesc,
              value: settings.notificationPreferences['projectUpdates'] ?? true,
              activeColor: AppColors.accentLavender,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  UpdateNotificationPreference(
                    key: 'projectUpdates',
                    value: value,
                  ),
                );
              },
            ),
            SettingsSwitchTile(
              title: l10n.messageNotifications,
              subtitle: l10n.messageNotificationsDesc,
              value: settings.notificationPreferences['messages'] ?? true,
              activeColor: AppColors.brandPrimary,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  UpdateNotificationPreference(key: 'messages', value: value),
                );
              },
            ),
            SettingsSwitchTile(
              title: l10n.riskAlerts,
              subtitle: l10n.riskAlertsDesc,
              value: settings.notificationPreferences['riskAlerts'] ?? true,
              activeColor: AppColors.accentGold,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                  UpdateNotificationPreference(key: 'riskAlerts', value: value),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        SettingsGlassSectionCard(
          icon: Icons.shield_rounded,
          title: l10n.privacySettings,
          isDark: isDark,
          accentColor: AppColors.accentRose,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                l10n.profileVisibility,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SettingsRadioTile<String>(
              value: 'public',
              groupValue:
                  settings.privacySettings['profileVisibility'] ?? 'public',
              title: l10n.publicProfile,
              icon: Icons.public_rounded,
              activeColor: AppColors.accentMint,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                    UpdatePrivacySetting(
                      key: 'profileVisibility',
                      value: value,
                    ),
                  );
                }
              },
            ),
            SettingsRadioTile<String>(
              value: 'private',
              groupValue:
                  settings.privacySettings['profileVisibility'] ?? 'public',
              title: l10n.privateProfile,
              icon: Icons.lock_rounded,
              activeColor: AppColors.accentRose,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                    UpdatePrivacySetting(
                      key: 'profileVisibility',
                      value: value,
                    ),
                  );
                }
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.whoCanFindYou,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SettingsRadioTile<String>(
              value: 'everyone',
              groupValue:
                  settings.privacySettings['whoCanFindYou'] ?? 'everyone',
              title: l10n.everyone,
              icon: Icons.groups_rounded,
              activeColor: AppColors.accentMint,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                    UpdatePrivacySetting(key: 'whoCanFindYou', value: value),
                  );
                }
              },
            ),
            SettingsRadioTile<String>(
              value: 'connections',
              groupValue:
                  settings.privacySettings['whoCanFindYou'] ?? 'everyone',
              title: l10n.connectionsOnly,
              icon: Icons.people_rounded,
              activeColor: AppColors.accentLavender,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                    UpdatePrivacySetting(key: 'whoCanFindYou', value: value),
                  );
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        SettingsGlassSectionCard(
          icon: Icons.palette_rounded,
          title: l10n.preferences,
          isDark: isDark,
          accentColor: AppColors.accentGold,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.theme,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsThemeSelector(
                    currentTheme: settings.themeMode ?? 'system',
                    lightLabel: l10n.lightTheme,
                    darkLabel: l10n.darkTheme,
                    systemLabel: l10n.systemTheme,
                    isDark: isDark,
                    onThemeChanged: (value) {
                      context.read<SettingsBloc>().add(
                        UpdateThemeMode(themeMode: value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SettingsGlassSectionCard(
          icon: Icons.info_rounded,
          title: l10n.about,
          isDark: isDark,
          accentColor: AppColors.accentLavender,
          children: [
            SettingsTile(
              icon: Icons.verified_rounded,
              iconColor: AppColors.accentMint,
              title: l10n.version,
              trailing: const SettingsVersionBadge(version: '1.0.0'),
            ),
            SettingsTile(
              icon: Icons.description_rounded,
              iconColor: AppColors.accentLavender,
              title: l10n.termsOfService,
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.privacy_tip_rounded,
              iconColor: AppColors.accentRose,
              title: l10n.privacyPolicy,
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.help_rounded,
              iconColor: AppColors.accentGold,
              title: l10n.helpAndSupport,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 24),

        SettingsLogoutButton(
          label: l10n.logout,
          onTap: () => _showLogoutDialog(context, l10n, isDark),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: AppColors.accentGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.changePassword),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.currentPassword,
                prefixIcon: const Icon(Icons.key_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                prefixIcon: const Icon(Icons.shield_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkPrimary, AppColors.accentRose]
                    : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (newController.text != confirmController.text) {
                    _showErrorSnackbar(dialogContext, l10n.passwordMismatch);
                    return;
                  }
                  Navigator.pop(dialogContext);
                  this.context.read<SettingsBloc>().add(
                    ChangePassword(
                      currentPassword: currentController.text,
                      newPassword: newController.text,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    l10n.save,
                    style: TextStyle(
                      color: isDark ? AppColors.darkOnPrimary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.riskHigh.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: AppColors.riskHigh,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.deleteAccount),
          ],
        ),
        content: Text(l10n.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [AppColors.riskHigh, AppColors.brandPrimary],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(dialogContext);
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    this.context.read<SettingsBloc>().add(
                      DeleteAccount(userId: userId),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    l10n.delete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentRose.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.accentRose,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.logout),
          ],
        ),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkPrimary, AppColors.accentRose]
                    : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(dialogContext);
                  this.context.read<SettingsBloc>().add(const Logout());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    l10n.logout,
                    style: TextStyle(
                      color: isDark ? AppColors.darkOnPrimary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

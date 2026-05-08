import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/connection_status.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionStatus connectionStatus;

  final bool isDark;

  final VoidCallback onConnect;

  final VoidCallback? onCancelConnection;

  final VoidCallback? onRemoveConnection;

  const ConnectionStatusWidget({
    super.key,
    required this.connectionStatus,
    required this.isDark,
    required this.onConnect,
    this.onCancelConnection,
    this.onRemoveConnection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (connectionStatus) {
      case ConnectionStatus.none:
        return _ConnectButton(isDark: isDark, onConnect: onConnect);

      case ConnectionStatus.pendingOut:
        return _PendingOutStatus(isDark: isDark, onCancel: onCancelConnection);

      case ConnectionStatus.pendingIn:
        return OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.notificationCenter),
          icon: const Icon(Icons.reply_rounded, size: 16),
          label: Text(l10n.respond),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );

      case ConnectionStatus.connected:
        return _ConnectedStatus(isDark: isDark, onRemove: onRemoveConnection);
    }
  }
}

class _ConnectButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConnect;

  const _ConnectButton({required this.isDark, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkPrimary, AppColors.accentRose]
              : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onConnect,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              l10n.connect,
              style: TextStyle(
                color: isDark ? AppColors.darkOnPrimary : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingOutStatus extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onCancel;

  const _PendingOutStatus({required this.isDark, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.accentGold.withValues(alpha: 0.15),
                  AppColors.accentGold.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.accentGold.withValues(alpha: 0.12),
                  Colors.orange.withValues(alpha: 0.08),
                ],
        ),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onCancel != null
              ? () => _showCancelConfirmation(context)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: isDark
                        ? AppColors.accentGold
                        : Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.alreadySent,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.accentGold
                        : Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _PremiumConfirmationDialog(
        icon: Icons.person_remove_rounded,
        iconColor: Colors.orange,
        title: AppLocalizations.of(context)!.cancelConnection,
        message: AppLocalizations.of(context)!.confirmCancelConnection,
        confirmLabel: AppLocalizations.of(context)!.confirm,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        isDestructive: true,
        onConfirm: () {
          Navigator.pop(dialogContext);
          onCancel?.call();
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

class _ConnectedStatus extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onRemove;

  const _ConnectedStatus({required this.isDark, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.accentMint.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.accentMint.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.08),
                ],
        ),
        border: Border.all(
          color: AppColors.accentMint.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onRemove != null
              ? () => _showRemoveConfirmation(context)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: AppColors.successDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.alreadyConnected,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppColors.accentMint.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.link_off_rounded,
                    size: 16,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _PremiumConfirmationDialog(
        icon: Icons.link_off_rounded,
        iconColor: Colors.red,
        title: AppLocalizations.of(context)!.removeConnection,
        message: AppLocalizations.of(context)!.confirmRemoveConnection,
        confirmLabel: AppLocalizations.of(context)!.confirm,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        isDestructive: true,
        onConfirm: () {
          Navigator.pop(dialogContext);
          onRemove?.call();
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }
}

class _PremiumConfirmationDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PremiumConfirmationDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_PremiumConfirmationDialog> createState() =>
      _PremiumConfirmationDialogState();
}

class _PremiumConfirmationDialogState extends State<_PremiumConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.grey.shade900.withValues(alpha: 0.95),
                            Colors.grey.shade800.withValues(alpha: 0.9),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.98),
                            Colors.grey.shade50.withValues(alpha: 0.95),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.iconColor.withValues(alpha: 0.1),
                            widget.iconColor.withValues(alpha: 0.03),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.iconColor.withValues(alpha: 0.2),
                                  widget.iconColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.iconColor.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.iconColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.iconColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          Text(
                            widget.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onCancel,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.cancelLabel,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: widget.isDestructive
                                          ? [
                                              Colors.red.shade500,
                                              Colors.red.shade700,
                                            ]
                                          : [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary
                                                  .withValues(alpha: 0.8),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (widget.isDestructive
                                                    ? Colors.red
                                                    : theme.colorScheme.primary)
                                                .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onConfirm,
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.confirmLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

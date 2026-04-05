import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/open_role.dart';

class ApplyToProjectDialog extends StatefulWidget {
  final List<OpenRole> openRoles;

  final String projectName;

  const ApplyToProjectDialog({
    super.key,
    required this.openRoles,
    required this.projectName,
  });

  static Future<Map<String, String?>?> show(
    BuildContext context, {
    required List<OpenRole> openRoles,
    required String projectName,
  }) {
    return showDialog<Map<String, String?>?>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) =>
          ApplyToProjectDialog(openRoles: openRoles, projectName: projectName),
    );
  }

  @override
  State<ApplyToProjectDialog> createState() => _ApplyToProjectDialogState();
}

class _ApplyToProjectDialogState extends State<ApplyToProjectDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  static const int _maxLength = 300;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    if (widget.openRoles.length == 1) {
      _selectedRole = widget.openRoles.first.roleName;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                constraints: const BoxConstraints(maxWidth: 420),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                            AppColors.accentMint.withValues(alpha: 0.05),
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
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.work_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.applyToProject,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.projectName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          Text(
                            l10n.selectRole,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.openRoles.map((role) {
                              final isSelected = _selectedRole == role.roleName;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedRole = role.roleName,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: isDark
                                                ? [
                                                    AppColors.darkPrimary,
                                                    AppColors.accentRose,
                                                  ]
                                                : [
                                                    theme.colorScheme.primary,
                                                    AppColors.accentMint,
                                                  ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: theme.colorScheme.outline
                                                .withValues(alpha: 0.3),
                                          ),
                                  ),
                                  child: Text(
                                    role.roleName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade100.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.15,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _controller,
                              maxLength: _maxLength,
                              maxLines: 4,
                              minLines: 3,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: l10n.joinRequestMessageHint,
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                counterStyle: theme.textTheme.labelSmall
                                    ?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                              ),
                              style: theme.textTheme.bodyMedium,
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
                                      onTap: () => Navigator.pop(context),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.cancel,
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
                                flex: 2,
                                child: AnimatedOpacity(
                                  opacity: _selectedRole != null ? 1.0 : 0.5,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                AppColors.darkPrimary,
                                                AppColors.accentRose,
                                              ]
                                            : [
                                                theme.colorScheme.primary,
                                                AppColors.accentMint,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _selectedRole != null
                                            ? () {
                                                final message = _controller.text
                                                    .trim();
                                                Navigator.pop(context, {
                                                  'roleName': _selectedRole,
                                                  'message': message.isEmpty
                                                      ? null
                                                      : message,
                                                });
                                              }
                                            : null,
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.send_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.sendApplication,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
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

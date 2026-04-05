import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/open_role.dart';

class PublishListingDialog extends StatefulWidget {
  final String projectName;
  final String projectDescription;
  final List<String> existingRoles;

  const PublishListingDialog({
    super.key,
    required this.projectName,
    required this.projectDescription,
    this.existingRoles = const [],
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String projectName,
    required String projectDescription,
    List<String> existingRoles = const [],
  }) {
    return showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublishListingDialog(
        projectName: projectName,
        projectDescription: projectDescription,
        existingRoles: existingRoles,
      ),
    );
  }

  @override
  State<PublishListingDialog> createState() => _PublishListingDialogState();
}

class _PublishListingDialogState extends State<PublishListingDialog> {
  final _messageController = TextEditingController();
  final _roleController = TextEditingController();
  final List<OpenRole> _openRoles = [];

  @override
  void initState() {
    super.initState();

    for (final role in widget.existingRoles) {
      _openRoles.add(OpenRole(roleName: role));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _addRole() {
    final roleName = _roleController.text.trim();
    if (roleName.isNotEmpty && !_openRoles.any((r) => r.roleName == roleName)) {
      setState(() {
        _openRoles.add(OpenRole(roleName: roleName));
        _roleController.clear();
      });
    }
  }

  void _removeRole(int index) {
    setState(() => _openRoles.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInsets),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          AppColors.accentGold.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shareProject,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.leaderMessageLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.leaderMessageHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.rolesNeeded,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _roleController,
                            decoration: InputDecoration(
                              hintText: l10n.addRoleHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addRole(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addRole,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_openRoles.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _openRoles.asMap().entries.map((entry) {
                          return Chip(
                            label: Text(entry.value.roleName),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeRole(entry.key),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addAtLeastOneRole,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _openRoles.isNotEmpty
                            ? () {
                                Navigator.pop(context, {
                                  'leaderMessage':
                                      _messageController.text.trim().isEmpty
                                      ? null
                                      : _messageController.text.trim(),
                                  'openRoles': _openRoles,
                                });
                              }
                            : null,
                        icon: const Icon(Icons.campaign_rounded),
                        label: Text(l10n.publishListing),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

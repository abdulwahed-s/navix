import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../project/domain/entities/project_entity.dart';
import 'project_status_badge.dart';

class HomeProjectCard extends StatelessWidget {
  final ProjectEntity project;

  final VoidCallback onTap;

  final bool isDark;

  final int colorIndex;

  const HomeProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.isDark,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d');

    final now = DateTime.now();
    final daysRemaining = project.endDate.difference(now).inDays;
    final isOverdue = daysRemaining < 0;

    final progress = project.completionPercentage / 100.0;

    final accentColors = [
      AppColors.accentLavender,
      AppColors.accentMint,
      AppColors.accentGold,
      AppColors.accentRose,
    ];
    final accent = accentColors[colorIndex % accentColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(theme, accent),
                      const SizedBox(height: 20),

                      _buildProgressSection(
                        theme: theme,
                        l10n: l10n,
                        progress: progress,
                        accent: accent,
                      ),
                      const SizedBox(height: 16),

                      _buildFooterRow(
                        theme: theme,
                        l10n: l10n,
                        dateFormat: dateFormat,
                        daysRemaining: daysRemaining,
                        isOverdue: isOverdue,
                        accent: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ProjectStatusBadge(status: project.status, isDark: isDark),
      ],
    );
  }

  Widget _buildProgressSection({
    required ThemeData theme,
    required AppLocalizations l10n,
    required double progress,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progress,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.progressPercent((progress * 100).toInt()),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? accent : AppColors.brandPrimaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, accent],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterRow({
    required ThemeData theme,
    required AppLocalizations l10n,
    required DateFormat dateFormat,
    required int daysRemaining,
    required bool isOverdue,
    required Color accent,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOverdue
                  ? [
                      AppColors.riskHigh.withValues(alpha: 0.2),
                      AppColors.riskHigh.withValues(alpha: 0.1),
                    ]
                  : [
                      accent.withValues(alpha: 0.2),
                      accent.withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOverdue)
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.riskHigh,
                ),
              if (isOverdue) const SizedBox(width: 4),
              Text(
                isOverdue ? l10n.overdue : l10n.daysRemaining(daysRemaining),
                style: TextStyle(
                  color: isOverdue
                      ? AppColors.riskHigh
                      : isDark
                      ? accent
                      : AppColors.brandPrimaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

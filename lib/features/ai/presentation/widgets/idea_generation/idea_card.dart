import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/project_idea_entity.dart';

class IdeaCard extends StatelessWidget {
  final ProjectIdeaEntity idea;
  final VoidCallback onTap;
  final bool isDark;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final complexityColor = idea.complexity == ProjectComplexity.low
        ? AppColors.success
        : idea.complexity == ProjectComplexity.medium
        ? AppColors.warning
        : AppColors.riskHigh;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: complexityColor.withValues(alpha: 0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, complexityColor),
                      const SizedBox(height: 12),
                      _buildDescription(theme),
                      const SizedBox(height: 12),
                      _buildSkillTags(theme),
                      const SizedBox(height: 12),
                      _buildFooter(theme, l10n),
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

  Widget _buildHeader(ThemeData theme, Color complexityColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: complexityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            idea.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                complexityColor.withValues(alpha: 0.2),
                complexityColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            idea.complexity.displayName.toUpperCase(),
            style: TextStyle(
              color: complexityColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      idea.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSkillTags(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: idea.skills.take(5).map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            skill,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          l10n.weeksEstimate(idea.estimatedDurationWeeks),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.2),
                AppColors.accentGold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 4),
              Text(
                '${idea.feasibilityScore}/10',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

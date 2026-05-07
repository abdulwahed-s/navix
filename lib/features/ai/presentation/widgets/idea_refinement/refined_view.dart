import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/refined_idea_entity.dart';
import 'feasibility_section.dart';
import 'features_section.dart';
import 'glass_expansion_tile.dart';
import 'gradient_button.dart';
import 'skills_section.dart';

class RefinedView extends StatelessWidget {
  final RefinedIdeaEntity refinedIdea;
  final bool isDark;
  final String refinedIdeaLabel;
  final String improvedDescriptionLabel;
  final String scopeClarificationLabel;
  final String suggestedFeaturesLabel;
  final String feasibilityAssessmentLabel;
  final String feasibilityScoreLabel;
  final String requiredSkillsLabel;
  final String yourSkillsLabel;
  final String missingSkillsLabel;
  final String refineAgainLabel;
  final String acceptRefinementLabel;
  final VoidCallback onRefineAgain;
  final VoidCallback onAcceptRefinement;

  const RefinedView({
    super.key,
    required this.refinedIdea,
    required this.isDark,
    required this.refinedIdeaLabel,
    required this.improvedDescriptionLabel,
    required this.scopeClarificationLabel,
    required this.suggestedFeaturesLabel,
    required this.feasibilityAssessmentLabel,
    required this.feasibilityScoreLabel,
    required this.requiredSkillsLabel,
    required this.yourSkillsLabel,
    required this.missingSkillsLabel,
    required this.refineAgainLabel,
    required this.acceptRefinementLabel,
    required this.onRefineAgain,
    required this.onAcceptRefinement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RefinedHeader(label: refinedIdeaLabel),
          const SizedBox(height: 24),

          GlassExpansionTile(
            title: improvedDescriptionLabel,
            content: refinedIdea.improvedDescription,
            icon: Icons.description_rounded,
            iconColor: theme.colorScheme.primary,
            isDark: isDark,
            initiallyExpanded: true,
          ),
          const SizedBox(height: 12),

          GlassExpansionTile(
            title: scopeClarificationLabel,
            content: refinedIdea.scopeClarification,
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.accentLavender,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          FeaturesSection(
            features: refinedIdea.suggestedFeatures,
            title: suggestedFeaturesLabel,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          FeasibilitySection(
            feasibilityScore: refinedIdea.feasibilityScore,
            feasibilityExplanation: refinedIdea.feasibilityExplanation,
            title: feasibilityAssessmentLabel,
            scoreLabel: feasibilityScoreLabel,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          SkillsSection(
            matchingSkills: refinedIdea.userMatchingSkills,
            missingSkills: refinedIdea.missingSkills,
            title: requiredSkillsLabel,
            yourSkillsLabel: yourSkillsLabel,
            missingSkillsLabel: missingSkillsLabel,
            isDark: isDark,
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRefineAgain,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(refineAgainLabel),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: acceptRefinementLabel,
                  icon: Icons.check_circle_rounded,
                  onPressed: onAcceptRefinement,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefinedHeader extends StatelessWidget {
  final String label;

  const _RefinedHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.2),
                AppColors.success.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

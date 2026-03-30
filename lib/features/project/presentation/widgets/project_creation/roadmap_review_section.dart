import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../bloc/project_creation_bloc.dart';
import 'gradient_button.dart';
import 'milestone_card.dart';
import 'milestones_header.dart';
import 'project_info_card.dart';

class ProjectCreationRoadmapReview extends StatelessWidget {
  final RoadmapGenerated state;
  final VoidCallback onCreateProject;
  final bool isDark;

  const ProjectCreationRoadmapReview({
    super.key,
    required this.state,
    required this.onCreateProject,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.roadmapGenerated,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reviewRoadmap,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          ProjectCreationInfoCard(
            projectName: state.projectName,
            projectDescription: state.projectDescription,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          ProjectCreationMilestonesHeader(
            title: l10n.milestones,
            milestoneCount: state.roadmap.milestones.length,
          ),
          const SizedBox(height: 16),

          ...state.roadmap.milestones.map((milestone) {
            final tasks = state.roadmap.getTasksForMilestone(milestone.id);
            return ProjectCreationMilestoneCard(
              milestone: milestone,
              tasks: tasks,
              noTasksLabel: l10n.noTasks,
              estimatedHoursLabel: l10n.estimatedHours,
              isDark: isDark,
            );
          }),
          const SizedBox(height: 24),

          ProjectCreationGradientButton(
            label: l10n.confirmAndCreate,
            icon: Icons.check_rounded,
            onPressed: onCreateProject,
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => context.read<ProjectCreationBloc>().add(
              const ResetProjectCreation(),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }
}

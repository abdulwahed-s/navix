import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProjectCreationMilestonesHeader extends StatelessWidget {
  final String title;
  final int milestoneCount;

  const ProjectCreationMilestonesHeader({
    super.key,
    required this.title,
    required this.milestoneCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.2),
                AppColors.accentGold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: AppColors.accentGold,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$milestoneCount',
            style: const TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

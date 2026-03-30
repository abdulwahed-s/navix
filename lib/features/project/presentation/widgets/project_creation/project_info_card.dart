import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProjectCreationInfoCard extends StatelessWidget {
  final String projectName;
  final String projectDescription;
  final bool isDark;

  const ProjectCreationInfoCard({
    super.key,
    required this.projectName,
    required this.projectDescription,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          AppColors.accentGold.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      projectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                projectDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

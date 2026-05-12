import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../project/domain/entities/project_entity.dart';

class ProjectStatusBadge extends StatelessWidget {
  final ProjectStatus status;

  final bool isDark;

  const ProjectStatusBadge({
    super.key,
    required this.status,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case ProjectStatus.active:
        color = AppColors.success;
        icon = Icons.play_circle_outline;
        break;
      case ProjectStatus.completed:
        color = AppColors.info;
        icon = Icons.check_circle_outline;
        break;
      case ProjectStatus.paused:
        color = AppColors.warning;
        icon = Icons.pause_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

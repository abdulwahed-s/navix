import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../project/domain/entities/project_entity.dart';
import 'home_project_card.dart';

class HomeProjectList extends StatelessWidget {
  final List<ProjectEntity> projects;

  final AnimationController listAnimationController;

  final bool isDark;

  final Future<void> Function() onRefresh;

  const HomeProjectList({
    super.key,
    required this.projects,
    required this.listAnimationController,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: listAnimationController,
            builder: (context, child) {
              final delay = index * 0.08;
              final animationValue = Curves.easeOutCubic.transform(
                (listAnimationController.value - delay).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: HomeProjectCard(
                    project: projects[index],
                    isDark: isDark,
                    colorIndex: index,
                    onTap: () => context.push('/project/${projects[index].id}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

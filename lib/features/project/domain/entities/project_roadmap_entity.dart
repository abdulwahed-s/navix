import 'package:equatable/equatable.dart';

import 'milestone_entity.dart';
import 'task_entity.dart';

class ProjectRoadmapEntity extends Equatable {
  final String projectName;

  final String projectDescription;

  final List<MilestoneEntity> milestones;

  final List<TaskEntity> tasks;

  const ProjectRoadmapEntity({
    required this.projectName,
    required this.projectDescription,
    this.milestones = const [],
    this.tasks = const [],
  });

  List<TaskEntity> getTasksForMilestone(String milestoneId) {
    return tasks.where((t) => t.milestoneId == milestoneId).toList();
  }

  @override
  List<Object?> get props => [
    projectName,
    projectDescription,
    milestones,
    tasks,
  ];
}

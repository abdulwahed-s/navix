import 'package:equatable/equatable.dart';

import '../../../ai/domain/entities/prd_entity.dart';
import '../../../project/domain/entities/milestone_entity.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/domain/entities/project_role_entity.dart';
import '../../../project/domain/entities/task_entity.dart';

class ProjectSupervisorContext extends Equatable {
  final ProjectEntity project;

  final List<MilestoneEntity> milestones;

  final List<TaskEntity> tasks;

  final List<ProjectRoleEntity> roles;

  final Map<String, String> memberNames;

  final DateTime currentDate;

  final PrdEntity? prd;

  const ProjectSupervisorContext({
    required this.project,
    required this.milestones,
    required this.tasks,
    required this.roles,
    required this.memberNames,
    required this.currentDate,
    this.prd,
  });

  int get completedTasksCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  int get totalTasksCount => tasks.length;

  int get overdueTasksCount => tasks.where((t) => t.isOverdue).length;

  int get blockedTasksCount =>
      tasks.where((t) => t.status == TaskStatus.blocked).length;

  double get completionPercentage =>
      totalTasksCount > 0 ? (completedTasksCount / totalTasksCount) * 100 : 0;

  int get daysUntilDeadline => project.endDate.difference(currentDate).inDays;

  bool get isProjectOverdue => daysUntilDeadline < 0;

  List<TaskEntity> get overdueTasks => tasks.where((t) => t.isOverdue).toList();

  List<TaskEntity> get blockedTasks =>
      tasks.where((t) => t.status == TaskStatus.blocked).toList();

  List<TaskEntity> get notStartedTasks =>
      tasks.where((t) => t.status == TaskStatus.notStarted).toList();

  List<TaskEntity> get inProgressTasks => tasks
      .where(
        (t) =>
            t.status == TaskStatus.started ||
            t.status == TaskStatus.inProgress ||
            t.status == TaskStatus.fixing ||
            t.status == TaskStatus.inReview,
      )
      .toList();

  List<MilestoneEntity> get incompleteMilestones =>
      milestones.where((m) => !m.completed).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  MilestoneEntity? get nextMilestone =>
      incompleteMilestones.isNotEmpty ? incompleteMilestones.first : null;

  Map<String?, List<TaskEntity>> get tasksByRole {
    final Map<String?, List<TaskEntity>> grouped = {};
    for (final task in tasks) {
      grouped.putIfAbsent(task.requiredRole, () => []).add(task);
    }
    return grouped;
  }

  List<TaskEntity> get unassignedTasks =>
      tasks.where((t) => t.assignedTo == null).toList();

  @override
  List<Object?> get props => [
    project,
    milestones,
    tasks,
    roles,
    memberNames,
    currentDate,
    prd,
  ];
}

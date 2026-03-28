import 'package:equatable/equatable.dart';

enum TaskPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}

enum TaskStatus {
  notStarted,
  started,
  inProgress,
  fixing,
  blocked,
  inReview,
  completed;

  String get displayName {
    switch (this) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.started:
        return 'Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.fixing:
        return 'Fixing';
      case TaskStatus.blocked:
        return 'Blocked';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

enum TaskUrgency {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case TaskUrgency.low:
        return 'Low Urgency';
      case TaskUrgency.medium:
        return 'Medium Urgency';
      case TaskUrgency.high:
        return 'High Urgency';
      case TaskUrgency.critical:
        return 'Critical Urgency';
    }
  }
}

class TaskEntity extends Equatable {
  final String id;

  final String projectId;

  final String? milestoneId;

  final String name;

  final String description;

  final String? detailedDescription;

  final String? assignedTo;

  final DateTime? deadline;

  final TaskPriority priority;

  final TaskStatus status;

  final double estimatedHours;

  final int order;

  final String? requiredRole;

  const TaskEntity({
    required this.id,
    required this.projectId,
    this.milestoneId,
    required this.name,
    this.description = '',
    this.detailedDescription,
    this.assignedTo,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.notStarted,
    this.estimatedHours = 0,
    this.order = 0,
    this.requiredRole,
  });

  TaskUrgency get urgency {
    if (status == TaskStatus.completed) {
      return TaskUrgency.low;
    }

    if (deadline == null) {
      switch (priority) {
        case TaskPriority.critical:
          return TaskUrgency.critical;
        case TaskPriority.high:
          return TaskUrgency.high;
        case TaskPriority.medium:
          return TaskUrgency.medium;
        case TaskPriority.low:
          return TaskUrgency.low;
      }
    }

    final now = DateTime.now();
    final daysUntilDeadline = deadline!.difference(now).inDays;

    if (daysUntilDeadline < 0) {
      return TaskUrgency.critical;
    }

    if (daysUntilDeadline == 0) {
      if (priority == TaskPriority.high || priority == TaskPriority.critical) {
        return TaskUrgency.critical;
      }
      return TaskUrgency.high;
    }

    if (daysUntilDeadline <= 3) {
      if (priority == TaskPriority.high || priority == TaskPriority.critical) {
        return TaskUrgency.high;
      }
      return TaskUrgency.medium;
    }

    if (daysUntilDeadline <= 7) {
      if (priority == TaskPriority.critical) {
        return TaskUrgency.high;
      }
      if (priority == TaskPriority.high) {
        return TaskUrgency.medium;
      }
      return TaskUrgency.low;
    }

    switch (priority) {
      case TaskPriority.critical:
        return TaskUrgency.medium;
      case TaskPriority.high:
        return TaskUrgency.medium;
      case TaskPriority.medium:
        return TaskUrgency.low;
      case TaskPriority.low:
        return TaskUrgency.low;
    }
  }

  bool get isOverdue {
    if (deadline == null || status == TaskStatus.completed) return false;
    return deadline!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    milestoneId,
    name,
    description,
    detailedDescription,
    assignedTo,
    deadline,
    priority,
    status,
    estimatedHours,
    order,
    requiredRole,
  ];
}

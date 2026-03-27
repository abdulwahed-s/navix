import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.projectId,
    super.milestoneId,
    required super.name,
    super.description = '',
    super.detailedDescription,
    super.assignedTo,
    super.deadline,
    super.priority = TaskPriority.medium,
    super.status = TaskStatus.notStarted,
    super.estimatedHours = 0,
    super.order = 0,
    super.requiredRole,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc, String projectId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel(
      id: doc.id,
      projectId: projectId,
      milestoneId: data['milestoneId'] as String?,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      detailedDescription: data['detailedDescription'] as String?,
      assignedTo: data['assignedTo'] as String?,
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      priority: _parsePriority(data['priority'] as String?),
      status: _parseStatus(data['status'] as String?),
      estimatedHours: (data['estimatedHours'] as num?)?.toDouble() ?? 0,
      order: data['order'] as int? ?? 0,
      requiredRole: data['requiredRole'] as String?,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, String projectId) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      projectId: projectId,
      milestoneId: json['milestoneId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      detailedDescription: json['detailedDescription'] as String?,
      assignedTo: json['assignedTo'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      priority: _parsePriority(json['priority'] as String?),
      status: _parseStatus(json['status'] as String?),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0,
      order: json['order'] as int? ?? 0,
      requiredRole: json['requiredRole'] as String?,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      milestoneId: entity.milestoneId,
      name: entity.name,
      description: entity.description,
      detailedDescription: entity.detailedDescription,
      assignedTo: entity.assignedTo,
      deadline: entity.deadline,
      priority: entity.priority,
      status: entity.status,
      estimatedHours: entity.estimatedHours,
      order: entity.order,
      requiredRole: entity.requiredRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'name': name,
      'description': description,
      'detailedDescription': detailedDescription,
      'assignedTo': assignedTo,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'priority': priority.name,
      'status': status.name,
      'estimatedHours': estimatedHours,
      'order': order,
      'requiredRole': requiredRole,
    };
  }

  static TaskPriority _parsePriority(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _parseStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'notstarted':
      case 'not_started':
        return TaskStatus.notStarted;
      case 'started':
        return TaskStatus.started;
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'fixing':
        return TaskStatus.fixing;
      case 'blocked':
        return TaskStatus.blocked;
      case 'inreview':
      case 'in_review':
        return TaskStatus.inReview;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.notStarted;
    }
  }
}

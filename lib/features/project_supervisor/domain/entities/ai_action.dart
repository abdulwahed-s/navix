import 'package:equatable/equatable.dart';

enum AIActionType {
  changeProjectDeadline,

  changeMilestoneDeadline,

  changeTaskDeadline,

  addFeature,

  addMilestone,

  addTasks,

  adjustTaskPriority,

  reassignTask,

  simplifyScope,

  markTasksBlocked,

  noAction,
}

class AIAction extends Equatable {
  final String id;

  final AIActionType type;

  final String title;

  final String description;

  final Map<String, dynamic> payload;

  final bool requiresConfirmation;

  const AIAction({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.payload,
    this.requiresConfirmation = true,
  });

  factory AIAction.fromJson(Map<String, dynamic> json) {
    return AIAction(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _parseActionType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      requiresConfirmation: json['requiresConfirmation'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'payload': payload,
      'requiresConfirmation': requiresConfirmation,
    };
  }

  static AIActionType _parseActionType(String? type) {
    switch (type) {
      case 'changeProjectDeadline':
        return AIActionType.changeProjectDeadline;
      case 'changeMilestoneDeadline':
        return AIActionType.changeMilestoneDeadline;
      case 'changeTaskDeadline':
        return AIActionType.changeTaskDeadline;
      case 'addFeature':
        return AIActionType.addFeature;
      case 'addMilestone':
        return AIActionType.addMilestone;
      case 'addTasks':
        return AIActionType.addTasks;
      case 'adjustTaskPriority':
        return AIActionType.adjustTaskPriority;
      case 'reassignTask':
        return AIActionType.reassignTask;
      case 'simplifyScope':
        return AIActionType.simplifyScope;
      case 'markTasksBlocked':
        return AIActionType.markTasksBlocked;
      default:
        return AIActionType.noAction;
    }
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    description,
    payload,
    requiresConfirmation,
  ];
}

import 'package:equatable/equatable.dart';

import 'ai_action.dart';

enum SupervisorRole {
  user,
  assistant;

  String get displayName {
    switch (this) {
      case SupervisorRole.user:
        return 'You';
      case SupervisorRole.assistant:
        return 'Navix AI';
    }
  }
}

class SupervisorMessage extends Equatable {
  final String id;

  final SupervisorRole role;

  final String content;

  final DateTime timestamp;

  final List<AIAction>? suggestedActions;

  final AIAction? executedAction;

  final bool actionsPending;

  const SupervisorMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestedActions,
    this.executedAction,
    this.actionsPending = false,
  });

  factory SupervisorMessage.user({required String content}) {
    return SupervisorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: SupervisorRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory SupervisorMessage.assistant({
    required String content,
    List<AIAction>? suggestedActions,
  }) {
    return SupervisorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: SupervisorRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      suggestedActions: suggestedActions,
      actionsPending: suggestedActions != null && suggestedActions.isNotEmpty,
    );
  }

  SupervisorMessage copyWith({AIAction? executedAction, bool? actionsPending}) {
    return SupervisorMessage(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
      suggestedActions: suggestedActions,
      executedAction: executedAction ?? this.executedAction,
      actionsPending: actionsPending ?? this.actionsPending,
    );
  }

  bool get hasActions =>
      suggestedActions != null && suggestedActions!.isNotEmpty;

  bool get hasExecutedAction => executedAction != null;

  @override
  List<Object?> get props => [
    id,
    role,
    content,
    timestamp,
    suggestedActions,
    executedAction,
    actionsPending,
  ];
}

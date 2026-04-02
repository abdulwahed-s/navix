part of 'project_supervisor_bloc.dart';

abstract class ProjectSupervisorState extends Equatable {
  const ProjectSupervisorState();

  @override
  List<Object?> get props => [];
}

class ProjectSupervisorInitial extends ProjectSupervisorState {
  const ProjectSupervisorInitial();
}

class ProjectSupervisorReady extends ProjectSupervisorState {
  final List<SupervisorMessage> messages;

  final ProjectSupervisorContext context;

  final bool isLoading;

  final String? error;

  const ProjectSupervisorReady({
    required this.messages,
    required this.context,
    this.isLoading = false,
    this.error,
  });

  ProjectSupervisorReady copyWith({
    List<SupervisorMessage>? messages,
    ProjectSupervisorContext? context,
    bool? isLoading,
    String? error,
  }) {
    return ProjectSupervisorReady(
      messages: messages ?? this.messages,
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  ProjectSupervisorReady clearError() {
    return ProjectSupervisorReady(
      messages: messages,
      context: context,
      isLoading: isLoading,
      error: null,
    );
  }

  @override
  List<Object?> get props => [messages, context, isLoading, error];
}

class ProjectSupervisorActionExecuting extends ProjectSupervisorState {
  final List<SupervisorMessage> messages;
  final ProjectSupervisorContext context;
  final AIAction action;

  const ProjectSupervisorActionExecuting({
    required this.messages,
    required this.context,
    required this.action,
  });

  @override
  List<Object?> get props => [messages, context, action];
}

class ProjectSupervisorActionSuccess extends ProjectSupervisorState {
  final List<SupervisorMessage> messages;
  final ProjectSupervisorContext context;
  final AIAction action;
  final String successMessage;

  const ProjectSupervisorActionSuccess({
    required this.messages,
    required this.context,
    required this.action,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [messages, context, action, successMessage];
}

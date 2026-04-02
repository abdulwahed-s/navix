part of 'project_supervisor_bloc.dart';

abstract class ProjectSupervisorEvent extends Equatable {
  const ProjectSupervisorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSupervisor extends ProjectSupervisorEvent {
  final ProjectSupervisorContext context;

  const InitializeSupervisor({required this.context});

  @override
  List<Object?> get props => [context];
}

class SendSupervisorMessage extends ProjectSupervisorEvent {
  final String message;

  const SendSupervisorMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConfirmAction extends ProjectSupervisorEvent {
  final AIAction action;
  final String messageId;

  const ConfirmAction({required this.action, required this.messageId});

  @override
  List<Object?> get props => [action, messageId];
}

class RejectAction extends ProjectSupervisorEvent {
  final String messageId;

  const RejectAction({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class ClearSupervisorChat extends ProjectSupervisorEvent {
  const ClearSupervisorChat();
}

class UpdateSupervisorContext extends ProjectSupervisorEvent {
  final ProjectSupervisorContext context;

  const UpdateSupervisorContext({required this.context});

  @override
  List<Object?> get props => [context];
}

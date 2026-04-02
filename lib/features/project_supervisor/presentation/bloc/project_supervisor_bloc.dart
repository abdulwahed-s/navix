import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_action.dart';
import '../../domain/entities/project_supervisor_context.dart';
import '../../domain/entities/supervisor_message.dart';
import '../../domain/usecases/chat_with_supervisor_usecase.dart';
import '../../domain/usecases/execute_ai_action_usecase.dart';

part 'project_supervisor_event.dart';
part 'project_supervisor_state.dart';

class ProjectSupervisorBloc
    extends Bloc<ProjectSupervisorEvent, ProjectSupervisorState> {
  final ChatWithSupervisorUseCase chatWithSupervisorUseCase;
  final ExecuteAIActionUseCase executeAIActionUseCase;

  ProjectSupervisorBloc({
    required this.chatWithSupervisorUseCase,
    required this.executeAIActionUseCase,
  }) : super(const ProjectSupervisorInitial()) {
    on<InitializeSupervisor>(_onInitializeSupervisor);
    on<SendSupervisorMessage>(_onSendSupervisorMessage);
    on<ConfirmAction>(_onConfirmAction);
    on<RejectAction>(_onRejectAction);
    on<ClearSupervisorChat>(_onClearChat);
    on<UpdateSupervisorContext>(_onUpdateContext);
  }

  void _onInitializeSupervisor(
    InitializeSupervisor event,
    Emitter<ProjectSupervisorState> emit,
  ) {
    emit(ProjectSupervisorReady(messages: const [], context: event.context));
  }

  Future<void> _onSendSupervisorMessage(
    SendSupervisorMessage event,
    Emitter<ProjectSupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectSupervisorReady) return;

    final userMessage = SupervisorMessage.user(content: event.message);
    final updatedMessages = [...currentState.messages, userMessage];

    emit(
      currentState.copyWith(
        messages: updatedMessages,
        isLoading: true,
        error: null,
      ),
    );

    final result = await chatWithSupervisorUseCase(
      ChatWithSupervisorParams(
        message: event.message,
        history: currentState.messages,
        context: currentState.context,
      ),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            messages: updatedMessages,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (response) {
        emit(
          ProjectSupervisorReady(
            messages: [...updatedMessages, response],
            context: currentState.context,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onConfirmAction(
    ConfirmAction event,
    Emitter<ProjectSupervisorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectSupervisorReady) return;

    emit(
      ProjectSupervisorActionExecuting(
        messages: currentState.messages,
        context: currentState.context,
        action: event.action,
      ),
    );

    final result = await executeAIActionUseCase(
      ExecuteAIActionParams(
        action: event.action,
        projectId: currentState.context.project.id,
      ),
    );

    result.fold(
      (failure) {
        emit(
          ProjectSupervisorReady(
            messages: currentState.messages,
            context: currentState.context,
            error: failure.message,
          ),
        );
      },
      (_) {
        final updatedMessages = currentState.messages.map((msg) {
          if (msg.id == event.messageId && msg.hasActions) {
            return msg.copyWith(
              executedAction: event.action,
              actionsPending: false,
            );
          }
          return msg;
        }).toList();

        emit(
          ProjectSupervisorActionSuccess(
            messages: updatedMessages,
            context: currentState.context,
            action: event.action,
            successMessage: _getSuccessMessage(event.action),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            add(UpdateSupervisorContext(context: currentState.context));
          }
        });
      },
    );
  }

  void _onRejectAction(
    RejectAction event,
    Emitter<ProjectSupervisorState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProjectSupervisorReady) return;

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.id == event.messageId && msg.hasActions) {
        return msg.copyWith(actionsPending: false);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  void _onClearChat(
    ClearSupervisorChat event,
    Emitter<ProjectSupervisorState> emit,
  ) {
    final currentState = state;
    if (currentState is ProjectSupervisorReady) {
      emit(
        ProjectSupervisorReady(
          messages: const [],
          context: currentState.context,
        ),
      );
    } else if (currentState is ProjectSupervisorActionSuccess) {
      emit(
        ProjectSupervisorReady(
          messages: const [],
          context: currentState.context,
        ),
      );
    }
  }

  void _onUpdateContext(
    UpdateSupervisorContext event,
    Emitter<ProjectSupervisorState> emit,
  ) {
    final currentState = state;
    List<SupervisorMessage> messages = const [];

    if (currentState is ProjectSupervisorReady) {
      messages = currentState.messages;
    } else if (currentState is ProjectSupervisorActionSuccess) {
      messages = currentState.messages;
    }

    emit(ProjectSupervisorReady(messages: messages, context: event.context));
  }

  String _getSuccessMessage(AIAction action) {
    switch (action.type) {
      case AIActionType.changeProjectDeadline:
        return 'Project deadline updated successfully';
      case AIActionType.changeMilestoneDeadline:
        return 'Milestone deadline updated successfully';
      case AIActionType.changeTaskDeadline:
        return 'Task deadline updated successfully';
      case AIActionType.addFeature:
        return 'Feature added with milestone and tasks';
      case AIActionType.addMilestone:
        return 'Milestone added successfully';
      case AIActionType.addTasks:
        return 'Tasks added successfully';
      case AIActionType.adjustTaskPriority:
        return 'Task priority updated';
      case AIActionType.reassignTask:
        return 'Task reassigned successfully';
      case AIActionType.simplifyScope:
        return 'Scope recommendation noted';
      case AIActionType.markTasksBlocked:
        return 'Tasks marked as blocked';
      case AIActionType.noAction:
        return 'No action needed';
    }
  }
}

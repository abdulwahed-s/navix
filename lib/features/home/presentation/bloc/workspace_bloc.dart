import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../project/domain/entities/chat_message_entity.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/domain/entities/project_member_entity.dart';
import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../../../project/domain/repositories/project_repository.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final ProjectRepository projectRepository;
  final ProfileRepository profileRepository;

  String? _currentProjectId;
  String? _currentUserId;
  String _currentUserName = 'User';

  WorkspaceBloc({
    required this.projectRepository,
    required this.profileRepository,
  }) : super(const WorkspaceInitial()) {
    on<LoadWorkspace>(_onLoadWorkspace);
    on<RefreshWorkspace>(_onRefreshWorkspace);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<SendChatMessage>(_onSendChatMessage);
    on<UpdateMessages>(_onUpdateMessages);
    on<ChangeTaskGrouping>(_onChangeTaskGrouping);
    on<FilterByRole>(_onFilterByRole);
    on<FilterByTime>(_onFilterByTime);
    on<ChangeSortOrder>(_onChangeSortOrder);
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    return super.close();
  }

  StreamSubscription<Either<Failure, List<ChatMessageEntity>>>?
  _messageSubscription;

  Future<void> _onLoadWorkspace(
    LoadWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(const WorkspaceLoading());

    _currentProjectId = event.projectId;
    _currentUserId = event.userId;

    final profileResult = await profileRepository.getProfile(event.userId);
    profileResult.fold(
      (failure) => _currentUserName = 'User',
      (profile) => _currentUserName = profile?.name ?? 'User',
    );

    final projectResult = await projectRepository.getProject(event.projectId);

    await projectResult.fold(
      (failure) async => emit(WorkspaceError(failure.message)),
      (project) async {
        final roadmapResult = await projectRepository.getProjectRoadmap(
          event.projectId,
        );

        roadmapResult.fold((failure) => emit(WorkspaceError(failure.message)), (
          roadmap,
        ) async {
          final isLeader = project.leaderId == event.userId;
          final role = isLeader
              ? ProjectMemberRole.leader
              : ProjectMemberRole.member;

          emit(
            WorkspaceLoaded(
              project: project,
              roadmap: roadmap,
              userRole: role,
              messages: const [],
              currentUserName: _currentUserName,
            ),
          );

          await _messageSubscription?.cancel();
          _messageSubscription = projectRepository
              .getProjectMessages(event.projectId)
              .listen((messagesEither) {
                messagesEither.fold((failure) {}, (messages) {
                  add(UpdateMessages(messages));
                });
              });
        });
      },
    );
  }

  Future<void> _onRefreshWorkspace(
    RefreshWorkspace event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is! WorkspaceLoaded) return;
    if (_currentProjectId == null || _currentUserId == null) return;

    final currentState = state as WorkspaceLoaded;

    final projectResult = await projectRepository.getProject(
      _currentProjectId!,
    );

    await projectResult.fold((failure) async {}, (project) async {
      final roadmapResult = await projectRepository.getProjectRoadmap(
        _currentProjectId!,
      );

      roadmapResult.fold((failure) {}, (roadmap) {
        emit(
          WorkspaceLoaded(
            project: project,
            roadmap: roadmap,
            userRole: currentState.userRole,
            messages: currentState.messages,
            currentUserName: currentState.currentUserName,
            grouping: currentState.grouping,
            selectedRoleFilter: currentState.selectedRoleFilter,
            selectedTimeFilter: currentState.selectedTimeFilter,
          ),
        );
      });
    });
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state is! WorkspaceLoaded) return;
    final currentState = state as WorkspaceLoaded;

    final updatedTasks = currentState.roadmap.tasks.map((task) {
      if (task.id == event.taskId) {
        return TaskEntity(
          id: task.id,
          projectId: task.projectId,
          milestoneId: task.milestoneId,
          name: task.name,
          description: task.description,
          detailedDescription: task.detailedDescription,
          assignedTo: task.assignedTo,
          deadline: task.deadline,
          priority: task.priority,
          status: event.newStatus,
          estimatedHours: task.estimatedHours,
          order: task.order,
          requiredRole: task.requiredRole,
        );
      }
      return task;
    }).toList();

    emit(
      currentState.copyWith(
        roadmap: ProjectRoadmapEntity(
          projectName: currentState.roadmap.projectName,
          projectDescription: currentState.roadmap.projectDescription,
          milestones: currentState.roadmap.milestones,
          tasks: updatedTasks,
        ),
      ),
    );

    await projectRepository.updateTaskStatus(
      projectId: _currentProjectId!,
      taskId: event.taskId,
      newStatus: event.newStatus,
      updatedBy: _currentUserId ?? '',
    );
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (_currentProjectId == null || _currentUserId == null) return;

    final message = ChatMessageEntity(
      id: '',
      projectId: _currentProjectId!,
      senderId: _currentUserId!,
      senderName: event.senderName,
      content: event.content,
      timestamp: DateTime.now(),
    );

    await projectRepository.sendProjectMessage(message);
  }

  void _onUpdateMessages(UpdateMessages event, Emitter<WorkspaceState> emit) {
    if (state is WorkspaceLoaded) {
      final currentState = state as WorkspaceLoaded;
      emit(currentState.copyWith(messages: event.messages));
    }
  }

  void _onChangeTaskGrouping(
    ChangeTaskGrouping event,
    Emitter<WorkspaceState> emit,
  ) {
    if (state is WorkspaceLoaded) {
      final currentState = state as WorkspaceLoaded;
      emit(
        currentState.copyWith(
          grouping: event.grouping,
          clearRoleFilter: true,
          clearTimeFilter: true,
        ),
      );
    }
  }

  void _onFilterByRole(FilterByRole event, Emitter<WorkspaceState> emit) {
    if (state is WorkspaceLoaded) {
      final currentState = state as WorkspaceLoaded;
      emit(currentState.copyWith(selectedRoleFilter: event.role));
    }
  }

  void _onFilterByTime(FilterByTime event, Emitter<WorkspaceState> emit) {
    if (state is WorkspaceLoaded) {
      final currentState = state as WorkspaceLoaded;
      emit(currentState.copyWith(selectedTimeFilter: event.timeGroup));
    }
  }

  void _onChangeSortOrder(ChangeSortOrder event, Emitter<WorkspaceState> emit) {
    if (state is WorkspaceLoaded) {
      final currentState = state as WorkspaceLoaded;
      emit(currentState.copyWith(sortOrder: event.sortOrder));
    }
  }
}

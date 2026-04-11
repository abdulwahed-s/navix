import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../project/domain/entities/task_entity.dart';
import '../../domain/entities/task_comment_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task_comment_usecase.dart';
import '../../domain/usecases/update_task_status_usecase.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;
  final AddTaskCommentUseCase addTaskCommentUseCase;

  String? _projectId;
  String? _taskId;
  StreamSubscription? _commentsSubscription;

  TaskBloc({
    required this.taskRepository,
    required this.updateTaskStatusUseCase,
    required this.addTaskCommentUseCase,
  }) : super(const TaskInitial()) {
    on<LoadTask>(_onLoadTask);
    on<UpdateStatus>(_onUpdateStatus);
    on<AddComment>(_onAddComment);
    on<ReassignTask>(_onReassignTask);
    on<DeleteTask>(_onDeleteTask);
    on<CommentsUpdated>(_onCommentsUpdated);
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTask(LoadTask event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());

    _projectId = event.projectId;
    _taskId = event.taskId;

    String? leaderId;
    List<String> memberIds = [];
    try {
      final projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(event.projectId)
          .get();
      leaderId = projectDoc.data()?['leaderId'] as String?;
      final memberIdsData = projectDoc.data()?['memberIds'] as List<dynamic>?;
      if (memberIdsData != null) {
        memberIds = memberIdsData.cast<String>();
      }
    } catch (_) {}

    final result = await taskRepository.getTask(
      projectId: event.projectId,
      taskId: event.taskId,
    );

    result.fold((failure) => emit(TaskError(failure.message)), (task) {
      emit(TaskLoaded(task: task, leaderId: leaderId, memberIds: memberIds));

      _commentsSubscription?.cancel();
      _commentsSubscription = taskRepository
          .watchComments(projectId: event.projectId, taskId: event.taskId)
          .listen((comments) => add(CommentsUpdated(comments)));
    });
  }

  void _onCommentsUpdated(CommentsUpdated event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(currentState.copyWith(comments: event.comments));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateStatus event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded || _projectId == null || _taskId == null) {
      return;
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final updatedTask = TaskEntity(
      id: currentState.task.id,
      projectId: currentState.task.projectId,
      milestoneId: currentState.task.milestoneId,
      name: currentState.task.name,
      description: currentState.task.description,
      detailedDescription: currentState.task.detailedDescription,
      assignedTo: currentState.task.assignedTo,
      deadline: currentState.task.deadline,
      priority: currentState.task.priority,
      status: event.newStatus,
      estimatedHours: currentState.task.estimatedHours,
      order: currentState.task.order,
      requiredRole: currentState.task.requiredRole,
    );

    emit(currentState.copyWith(task: updatedTask));

    final result = await updateTaskStatusUseCase(
      UpdateTaskStatusParams(
        projectId: _projectId!,
        taskId: _taskId!,
        newStatus: event.newStatus,
        updatedBy: currentUserId,
      ),
    );

    result.fold((failure) => emit(TaskError(failure.message)), (_) {});
  }

  Future<void> _onAddComment(AddComment event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded || _projectId == null || _taskId == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await addTaskCommentUseCase(
      AddCommentParams(
        projectId: _projectId!,
        taskId: _taskId!,
        userId: user.uid,
        userName: user.displayName ?? 'User',
        comment: event.comment,
      ),
    );

    result.fold((failure) => emit(TaskError(failure.message)), (_) {});
  }

  Future<void> _onReassignTask(
    ReassignTask event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded || _projectId == null || _taskId == null) {
      return;
    }

    emit(currentState.copyWith(isUpdating: true));

    final result = await taskRepository.reassignTask(
      projectId: _projectId!,
      taskId: _taskId!,
      newAssigneeId: event.newAssigneeId,
    );

    result.fold((failure) => emit(TaskError(failure.message)), (_) {
      add(LoadTask(projectId: _projectId!, taskId: _taskId!));
    });
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (_projectId == null || _taskId == null) return;

    final result = await taskRepository.deleteTask(
      projectId: _projectId!,
      taskId: _taskId!,
    );

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => emit(const TaskDeleted()),
    );
  }
}

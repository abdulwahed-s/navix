import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_comment_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskCommentUseCase
    implements UseCase<TaskCommentEntity, AddCommentParams> {
  final TaskRepository repository;

  AddTaskCommentUseCase(this.repository);

  @override
  Future<Either<Failure, TaskCommentEntity>> call(AddCommentParams params) {
    return repository.addComment(
      projectId: params.projectId,
      taskId: params.taskId,
      userId: params.userId,
      userName: params.userName,
      comment: params.comment,
    );
  }
}

class AddCommentParams extends Equatable {
  final String projectId;
  final String taskId;
  final String userId;
  final String userName;
  final String comment;

  const AddCommentParams({
    required this.projectId,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.comment,
  });

  @override
  List<Object?> get props => [projectId, taskId, userId, userName, comment];
}

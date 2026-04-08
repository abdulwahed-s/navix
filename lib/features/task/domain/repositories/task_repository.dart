import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../entities/task_comment_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskEntity>> getTask({
    required String projectId,
    required String taskId,
  });

  Future<Either<Failure, void>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus newStatus,
    required String updatedBy,
  });

  Future<Either<Failure, void>> reassignTask({
    required String projectId,
    required String taskId,
    required String newAssigneeId,
  });

  Future<Either<Failure, TaskCommentEntity>> addComment({
    required String projectId,
    required String taskId,
    required String userId,
    required String userName,
    required String comment,
  });

  Future<Either<Failure, List<TaskCommentEntity>>> getComments({
    required String projectId,
    required String taskId,
  });

  Stream<List<TaskCommentEntity>> watchComments({
    required String projectId,
    required String taskId,
  });

  Future<Either<Failure, void>> deleteTask({
    required String projectId,
    required String taskId,
  });
}

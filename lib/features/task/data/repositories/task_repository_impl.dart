import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../project/data/models/task_model.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../../domain/entities/task_comment_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_comment_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<Either<Failure, TaskEntity>> getTask({
    required String projectId,
    required String taskId,
  }) async {
    try {
      final doc = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (!doc.exists) {
        return const Left(
          ServerFailure(message: 'Task not found', code: 'task-not-found'),
        );
      }

      final task = TaskModel.fromFirestore(doc, projectId);
      return Right(task);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get task: $e',
          code: 'task-fetch-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus newStatus,
    required String updatedBy,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({
            'status': newStatus.name,
            'updatedAt': FieldValue.serverTimestamp(),
            'lastUpdatedBy': updatedBy,
          });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to update task: $e',
          code: 'task-update-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reassignTask({
    required String projectId,
    required String taskId,
    required String newAssigneeId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({
            'assignedTo': newAssigneeId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to reassign task: $e',
          code: 'task-reassign-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TaskCommentEntity>> addComment({
    required String projectId,
    required String taskId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final commentModel = TaskCommentModel(
        id: '',
        taskId: taskId,
        userId: userId,
        userName: userName,
        comment: comment,
        createdAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(commentModel.toJson());

      return Right(
        TaskCommentEntity(
          id: docRef.id,
          taskId: taskId,
          userId: userId,
          userName: userName,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to add comment: $e',
          code: 'comment-add-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<TaskCommentEntity>>> getComments({
    required String projectId,
    required String taskId,
  }) async {
    try {
      final query = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      final comments = query.docs
          .map((doc) => TaskCommentModel.fromFirestore(doc))
          .toList();

      return Right(comments);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get comments: $e',
          code: 'comments-fetch-error',
        ),
      );
    }
  }

  @override
  Stream<List<TaskCommentEntity>> watchComments({
    required String projectId,
    required String taskId,
  }) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final comments = <TaskCommentEntity>[];

          for (final doc in snapshot.docs) {
            final comment = TaskCommentModel.fromFirestore(doc);

            try {
              final profileDoc = await firestore
                  .collection('users')
                  .doc(comment.userId)
                  .collection('profile')
                  .doc('main')
                  .get();

              if (profileDoc.exists) {
                final profileData = profileDoc.data();
                final userName = profileData?['name'] as String? ?? 'Unknown';
                final profilePicUrl = profileData?['profilePicUrl'] as String?;

                comments.add(
                  comment.copyWith(
                    userName: userName,
                    userProfilePicUrl: profilePicUrl,
                  ),
                );
              } else {
                comments.add(comment);
              }
            } catch (_) {
              comments.add(comment);
            }
          }

          return comments;
        });
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to delete task: $e',
          code: 'task-delete-error',
        ),
      );
    }
  }
}

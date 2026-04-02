import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ai_action.dart';
import '../../domain/entities/project_supervisor_context.dart';
import '../../domain/entities/supervisor_message.dart';
import '../../domain/repositories/project_supervisor_repository.dart';
import '../datasources/project_supervisor_remote_datasource.dart';

/// Implementation of ProjectSupervisorRepository.
///
/// Handles AI communication via datasource and executes actions
/// directly against Firestore.
class ProjectSupervisorRepositoryImpl implements ProjectSupervisorRepository {
  final ProjectSupervisorRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  ProjectSupervisorRepositoryImpl({
    required this.remoteDataSource,
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SupervisorMessage>> sendMessage({
    required String message,
    required List<SupervisorMessage> history,
    required ProjectSupervisorContext context,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final response = await remoteDataSource.sendMessage(
        message: message,
        history: history,
        context: context,
      );
      return Right(response);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to communicate with AI: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> executeAction({
    required AIAction action,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      switch (action.type) {
        case AIActionType.changeProjectDeadline:
          await _executeChangeProjectDeadline(action, projectId);
          break;
        case AIActionType.changeMilestoneDeadline:
          await _executeChangeMilestoneDeadline(action, projectId);
          break;
        case AIActionType.changeTaskDeadline:
          await _executeChangeTaskDeadline(action, projectId);
          break;
        case AIActionType.addFeature:
          await _executeAddFeature(action, projectId);
          break;
        case AIActionType.addMilestone:
          await _executeAddMilestone(action, projectId);
          break;
        case AIActionType.addTasks:
          await _executeAddTasks(action, projectId);
          break;
        case AIActionType.adjustTaskPriority:
          await _executeAdjustTaskPriority(action, projectId);
          break;
        case AIActionType.reassignTask:
          await _executeReassignTask(action, projectId);
          break;
        case AIActionType.simplifyScope:
          // For simplifyScope, we just acknowledge - actual changes need manual review
          break;
        case AIActionType.markTasksBlocked:
          await _executeMarkTasksBlocked(action, projectId);
          break;
        case AIActionType.noAction:
          // Nothing to do
          break;
      }
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: 'Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to execute action: $e'));
    }
  }

  Future<void> _executeChangeProjectDeadline(
    AIAction action,
    String projectId,
  ) async {
    final newDeadline = _parseDate(action.payload['newDeadline'] as String?);
    if (newDeadline == null) {
      throw const AIException(
        message: 'Invalid deadline format',
        code: 'invalid-date',
      );
    }

    await firestore.collection('projects').doc(projectId).update({
      'endDate': Timestamp.fromDate(newDeadline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _executeChangeMilestoneDeadline(
    AIAction action,
    String projectId,
  ) async {
    final milestoneId = action.payload['milestoneId'] as String?;
    final newDeadline = _parseDate(action.payload['newDeadline'] as String?);

    if (milestoneId == null || newDeadline == null) {
      throw const AIException(
        message: 'Invalid milestone or deadline',
        code: 'invalid-params',
      );
    }

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('milestones')
        .doc(milestoneId)
        .update({'deadline': Timestamp.fromDate(newDeadline)});
  }

  Future<void> _executeChangeTaskDeadline(
    AIAction action,
    String projectId,
  ) async {
    final taskId = action.payload['taskId'] as String?;
    final newDeadline = _parseDate(action.payload['newDeadline'] as String?);

    if (taskId == null || newDeadline == null) {
      throw const AIException(
        message: 'Invalid task or deadline',
        code: 'invalid-params',
      );
    }

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'deadline': Timestamp.fromDate(newDeadline)});
  }

  Future<void> _executeAddFeature(AIAction action, String projectId) async {
    final featureName = action.payload['featureName'] as String?;
    final description = action.payload['description'] as String? ?? '';
    final milestoneData = action.payload['milestone'] as Map<String, dynamic>?;
    final tasksData = action.payload['tasks'] as List?;

    if (featureName == null || milestoneData == null) {
      throw const AIException(
        message: 'Invalid feature data',
        code: 'invalid-params',
      );
    }

    // Create milestone for the feature
    final milestoneDeadline = _parseDate(milestoneData['deadline'] as String?);
    final milestoneRef = firestore
        .collection('projects')
        .doc(projectId)
        .collection('milestones')
        .doc();

    // Get current milestone count for ordering
    final milestonesSnapshot = await firestore
        .collection('projects')
        .doc(projectId)
        .collection('milestones')
        .get();
    final nextOrder = milestonesSnapshot.docs.length + 1;

    await milestoneRef.set({
      'name': milestoneData['name'] ?? featureName,
      'description': milestoneData['description'] ?? description,
      'deadline': milestoneDeadline != null
          ? Timestamp.fromDate(milestoneDeadline)
          : null,
      'completed': false,
      'order': nextOrder,
    });

    // Create tasks for the feature
    if (tasksData != null && tasksData.isNotEmpty) {
      final batch = firestore.batch();
      int taskOrder = 0;

      for (final taskData in tasksData) {
        if (taskData is Map<String, dynamic>) {
          final taskRef = firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .doc();

          final taskDeadline =
              _parseDate(taskData['deadline'] as String?) ?? milestoneDeadline;

          batch.set(taskRef, {
            'name': taskData['name'] ?? 'New Task',
            'description': taskData['description'] ?? '',
            'detailedDescription': taskData['detailedDescription'],
            'milestoneId': milestoneRef.id,
            'assignedTo': null,
            'deadline': taskDeadline != null
                ? Timestamp.fromDate(taskDeadline)
                : null,
            'priority': taskData['priority'] ?? 'medium',
            'status': 'notStarted',
            'estimatedHours':
                (taskData['estimatedHours'] as num?)?.toDouble() ?? 4.0,
            'order': taskOrder++,
            'requiredRole': taskData['requiredRole'],
          });
        }
      }

      await batch.commit();
    }

    // Update project timestamp
    await firestore.collection('projects').doc(projectId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _executeAddMilestone(AIAction action, String projectId) async {
    final name = action.payload['name'] as String?;
    final description = action.payload['description'] as String? ?? '';
    final deadline = _parseDate(action.payload['deadline'] as String?);

    if (name == null) {
      throw const AIException(
        message: 'Invalid milestone name',
        code: 'invalid-params',
      );
    }

    // Get current milestone count for ordering
    final milestonesSnapshot = await firestore
        .collection('projects')
        .doc(projectId)
        .collection('milestones')
        .get();
    final nextOrder = milestonesSnapshot.docs.length + 1;

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('milestones')
        .add({
          'name': name,
          'description': description,
          'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
          'completed': false,
          'order': nextOrder,
        });
  }

  Future<void> _executeAddTasks(AIAction action, String projectId) async {
    final milestoneId = action.payload['milestoneId'] as String?;
    final tasksData = action.payload['tasks'] as List?;

    if (milestoneId == null || tasksData == null || tasksData.isEmpty) {
      throw const AIException(
        message: 'Invalid tasks data',
        code: 'invalid-params',
      );
    }

    // Get current task count in milestone for ordering
    final tasksSnapshot = await firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .where('milestoneId', isEqualTo: milestoneId)
        .get();
    int nextOrder = tasksSnapshot.docs.length;

    final batch = firestore.batch();

    for (final taskData in tasksData) {
      if (taskData is Map<String, dynamic>) {
        final taskRef = firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .doc();

        final taskDeadline = _parseDate(taskData['deadline'] as String?);

        batch.set(taskRef, {
          'name': taskData['name'] ?? 'New Task',
          'description': taskData['description'] ?? '',
          'detailedDescription': taskData['detailedDescription'],
          'milestoneId': milestoneId,
          'assignedTo': null,
          'deadline': taskDeadline != null
              ? Timestamp.fromDate(taskDeadline)
              : null,
          'priority': taskData['priority'] ?? 'medium',
          'status': 'notStarted',
          'estimatedHours':
              (taskData['estimatedHours'] as num?)?.toDouble() ?? 4.0,
          'order': nextOrder++,
          'requiredRole': taskData['requiredRole'],
        });
      }
    }

    await batch.commit();
  }

  Future<void> _executeAdjustTaskPriority(
    AIAction action,
    String projectId,
  ) async {
    final taskId = action.payload['taskId'] as String?;
    final newPriority = action.payload['newPriority'] as String?;

    if (taskId == null || newPriority == null) {
      throw const AIException(
        message: 'Invalid task or priority',
        code: 'invalid-params',
      );
    }

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'priority': newPriority});
  }

  Future<void> _executeReassignTask(AIAction action, String projectId) async {
    final taskId = action.payload['taskId'] as String?;
    final newAssigneeId = action.payload['newAssigneeId'] as String?;

    if (taskId == null) {
      throw const AIException(message: 'Invalid task', code: 'invalid-params');
    }

    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({'assignedTo': newAssigneeId});
  }

  Future<void> _executeMarkTasksBlocked(
    AIAction action,
    String projectId,
  ) async {
    final taskIds = action.payload['taskIds'] as List?;

    if (taskIds == null || taskIds.isEmpty) {
      throw const AIException(
        message: 'Invalid task IDs',
        code: 'invalid-params',
      );
    }

    final batch = firestore.batch();

    for (final taskId in taskIds) {
      if (taskId is String) {
        final taskRef = firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .doc(taskId);
        batch.update(taskRef, {'status': 'blocked'});
      }
    }

    await batch.commit();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

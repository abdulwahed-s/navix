import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navix/features/project/domain/entities/task_entity.dart';

import '../../../../core/error/exceptions.dart';
import '../../../ai/data/models/prd_model.dart';
import '../models/chat_message_model.dart';
import '../models/milestone_model.dart';
import '../models/project_model.dart';
import '../models/project_role_model.dart';
import '../models/task_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject({
    required ProjectModel project,
    required List<MilestoneModel> milestones,
    required List<TaskModel> tasks,
    PrdModel? prd,
  });

  Future<List<ProjectModel>> getUserProjects(String userId);

  Future<ProjectModel?> getProject(String projectId);

  Future<ProjectModel> updateProject(ProjectModel project);

  Future<List<MilestoneModel>> getProjectMilestones(String projectId);

  Future<List<TaskModel>> getProjectTasks(String projectId);

  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus newStatus,
    required String updatedBy,
  });

  Future<void> sendProjectMessage(ChatMessageModel message);

  Stream<List<ChatMessageModel>> getProjectMessages(String projectId);

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> updates,
  });

  Future<void> saveRoleAssignment({
    required String projectId,
    required ProjectRoleModel roleModel,
  });

  Future<List<ProjectRoleModel>> getRoleAssignments(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _projectsCollection =>
      firestore.collection('projects');

  @override
  Future<ProjectModel> createProject({
    required ProjectModel project,
    required List<MilestoneModel> milestones,
    required List<TaskModel> tasks,
    PrdModel? prd,
  }) async {
    try {
      final projectRef = _projectsCollection.doc();
      final projectWithId = ProjectModel(
        id: projectRef.id,
        name: project.name,
        description: project.description,
        leaderId: project.leaderId,
        memberIds: project.memberIds,
        status: project.status,
        startDate: project.startDate,
        endDate: project.endDate,
        createdAt: DateTime.now(),
      );

      final projectData = projectWithId.toJson();
      if (prd != null) {
        projectData['prd'] = prd.toJson();
      }

      await projectRef.set(projectData);

      final milestonesCollection = projectRef.collection('milestones');
      final milestoneIdMap = <String, String>{};

      for (final milestone in milestones) {
        final milestoneRef = milestonesCollection.doc();

        milestoneIdMap[milestone.id] = milestoneRef.id;

        final milestoneWithId = MilestoneModel(
          id: milestoneRef.id,
          projectId: projectRef.id,
          name: milestone.name,
          description: milestone.description,
          deadline: milestone.deadline,
          completed: milestone.completed,
          order: milestone.order,
        );

        final milestoneData = milestoneWithId.toJson();
        milestoneData['id'] = milestoneRef.id;
        await milestoneRef.set(milestoneData);
      }

      final tasksCollection = projectRef.collection('tasks');
      for (final task in tasks) {
        final taskRef = tasksCollection.doc();

        final mappedMilestoneId = task.milestoneId != null
            ? (milestoneIdMap[task.milestoneId] ?? task.milestoneId)
            : null;

        final taskWithId = TaskModel(
          id: taskRef.id,
          projectId: projectRef.id,
          milestoneId: mappedMilestoneId,
          name: task.name,
          description: task.description,
          detailedDescription: task.detailedDescription,
          assignedTo: task.assignedTo,
          deadline: task.deadline,
          priority: task.priority,
          status: task.status,
          estimatedHours: task.estimatedHours,
          order: task.order,
          requiredRole: task.requiredRole,
        );
        await taskRef.set(taskWithId.toJson());
      }

      return projectWithId;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to create project: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred',
        code: e.toString(),
      );
    }
  }

  @override
  Future<List<ProjectModel>> getUserProjects(String userId) async {
    try {
      final leaderQuery = await _projectsCollection
          .where('leaderId', isEqualTo: userId)
          .get();

      final memberQuery = await _projectsCollection
          .where('memberIds', arrayContains: userId)
          .get();

      final projectDocs = <DocumentSnapshot>{};
      projectDocs.addAll(leaderQuery.docs);
      projectDocs.addAll(memberQuery.docs);

      return projectDocs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get projects: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      if (!doc.exists) return null;
      return ProjectModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get project: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final updatedProject = ProjectModel(
        id: project.id,
        name: project.name,
        description: project.description,
        leaderId: project.leaderId,
        memberIds: project.memberIds,
        status: project.status,
        startDate: project.startDate,
        endDate: project.endDate,
        createdAt: project.createdAt,
        updatedAt: DateTime.now(),
      );

      await _projectsCollection.doc(project.id).update(updatedProject.toJson());
      return updatedProject;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update project: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<MilestoneModel>> getProjectMilestones(String projectId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection('milestones')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => MilestoneModel.fromFirestore(doc, projectId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get milestones: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<TaskModel>> getProjectTasks(String projectId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection('tasks')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc, projectId))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get tasks: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus newStatus,
    required String updatedBy,
  }) async {
    try {
      await _projectsCollection
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({
            'status': newStatus.name,
            'updatedAt': FieldValue.serverTimestamp(),
            'lastUpdatedBy': updatedBy,
          });

      final tasks = await getProjectTasks(projectId);

      final updatedTask = tasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => tasks.first,
      );

      final completedTasks = tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
      final completionPercentage = tasks.isEmpty
          ? 0.0
          : (completedTasks / tasks.length) * 100;

      await _projectsCollection.doc(projectId).update({
        'completionPercentage': completionPercentage,
        'updatedAt': Timestamp.now(),
      });

      final taskMilestoneId = updatedTask.milestoneId;
      if (taskMilestoneId != null && taskMilestoneId.isNotEmpty) {
        final milestoneTasks = tasks
            .where((t) => t.milestoneId == taskMilestoneId)
            .toList();

        final allMilestoneTasksCompleted =
            milestoneTasks.isNotEmpty &&
            milestoneTasks.every((t) => t.status == TaskStatus.completed);

        await _projectsCollection
            .doc(projectId)
            .collection('milestones')
            .doc(taskMilestoneId)
            .update({'completed': allMilestoneTasksCompleted});
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update task status: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> sendProjectMessage(ChatMessageModel message) async {
    try {
      final chatRef = _projectsCollection
          .doc(message.projectId)
          .collection('chat')
          .doc();

      final messageWithId = ChatMessageModel(
        id: chatRef.id,
        projectId: message.projectId,
        senderId: message.senderId,
        senderName: message.senderName,
        content: message.content,
        timestamp: message.timestamp,
      );

      await chatRef.set(messageWithId.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to send message: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<ChatMessageModel>> getProjectMessages(String projectId) {
    try {
      return _projectsCollection
          .doc(projectId)
          .collection('chat')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ChatMessageModel.fromFirestore(doc, projectId))
                .toList(),
          );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get messages: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _projectsCollection
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update(updates);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update task: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> saveRoleAssignment({
    required String projectId,
    required ProjectRoleModel roleModel,
  }) async {
    try {
      await _projectsCollection
          .doc(projectId)
          .collection('roleAssignments')
          .doc(roleModel.roleName)
          .set(roleModel.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to save role assignment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<ProjectRoleModel>> getRoleAssignments(String projectId) async {
    try {
      final snapshot = await _projectsCollection
          .doc(projectId)
          .collection('roleAssignments')
          .get();

      return snapshot.docs
          .map((doc) => ProjectRoleModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get role assignments: ${e.message}',
        code: e.code,
      );
    }
  }
}

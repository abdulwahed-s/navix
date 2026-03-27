import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../ai/data/models/prd_model.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/project_roadmap_entity.dart';
import '../../domain/entities/project_role_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/milestone_model.dart';
import '../models/project_model.dart';
import '../models/project_role_model.dart';
import '../models/task_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProjectEntity>> createProject({
    required ProjectEntity project,
    required ProjectRoadmapEntity roadmap,
    PrdEntity? prd,
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
      final projectModel = ProjectModel.fromEntity(project);
      final milestoneModels = roadmap.milestones
          .map((m) => MilestoneModel.fromEntity(m))
          .toList();
      final taskModels = roadmap.tasks
          .map((t) => TaskModel.fromEntity(t))
          .toList();

      PrdModel? prdModel;
      if (prd != null) {
        prdModel = PrdModel.fromEntity(prd);
      }

      final result = await remoteDataSource.createProject(
        project: projectModel,
        milestones: milestoneModels,
        tasks: taskModels,
        prd: prdModel,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getUserProjects(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final projects = await remoteDataSource.getUserProjects(userId);
      return Right(projects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProject(String projectId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final project = await remoteDataSource.getProject(projectId);
      if (project == null) {
        return const Left(
          ServerFailure(message: 'Project not found', code: 'not-found'),
        );
      }
      return Right(project);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject(
    ProjectEntity project,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final projectModel = ProjectModel.fromEntity(project);
      final result = await remoteDataSource.updateProject(projectModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProjectRoadmapEntity>> getProjectRoadmap(
    String projectId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final project = await remoteDataSource.getProject(projectId);
      final milestones = await remoteDataSource.getProjectMilestones(projectId);
      final tasks = await remoteDataSource.getProjectTasks(projectId);

      return Right(
        ProjectRoadmapEntity(
          projectName: project?.name ?? '',
          projectDescription: project?.description ?? '',
          milestones: milestones,
          tasks: tasks,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
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
      await remoteDataSource.updateTaskStatus(
        projectId: projectId,
        taskId: taskId,
        newStatus: newStatus,
        updatedBy: updatedBy,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendProjectMessage(
    ChatMessageEntity message,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      await remoteDataSource.sendProjectMessage(messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessageEntity>>> getProjectMessages(
    String projectId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
      return;
    }

    try {
      await for (final messages in remoteDataSource.getProjectMessages(
        projectId,
      )) {
        yield Right(messages.map((m) => m.toEntity()).toList());
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      yield Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProjectRoleEntity>>> getProjectRoles(
    String projectId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final tasks = await remoteDataSource.getProjectTasks(projectId);

      final roleTaskCounts = <String, int>{};
      for (final task in tasks) {
        if (task.requiredRole != null && task.requiredRole!.isNotEmpty) {
          roleTaskCounts[task.requiredRole!] =
              (roleTaskCounts[task.requiredRole!] ?? 0) + 1;
        }
      }

      if (roleTaskCounts.isEmpty) {
        return const Right([]);
      }

      final roleAssignments = await remoteDataSource.getRoleAssignments(
        projectId,
      );

      final assignmentMap = <String, ProjectRoleEntity>{};
      for (final assignment in roleAssignments) {
        assignmentMap[assignment.roleName] = assignment;
      }

      final rolesWithNames = <ProjectRoleEntity>[];
      for (final roleName in roleTaskCounts.keys) {
        final taskCount = roleTaskCounts[roleName]!;

        final existingAssignment = assignmentMap[roleName];

        if (existingAssignment != null) {
          rolesWithNames.add(
            ProjectRoleEntity(
              roleName: roleName,
              assignedUserId: existingAssignment.assignedUserId,
              assignedUserName: existingAssignment.assignedUserName,
              taskCount: taskCount,
            ),
          );
        } else {
          rolesWithNames.add(
            ProjectRoleEntity(
              roleName: roleName,
              assignedUserId: null,
              assignedUserName: null,
              taskCount: taskCount,
            ),
          );
        }
      }

      return Right(rolesWithNames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> assignRoleToMember({
    required String projectId,
    required String roleName,
    required String userId,
    required String userName,
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
      final tasks = await remoteDataSource.getProjectTasks(projectId);

      final tasksToUpdate = tasks.where(
        (task) => task.requiredRole == roleName,
      );

      for (final task in tasksToUpdate) {
        await remoteDataSource.updateTask(
          projectId: projectId,
          taskId: task.id,
          updates: {'assignedTo': userId},
        );
      }

      final roleModel = ProjectRoleModel(
        roleName: roleName,
        assignedUserId: userId,
        assignedUserName: userName,
        taskCount: tasksToUpdate.length,
      );

      await remoteDataSource.saveRoleAssignment(
        projectId: projectId,
        roleModel: roleModel,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../entities/chat_message_entity.dart';
import '../entities/project_entity.dart';
import '../entities/project_roadmap_entity.dart';
import '../entities/project_role_entity.dart';
import '../entities/task_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject({
    required ProjectEntity project,
    required ProjectRoadmapEntity roadmap,
    PrdEntity? prd,
  });

  Future<Either<Failure, List<ProjectEntity>>> getUserProjects(String userId);

  Future<Either<Failure, ProjectEntity>> getProject(String projectId);

  Future<Either<Failure, ProjectEntity>> updateProject(ProjectEntity project);

  Future<Either<Failure, ProjectRoadmapEntity>> getProjectRoadmap(
    String projectId,
  );

  Future<Either<Failure, void>> updateTaskStatus({
    required String projectId,
    required String taskId,
    required TaskStatus newStatus,
    required String updatedBy,
  });

  Future<Either<Failure, void>> sendProjectMessage(ChatMessageEntity message);

  Stream<Either<Failure, List<ChatMessageEntity>>> getProjectMessages(
    String projectId,
  );

  Future<Either<Failure, List<ProjectRoleEntity>>> getProjectRoles(
    String projectId,
  );

  Future<Either<Failure, void>> assignRoleToMember({
    required String projectId,
    required String roleName,
    required String userId,
    required String userName,
  });
}

class GenerateRoadmapParams extends Equatable {
  final String projectName;
  final String projectDescription;
  final List<String> skills;
  final int teamSize;
  final DateTime startDate;
  final DateTime endDate;
  final bool isTeamProject;

  const GenerateRoadmapParams({
    required this.projectName,
    required this.projectDescription,
    required this.skills,
    required this.teamSize,
    required this.startDate,
    required this.endDate,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [
    projectName,
    projectDescription,
    skills,
    teamSize,
    startDate,
    endDate,
    isTeamProject,
  ];
}

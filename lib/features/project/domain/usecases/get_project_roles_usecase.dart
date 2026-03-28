import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_role_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectRolesUseCase
    implements UseCase<List<ProjectRoleEntity>, GetProjectRolesParams> {
  final ProjectRepository repository;

  GetProjectRolesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectRoleEntity>>> call(
    GetProjectRolesParams params,
  ) {
    return repository.getProjectRoles(params.projectId);
  }
}

class GetProjectRolesParams extends Equatable {
  final String projectId;

  const GetProjectRolesParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

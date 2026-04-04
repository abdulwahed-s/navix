import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_join_request_entity.dart';
import '../repositories/find_projects_repository.dart';

class GetJoinRequestsUseCase
    implements UseCase<List<ProjectJoinRequestEntity>, GetJoinRequestsParams> {
  final FindProjectsRepository repository;

  GetJoinRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectJoinRequestEntity>>> call(
    GetJoinRequestsParams params,
  ) {
    return repository.getJoinRequestsForProject(projectId: params.projectId);
  }
}

class GetJoinRequestsParams extends Equatable {
  final String projectId;

  const GetJoinRequestsParams({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class GetUserProjectsUseCase
    implements UseCase<List<ProjectEntity>, GetUserProjectsParams> {
  final ProjectRepository repository;

  GetUserProjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectEntity>>> call(
    GetUserProjectsParams params,
  ) {
    return repository.getUserProjects(params.userId);
  }
}

class GetUserProjectsParams extends Equatable {
  final String userId;

  const GetUserProjectsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

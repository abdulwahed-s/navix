import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/find_projects_repository.dart';

class ApplyToProjectUseCase implements UseCase<void, ApplyToProjectParams> {
  final FindProjectsRepository repository;

  ApplyToProjectUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ApplyToProjectParams params) {
    return repository.applyToProject(
      listingId: params.listingId,
      projectId: params.projectId,
      leaderId: params.leaderId,
      roleName: params.roleName,
      message: params.message,
    );
  }
}

class ApplyToProjectParams extends Equatable {
  final String listingId;
  final String projectId;
  final String leaderId;
  final String roleName;
  final String? message;

  const ApplyToProjectParams({
    required this.listingId,
    required this.projectId,
    required this.leaderId,
    required this.roleName,
    this.message,
  });

  @override
  List<Object?> get props => [
    listingId,
    projectId,
    leaderId,
    roleName,
    message,
  ];
}

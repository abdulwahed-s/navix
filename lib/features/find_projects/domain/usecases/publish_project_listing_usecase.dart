import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/open_role.dart';
import '../repositories/find_projects_repository.dart';

class PublishProjectListingUseCase
    implements UseCase<void, PublishProjectListingParams> {
  final FindProjectsRepository repository;

  PublishProjectListingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PublishProjectListingParams params) {
    return repository.publishProjectListing(
      projectId: params.projectId,
      projectName: params.projectName,
      projectDescription: params.projectDescription,
      leaderId: params.leaderId,
      leaderMessage: params.leaderMessage,
      openRoles: params.openRoles,
    );
  }
}

class PublishProjectListingParams extends Equatable {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final String leaderId;
  final String? leaderMessage;
  final List<OpenRole> openRoles;

  const PublishProjectListingParams({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.leaderId,
    this.leaderMessage,
    required this.openRoles,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    projectDescription,
    leaderId,
    leaderMessage,
    openRoles,
  ];
}

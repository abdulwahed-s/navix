import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/find_projects_repository.dart';

class RespondToJoinRequestUseCase
    implements UseCase<void, RespondToJoinRequestParams> {
  final FindProjectsRepository repository;

  RespondToJoinRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RespondToJoinRequestParams params) {
    return repository.respondToJoinRequest(
      requestId: params.requestId,
      accepted: params.accepted,
      projectId: params.projectId,
      applicantId: params.applicantId,
      projectName: params.projectName,
    );
  }
}

class RespondToJoinRequestParams extends Equatable {
  final String requestId;
  final bool accepted;
  final String projectId;
  final String applicantId;
  final String projectName;

  const RespondToJoinRequestParams({
    required this.requestId,
    required this.accepted,
    required this.projectId,
    required this.applicantId,
    required this.projectName,
  });

  @override
  List<Object?> get props => [
    requestId,
    accepted,
    projectId,
    applicantId,
    projectName,
  ];
}

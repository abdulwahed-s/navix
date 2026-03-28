import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

class AssignRoleToMemberUseCase
    implements UseCase<void, AssignRoleToMemberParams> {
  final ProjectRepository repository;

  AssignRoleToMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AssignRoleToMemberParams params) {
    return repository.assignRoleToMember(
      projectId: params.projectId,
      roleName: params.roleName,
      userId: params.userId,
      userName: params.userName,
    );
  }
}

class AssignRoleToMemberParams extends Equatable {
  final String projectId;
  final String roleName;
  final String userId;
  final String userName;

  const AssignRoleToMemberParams({
    required this.projectId,
    required this.roleName,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [projectId, roleName, userId, userName];
}

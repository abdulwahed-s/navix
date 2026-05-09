import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class ChangeMemberRoleUseCase implements UseCase<void, ChangeMemberRoleParams> {
  final TeamRepository repository;

  ChangeMemberRoleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangeMemberRoleParams params) {
    return repository.changeMemberRole(
      projectId: params.projectId,
      memberId: params.memberId,
      newRole: params.newRole,
    );
  }
}

class ChangeMemberRoleParams extends Equatable {
  final String projectId;
  final String memberId;
  final MemberRole newRole;

  const ChangeMemberRoleParams({
    required this.projectId,
    required this.memberId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [projectId, memberId, newRole];
}

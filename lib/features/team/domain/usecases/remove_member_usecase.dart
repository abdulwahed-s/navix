import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class RemoveMemberUseCase implements UseCase<void, RemoveMemberParams> {
  final TeamRepository repository;

  RemoveMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) {
    return repository.removeMember(
      projectId: params.projectId,
      memberId: params.memberId,
    );
  }
}

class RemoveMemberParams extends Equatable {
  final String projectId;
  final String memberId;

  const RemoveMemberParams({required this.projectId, required this.memberId});

  @override
  List<Object?> get props => [projectId, memberId];
}

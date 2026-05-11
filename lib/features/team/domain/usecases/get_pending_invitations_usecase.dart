import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invitation_entity.dart';
import '../repositories/team_repository.dart';

class GetPendingInvitationsUseCase
    implements UseCase<List<InvitationEntity>, String> {
  final TeamRepository repository;

  GetPendingInvitationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<InvitationEntity>>> call(String userId) {
    return repository.getPendingInvitations(userId);
  }
}

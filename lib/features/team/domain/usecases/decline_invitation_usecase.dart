import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class DeclineInvitationUseCase implements UseCase<void, String> {
  final TeamRepository repository;

  DeclineInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String invitationId) {
    return repository.declineInvitation(invitationId);
  }
}

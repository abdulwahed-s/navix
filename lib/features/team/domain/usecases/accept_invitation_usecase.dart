import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class AcceptInvitationUseCase implements UseCase<void, String> {
  final TeamRepository repository;

  AcceptInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String invitationId) {
    return repository.acceptInvitation(invitationId);
  }
}

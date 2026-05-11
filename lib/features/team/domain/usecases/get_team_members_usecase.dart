import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class GetTeamMembersUseCase implements UseCase<List<TeamMemberInfo>, String> {
  final TeamRepository repository;

  GetTeamMembersUseCase(this.repository);

  @override
  Future<Either<Failure, List<TeamMemberInfo>>> call(String projectId) {
    return repository.getTeamMembers(projectId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../repositories/user_discovery_repository.dart';

class SearchUsersUseCase
    implements UseCase<List<ProfileEntity>, SearchUsersParams> {
  final UserDiscoveryRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProfileEntity>>> call(SearchUsersParams params) {
    return repository.searchUsers(
      query: params.query,
      skills: params.skills,
      limit: params.limit,
      lastUserId: params.lastUserId,
    );
  }
}

class SearchUsersParams extends Equatable {
  final String query;
  final List<String>? skills;
  final int? limit;
  final String? lastUserId;

  const SearchUsersParams({
    required this.query,
    this.skills,
    this.limit,
    this.lastUserId,
  });

  @override
  List<Object?> get props => [query, skills, limit, lastUserId];
}

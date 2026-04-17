import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class GetUserPostsUseCase
    implements UseCase<List<PostEntity>, GetUserPostsParams> {
  final CommunityRepository repository;

  GetUserPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetUserPostsParams params) {
    return repository.getUserPosts(
      userId: params.userId,
      currentUserId: params.currentUserId,
      limit: params.limit,
    );
  }
}

class GetUserPostsParams extends Equatable {
  final String userId;
  final String currentUserId;
  final int limit;

  const GetUserPostsParams({
    required this.userId,
    required this.currentUserId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, currentUserId, limit];
}

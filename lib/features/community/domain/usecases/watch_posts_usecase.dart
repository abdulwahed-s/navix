import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class WatchPostsUseCase {
  final CommunityRepository repository;

  WatchPostsUseCase(this.repository);

  Stream<Either<Failure, List<PostEntity>>> call(WatchPostsParams params) {
    return repository.watchPosts(
      sortType: params.sortType,
      limit: params.limit,
      currentUserId: params.currentUserId,
    );
  }
}

class WatchPostsParams extends Equatable {
  final PostSortType sortType;
  final int limit;
  final String currentUserId;

  const WatchPostsParams({
    required this.sortType,
    this.limit = 20,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [sortType, limit, currentUserId];
}

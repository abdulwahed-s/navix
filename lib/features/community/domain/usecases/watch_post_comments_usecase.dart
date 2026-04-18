import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class WatchPostCommentsUseCase {
  final CommunityRepository repository;

  WatchPostCommentsUseCase(this.repository);

  Stream<Either<Failure, List<CommentEntity>>> call(
    WatchPostCommentsParams params,
  ) {
    return repository.watchPostComments(
      postId: params.postId,
      currentUserId: params.currentUserId,
    );
  }
}

class WatchPostCommentsParams extends Equatable {
  final String postId;
  final String currentUserId;

  const WatchPostCommentsParams({
    required this.postId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [postId, currentUserId];
}

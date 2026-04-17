import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class GetPostCommentsUseCase
    implements UseCase<List<CommentEntity>, GetPostCommentsParams> {
  final CommunityRepository repository;

  GetPostCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CommentEntity>>> call(
    GetPostCommentsParams params,
  ) {
    return repository.getPostComments(
      postId: params.postId,
      currentUserId: params.currentUserId,
    );
  }
}

class GetPostCommentsParams extends Equatable {
  final String postId;
  final String currentUserId;

  const GetPostCommentsParams({
    required this.postId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [postId, currentUserId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/community_repository.dart';

class VoteCommentUseCase implements UseCase<void, VoteCommentParams> {
  final CommunityRepository repository;

  VoteCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VoteCommentParams params) {
    return repository.voteComment(
      postId: params.postId,
      commentId: params.commentId,
      userId: params.userId,
      voteType: params.voteType,
    );
  }
}

class VoteCommentParams extends Equatable {
  final String postId;
  final String commentId;
  final String userId;
  final String voteType;

  const VoteCommentParams({
    required this.postId,
    required this.commentId,
    required this.userId,
    required this.voteType,
  });

  @override
  List<Object?> get props => [postId, commentId, userId, voteType];
}

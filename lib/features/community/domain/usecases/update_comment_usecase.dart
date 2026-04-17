import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class UpdateCommentUseCase
    implements UseCase<CommentEntity, UpdateCommentParams> {
  final CommunityRepository repository;

  UpdateCommentUseCase(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(UpdateCommentParams params) {
    if (params.content.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure(message: 'Comment content is required')),
      );
    }
    if (params.content.trim().length > 2000) {
      return Future.value(
        Left(
          ValidationFailure(
            message: 'Comment must be less than 2,000 characters',
          ),
        ),
      );
    }

    return repository.updateComment(
      postId: params.postId,
      commentId: params.commentId,
      content: params.content.trim(),
    );
  }
}

class UpdateCommentParams extends Equatable {
  final String postId;
  final String commentId;
  final String content;

  const UpdateCommentParams({
    required this.postId,
    required this.commentId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, commentId, content];
}

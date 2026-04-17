import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class ReplyToCommentUseCase
    implements UseCase<CommentEntity, ReplyToCommentParams> {
  final CommunityRepository repository;

  ReplyToCommentUseCase(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(ReplyToCommentParams params) {
    if (params.content.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure(message: 'Reply cannot be empty')),
      );
    }
    if (params.content.trim().length > 2000) {
      return Future.value(
        Left(
          ValidationFailure(
            message: 'Reply must be less than 2,000 characters',
          ),
        ),
      );
    }

    if (params.parentDepth >= 5) {
      return Future.value(
        Left(ValidationFailure(message: 'Maximum nesting depth reached')),
      );
    }

    return repository.replyToComment(
      postId: params.postId,
      parentCommentId: params.parentCommentId,
      authorId: params.authorId,
      content: params.content.trim(),
      parentDepth: params.parentDepth,
    );
  }
}

class ReplyToCommentParams extends Equatable {
  final String postId;
  final String parentCommentId;
  final String authorId;
  final String content;
  final int parentDepth;

  const ReplyToCommentParams({
    required this.postId,
    required this.parentCommentId,
    required this.authorId,
    required this.content,
    required this.parentDepth,
  });

  @override
  List<Object?> get props => [
    postId,
    parentCommentId,
    authorId,
    content,
    parentDepth,
  ];
}

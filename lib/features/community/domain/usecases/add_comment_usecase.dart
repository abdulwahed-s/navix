import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

class AddCommentUseCase implements UseCase<CommentEntity, AddCommentParams> {
  final CommunityRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(AddCommentParams params) {
    if (params.content.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure(message: 'Comment cannot be empty')),
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

    return repository.addComment(
      postId: params.postId,
      authorId: params.authorId,
      content: params.content.trim(),
    );
  }
}

class AddCommentParams extends Equatable {
  final String postId;
  final String authorId;
  final String content;

  const AddCommentParams({
    required this.postId,
    required this.authorId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, authorId, content];
}

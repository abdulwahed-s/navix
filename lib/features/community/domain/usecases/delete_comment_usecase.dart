import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/community_repository.dart';

class DeleteCommentUseCase implements UseCase<void, DeleteCommentParams> {
  final CommunityRepository repository;

  DeleteCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) {
    return repository.deleteComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}

class DeleteCommentParams extends Equatable {
  final String postId;
  final String commentId;

  const DeleteCommentParams({required this.postId, required this.commentId});

  @override
  List<Object?> get props => [postId, commentId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class UpdatePostUseCase implements UseCase<PostEntity, UpdatePostParams> {
  final CommunityRepository repository;

  UpdatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(UpdatePostParams params) {
    if (params.title.trim().length < 10) {
      return Future.value(
        Left(
          ValidationFailure(message: 'Title must be at least 10 characters'),
        ),
      );
    }
    if (params.title.trim().length > 300) {
      return Future.value(
        Left(
          ValidationFailure(message: 'Title must be less than 300 characters'),
        ),
      );
    }

    if (params.content.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure(message: 'Content is required')),
      );
    }
    if (params.content.trim().length > 10000) {
      return Future.value(
        Left(
          ValidationFailure(
            message: 'Content must be less than 10,000 characters',
          ),
        ),
      );
    }

    return repository.updatePost(
      postId: params.postId,
      title: params.title.trim(),
      content: params.content.trim(),
    );
  }
}

class UpdatePostParams extends Equatable {
  final String postId;
  final String title;
  final String content;

  const UpdatePostParams({
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, title, content];
}

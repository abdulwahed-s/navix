import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final CommunityRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) {
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

    return repository.createPost(
      authorId: params.authorId,
      title: params.title.trim(),
      content: params.content.trim(),
      imageUrl: params.imageUrl,
      postType: params.postType,
      surveyId: params.surveyId,
      surveyProjectId: params.surveyProjectId,
    );
  }
}

class CreatePostParams extends Equatable {
  final String authorId;
  final String title;
  final String content;
  final String? imageUrl;
  final PostType postType;
  final String? surveyId;
  final String? surveyProjectId;

  const CreatePostParams({
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.postType,
    this.surveyId,
    this.surveyProjectId,
  });

  @override
  List<Object?> get props => [
    authorId,
    title,
    content,
    imageUrl,
    postType,
    surveyId,
    surveyProjectId,
  ];
}

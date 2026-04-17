import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/community_repository.dart';

class UploadPostImageUseCase implements UseCase<String, UploadPostImageParams> {
  final CommunityRepository repository;

  UploadPostImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadPostImageParams params) {
    return repository.uploadPostImage(
      postId: params.postId,
      imagePath: params.imagePath,
    );
  }
}

class UploadPostImageParams extends Equatable {
  final String postId;
  final String imagePath;

  const UploadPostImageParams({required this.postId, required this.imagePath});

  @override
  List<Object?> get props => [postId, imagePath];
}

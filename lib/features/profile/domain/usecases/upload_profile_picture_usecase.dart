import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePictureUseCase
    implements UseCase<String, UploadProfilePictureParams> {
  final ProfileRepository repository;

  UploadProfilePictureUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) {
    return repository.uploadProfilePicture(
      userId: params.userId,
      imageFile: params.imageFile,
    );
  }
}

class UploadProfilePictureParams extends Equatable {
  final String userId;
  final File imageFile;

  const UploadProfilePictureParams({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [userId, imageFile];
}

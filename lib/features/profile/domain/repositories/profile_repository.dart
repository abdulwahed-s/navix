import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> createProfile(ProfileEntity profile);

  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);

  Future<Either<Failure, ProfileEntity?>> getProfile(String userId);

  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  Future<Either<Failure, void>> deleteProfilePicture(String userId);
}

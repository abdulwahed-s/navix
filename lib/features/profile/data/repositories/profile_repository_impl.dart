import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> createProfile(
    ProfileEntity profile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final result = await remoteDataSource.createProfile(profileModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final result = await remoteDataSource.updateProfile(profileModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final result = await remoteDataSource.getProfile(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final downloadUrl = await remoteDataSource.uploadProfilePicture(
        userId: userId,
        imageFile: imageFile,
      );
      return Right(downloadUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.deleteProfilePicture(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }
}

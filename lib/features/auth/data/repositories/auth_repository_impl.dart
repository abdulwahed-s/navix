import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
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
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
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
      final user = await remoteDataSource.register(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AuthFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;
}

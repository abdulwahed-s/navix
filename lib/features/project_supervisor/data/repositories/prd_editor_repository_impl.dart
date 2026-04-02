import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prd_editor_context.dart';
import '../../domain/entities/prd_editor_message.dart';
import '../../domain/repositories/prd_editor_repository.dart';
import '../datasources/prd_editor_remote_datasource.dart';

/// Implementation of PrdEditorRepository.
class PrdEditorRepositoryImpl implements PrdEditorRepository {
  final PrdEditorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PrdEditorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PrdEditorMessage>> sendMessage({
    required String message,
    required List<PrdEditorMessage> history,
    required PrdEditorContext context,
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
      final response = await remoteDataSource.sendMessage(
        message: message,
        history: history,
        context: context,
      );
      return Right(response);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
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

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prd_entity.dart';
import '../../domain/entities/project_idea_entity.dart';
import '../../domain/entities/refined_idea_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AIRepositoryImpl implements AIRepository {
  final AIRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AIRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<ProjectIdeaEntity>>> generateProjectIdeas(
    GenerateIdeasParams params,
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
      final ideas = await remoteDataSource.generateProjectIdeas(params);
      return Right(ideas);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AIFailure(message: 'An unexpected error occurred', code: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, RefinedIdeaEntity>> refineProjectIdea({
    required String ideaDescription,
    required List<String> userSkills,
    String? additionalContext,
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
      final refinedIdea = await remoteDataSource.refineProjectIdea(
        ideaDescription: ideaDescription,
        userSkills: userSkills,
        additionalContext: additionalContext,
      );
      return Right(refinedIdea);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AIFailure(message: 'An unexpected error occurred', code: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, PrdEntity>> generatePrd(
    GeneratePrdParams params,
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
      final prd = await remoteDataSource.generatePrd(params);
      return Right(prd);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AIFailure(message: 'An unexpected error occurred', code: e.toString()),
      );
    }
  }
}

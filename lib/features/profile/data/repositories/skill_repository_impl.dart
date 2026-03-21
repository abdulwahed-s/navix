import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/skill_status.dart';
import '../../domain/repositories/skill_repository.dart';
import '../datasources/skill_remote_datasource.dart';
import '../models/skill_model.dart';
import '../models/skill_test_model.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SkillRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SkillEntity>> validateCustomSkill(
    String skillName,
  ) async {
    final localValidationError =
        SkillRemoteDataSourceImpl.performLocalValidation(skillName);

    if (localValidationError != null) {
      return Right(
        SkillModel(
          skillName: skillName,
          status: SkillStatus.rejected,
          isVerified: false,
        ),
      );
    }

    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'no-connection',
        ),
      );
    }

    try {
      final result = await remoteDataSource.validateCustomSkill(skillName);

      if (result.isValid) {
        return Right(
          SkillModel(
            skillName: skillName,
            status: SkillStatus.approved,
            isVerified: false,
          ),
        );
      } else {
        return Right(
          SkillModel(
            skillName: skillName,
            status: SkillStatus.rejected,
            isVerified: false,
          ),
        );
      }
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred: $e',
          code: 'unknown',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SkillTestModel>> generateSkillTest(
    List<String> skillNames,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'no-connection',
        ),
      );
    }

    try {
      final test = await remoteDataSource.generateSkillTest(skillNames);
      return Right(test);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred: $e',
          code: 'unknown',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SkillTestResult>> evaluateSkillTest({
    required SkillTestModel test,
    required Map<String, String> answers,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'no-connection',
        ),
      );
    }

    try {
      final result = await remoteDataSource.evaluateSkillTest(
        test: test,
        answers: answers,
      );
      return Right(result);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred: $e',
          code: 'unknown',
        ),
      );
    }
  }
}

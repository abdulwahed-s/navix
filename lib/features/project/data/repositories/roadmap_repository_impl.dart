import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/project_roadmap_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/generate_roadmap_usecase.dart';
import '../datasources/roadmap_remote_datasource.dart';

class RoadmapRepositoryImpl implements RoadmapRepository {
  final RoadmapRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RoadmapRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProjectRoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
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
      final roadmap = await remoteDataSource.generateRoadmap(params);
      return Right(roadmap);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AIFailure(message: 'An unexpected error occurred', code: e.toString()),
      );
    }
  }
}

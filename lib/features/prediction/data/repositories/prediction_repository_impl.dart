import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../../domain/entities/risk_prediction_entity.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../datasources/prediction_remote_datasource.dart';
import '../models/risk_prediction_model.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  PredictionRepositoryImpl({
    required this.remoteDataSource,
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, RiskPredictionEntity>> analyzeProjectHealth({
    required String projectId,
    required String projectName,
    required ProjectRoadmapEntity roadmap,
    required DateTime startDate,
    required DateTime endDate,
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
      final prediction = await remoteDataSource.analyzeProject(
        projectId: projectId,
        projectName: projectName,
        roadmap: roadmap,
        startDate: startDate,
        endDate: endDate,
      );

      await storePrediction(prediction);

      return Right(prediction);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to analyze project: $e',
          code: 'prediction-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RiskPredictionEntity?>> getLatestPrediction(
    String projectId,
  ) async {
    try {
      final query = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('predictions')
          .orderBy('analyzedAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return const Right(null);
      }

      final prediction = RiskPredictionModel.fromFirestore(query.docs.first);
      return Right(prediction);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get prediction: $e',
          code: 'prediction-fetch-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<RiskPredictionEntity>>> getPredictionHistory(
    String projectId,
  ) async {
    try {
      final query = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('predictions')
          .orderBy('analyzedAt', descending: true)
          .limit(10)
          .get();

      final predictions = query.docs
          .map((doc) => RiskPredictionModel.fromFirestore(doc))
          .toList();

      return Right(predictions);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get prediction history: $e',
          code: 'prediction-history-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> storePrediction(
    RiskPredictionEntity prediction,
  ) async {
    try {
      final model = RiskPredictionModel.fromEntity(prediction);
      await firestore
          .collection('projects')
          .doc(prediction.projectId)
          .collection('predictions')
          .add(model.toJson());

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to store prediction: $e',
          code: 'prediction-store-error',
        ),
      );
    }
  }
}

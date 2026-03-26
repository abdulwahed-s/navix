import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../entities/risk_prediction_entity.dart';

abstract class PredictionRepository {
  Future<Either<Failure, RiskPredictionEntity>> analyzeProjectHealth({
    required String projectId,
    required String projectName,
    required ProjectRoadmapEntity roadmap,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, RiskPredictionEntity?>> getLatestPrediction(
    String projectId,
  );

  Future<Either<Failure, List<RiskPredictionEntity>>> getPredictionHistory(
    String projectId,
  );

  Future<Either<Failure, void>> storePrediction(
    RiskPredictionEntity prediction,
  );
}

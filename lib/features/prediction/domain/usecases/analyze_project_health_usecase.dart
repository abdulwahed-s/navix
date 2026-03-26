import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../entities/risk_prediction_entity.dart';
import '../repositories/prediction_repository.dart';

class AnalyzeProjectHealthUseCase
    implements UseCase<RiskPredictionEntity, AnalyzeProjectParams> {
  final PredictionRepository repository;

  AnalyzeProjectHealthUseCase(this.repository);

  @override
  Future<Either<Failure, RiskPredictionEntity>> call(
    AnalyzeProjectParams params,
  ) {
    return repository.analyzeProjectHealth(
      projectId: params.projectId,
      projectName: params.projectName,
      roadmap: params.roadmap,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class AnalyzeProjectParams extends Equatable {
  final String projectId;
  final String projectName;
  final ProjectRoadmapEntity roadmap;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyzeProjectParams({
    required this.projectId,
    required this.projectName,
    required this.roadmap,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    roadmap,
    startDate,
    endDate,
  ];
}

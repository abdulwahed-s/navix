part of 'prediction_bloc.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeProjectRequested extends PredictionEvent {
  final String projectId;
  final String projectName;
  final ProjectRoadmapEntity roadmap;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyzeProjectRequested({
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

class LoadCachedPrediction extends PredictionEvent {
  final String projectId;
  final String projectName;
  final ProjectRoadmapEntity roadmap;
  final DateTime startDate;
  final DateTime endDate;

  const LoadCachedPrediction({
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

class RefreshPrediction extends PredictionEvent {
  const RefreshPrediction();
}

import 'package:equatable/equatable.dart';

enum RiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }
}

class RiskPredictionEntity extends Equatable {
  final String id;
  final String projectId;
  final RiskLevel riskLevel;
  final int delayProbability;
  final List<String> blockedTasks;
  final List<String> atRiskTasks;
  final List<String> recommendations;
  final List<String> affectedMilestones;
  final DateTime analyzedAt;

  const RiskPredictionEntity({
    required this.id,
    required this.projectId,
    required this.riskLevel,
    required this.delayProbability,
    this.blockedTasks = const [],
    this.atRiskTasks = const [],
    this.recommendations = const [],
    this.affectedMilestones = const [],
    required this.analyzedAt,
  });

  bool get hasRisks =>
      blockedTasks.isNotEmpty ||
      atRiskTasks.isNotEmpty ||
      riskLevel != RiskLevel.low;

  bool get actionRequired =>
      riskLevel == RiskLevel.high || blockedTasks.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    projectId,
    riskLevel,
    delayProbability,
    blockedTasks,
    atRiskTasks,
    recommendations,
    affectedMilestones,
    analyzedAt,
  ];
}

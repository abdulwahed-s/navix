import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/risk_prediction_entity.dart';

class RiskPredictionModel extends RiskPredictionEntity {
  const RiskPredictionModel({
    required super.id,
    required super.projectId,
    required super.riskLevel,
    required super.delayProbability,
    super.blockedTasks,
    super.atRiskTasks,
    super.recommendations,
    super.affectedMilestones,
    required super.analyzedAt,
  });

  factory RiskPredictionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RiskPredictionModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      riskLevel: _parseRiskLevel(data['riskLevel'] as String?),
      delayProbability: data['delayProbability'] as int? ?? 0,
      blockedTasks: _parseList(data['blockedTasks']),
      atRiskTasks: _parseList(data['atRiskTasks']),
      recommendations: _parseList(data['recommendations']),
      affectedMilestones: _parseList(data['affectedMilestones']),
      analyzedAt:
          (data['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory RiskPredictionModel.fromEntity(RiskPredictionEntity entity) {
    return RiskPredictionModel(
      id: entity.id,
      projectId: entity.projectId,
      riskLevel: entity.riskLevel,
      delayProbability: entity.delayProbability,
      blockedTasks: entity.blockedTasks,
      atRiskTasks: entity.atRiskTasks,
      recommendations: entity.recommendations,
      affectedMilestones: entity.affectedMilestones,
      analyzedAt: entity.analyzedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'riskLevel': riskLevel.name,
      'delayProbability': delayProbability,
      'blockedTasks': blockedTasks,
      'atRiskTasks': atRiskTasks,
      'recommendations': recommendations,
      'affectedMilestones': affectedMilestones,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }

  static RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}

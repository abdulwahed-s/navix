import '../../domain/entities/prd_entity.dart';

class PrdModel extends PrdEntity {
  const PrdModel({
    required super.title,
    required super.description,
    required super.problemStatement,
    required super.projectObjective,
    required super.targetUsers,
    super.inScope = const [],
    super.outOfScope = const [],
    super.coreFeatures = const [],
    super.functionalRequirements = const [],
    super.nonFunctionalRequirements = const [],
    super.detailedRequirementsPerFeature = const {},
    super.acceptanceCriteria = const [],
    super.estimatedDurationWeeks = 8,
    super.teamSize = 1,
  });

  factory PrdModel.fromJson(Map<String, dynamic> json) {
    return PrdModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      problemStatement: json['problemStatement'] as String? ?? '',
      projectObjective: json['projectObjective'] as String? ?? '',
      targetUsers: json['targetUsers'] as String? ?? '',
      inScope: List<String>.from(json['inScope'] as List? ?? []),
      outOfScope: List<String>.from(json['outOfScope'] as List? ?? []),
      coreFeatures: List<String>.from(json['coreFeatures'] as List? ?? []),
      functionalRequirements: List<String>.from(
        json['functionalRequirements'] as List? ?? [],
      ),
      nonFunctionalRequirements: List<String>.from(
        json['nonFunctionalRequirements'] as List? ?? [],
      ),
      detailedRequirementsPerFeature: _parseDetailedRequirements(
        json['detailedRequirementsPerFeature'] as Map<String, dynamic>?,
      ),
      acceptanceCriteria: List<String>.from(
        json['acceptanceCriteria'] as List? ?? [],
      ),
      estimatedDurationWeeks: json['estimatedDurationWeeks'] as int? ?? 8,
      teamSize: json['teamSize'] as int? ?? 1,
    );
  }

  factory PrdModel.fromEntity(PrdEntity entity) {
    return PrdModel(
      title: entity.title,
      description: entity.description,
      problemStatement: entity.problemStatement,
      projectObjective: entity.projectObjective,
      targetUsers: entity.targetUsers,
      inScope: entity.inScope,
      outOfScope: entity.outOfScope,
      coreFeatures: entity.coreFeatures,
      functionalRequirements: entity.functionalRequirements,
      nonFunctionalRequirements: entity.nonFunctionalRequirements,
      detailedRequirementsPerFeature: entity.detailedRequirementsPerFeature,
      acceptanceCriteria: entity.acceptanceCriteria,
      estimatedDurationWeeks: entity.estimatedDurationWeeks,
      teamSize: entity.teamSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'problemStatement': problemStatement,
      'projectObjective': projectObjective,
      'targetUsers': targetUsers,
      'inScope': inScope,
      'outOfScope': outOfScope,
      'coreFeatures': coreFeatures,
      'functionalRequirements': functionalRequirements,
      'nonFunctionalRequirements': nonFunctionalRequirements,
      'detailedRequirementsPerFeature': detailedRequirementsPerFeature.map(
        (key, value) => MapEntry(key, value),
      ),
      'acceptanceCriteria': acceptanceCriteria,
      'estimatedDurationWeeks': estimatedDurationWeeks,
      'teamSize': teamSize,
    };
  }

  static Map<String, List<String>> _parseDetailedRequirements(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return {};
    return data.map(
      (key, value) => MapEntry(key, List<String>.from(value as List? ?? [])),
    );
  }
}

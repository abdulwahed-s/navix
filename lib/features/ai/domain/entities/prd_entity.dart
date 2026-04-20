import 'package:equatable/equatable.dart';

class PrdEntity extends Equatable {
  final String title;

  final String description;

  final String problemStatement;

  final String projectObjective;

  final String targetUsers;

  final List<String> inScope;

  final List<String> outOfScope;

  final List<String> coreFeatures;

  final List<String> functionalRequirements;

  final List<String> nonFunctionalRequirements;

  final Map<String, List<String>> detailedRequirementsPerFeature;

  final List<String> acceptanceCriteria;

  final int estimatedDurationWeeks;

  final int teamSize;

  const PrdEntity({
    required this.title,
    required this.description,
    required this.problemStatement,
    required this.projectObjective,
    required this.targetUsers,
    this.inScope = const [],
    this.outOfScope = const [],
    this.coreFeatures = const [],
    this.functionalRequirements = const [],
    this.nonFunctionalRequirements = const [],
    this.detailedRequirementsPerFeature = const {},
    this.acceptanceCriteria = const [],
    this.estimatedDurationWeeks = 8,
    this.teamSize = 1,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    problemStatement,
    projectObjective,
    targetUsers,
    inScope,
    outOfScope,
    coreFeatures,
    functionalRequirements,
    nonFunctionalRequirements,
    detailedRequirementsPerFeature,
    acceptanceCriteria,
    estimatedDurationWeeks,
    teamSize,
  ];

  PrdEntity copyWith({
    String? title,
    String? description,
    String? problemStatement,
    String? projectObjective,
    String? targetUsers,
    List<String>? inScope,
    List<String>? outOfScope,
    List<String>? coreFeatures,
    List<String>? functionalRequirements,
    List<String>? nonFunctionalRequirements,
    Map<String, List<String>>? detailedRequirementsPerFeature,
    List<String>? acceptanceCriteria,
    int? estimatedDurationWeeks,
    int? teamSize,
  }) {
    return PrdEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      problemStatement: problemStatement ?? this.problemStatement,
      projectObjective: projectObjective ?? this.projectObjective,
      targetUsers: targetUsers ?? this.targetUsers,
      inScope: inScope ?? this.inScope,
      outOfScope: outOfScope ?? this.outOfScope,
      coreFeatures: coreFeatures ?? this.coreFeatures,
      functionalRequirements:
          functionalRequirements ?? this.functionalRequirements,
      nonFunctionalRequirements:
          nonFunctionalRequirements ?? this.nonFunctionalRequirements,
      detailedRequirementsPerFeature:
          detailedRequirementsPerFeature ?? this.detailedRequirementsPerFeature,
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
      estimatedDurationWeeks:
          estimatedDurationWeeks ?? this.estimatedDurationWeeks,
      teamSize: teamSize ?? this.teamSize,
    );
  }
}

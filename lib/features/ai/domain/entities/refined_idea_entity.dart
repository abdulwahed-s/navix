import 'package:equatable/equatable.dart';

class RefinedIdeaEntity extends Equatable {
  final String originalIdea;
  final String improvedDescription;
  final String scopeClarification;
  final List<String> suggestedFeatures;
  final int feasibilityScore;
  final String feasibilityExplanation;
  final List<String> requiredSkills;
  final List<String> userMatchingSkills;
  final List<String> missingSkills;

  const RefinedIdeaEntity({
    required this.originalIdea,
    required this.improvedDescription,
    required this.scopeClarification,
    required this.suggestedFeatures,
    required this.feasibilityScore,
    required this.feasibilityExplanation,
    required this.requiredSkills,
    this.userMatchingSkills = const [],
    this.missingSkills = const [],
  });

  @override
  List<Object?> get props => [
    originalIdea,
    improvedDescription,
    scopeClarification,
    suggestedFeatures,
    feasibilityScore,
    feasibilityExplanation,
    requiredSkills,
    userMatchingSkills,
    missingSkills,
  ];
}

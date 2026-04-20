import 'package:equatable/equatable.dart';

enum ProjectComplexity {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case ProjectComplexity.low:
        return 'Low';
      case ProjectComplexity.medium:
        return 'Medium';
      case ProjectComplexity.high:
        return 'High';
    }
  }
}

class ProjectIdeaEntity extends Equatable {
  final String title;

  final String description;

  final List<String> skills;

  final int estimatedDurationWeeks;

  final ProjectComplexity complexity;

  final int feasibilityScore;

  final bool isTeamProject;

  const ProjectIdeaEntity({
    required this.title,
    required this.description,
    required this.skills,
    required this.estimatedDurationWeeks,
    required this.complexity,
    required this.feasibilityScore,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    skills,
    estimatedDurationWeeks,
    complexity,
    feasibilityScore,
    isTeamProject,
  ];
}

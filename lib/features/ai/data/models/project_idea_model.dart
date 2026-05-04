import '../../domain/entities/project_idea_entity.dart';

class ProjectIdeaModel extends ProjectIdeaEntity {
  const ProjectIdeaModel({
    required super.title,
    required super.description,
    required super.skills,
    required super.estimatedDurationWeeks,
    required super.complexity,
    required super.feasibilityScore,
    super.isTeamProject = false,
  });

  factory ProjectIdeaModel.fromJson(Map<String, dynamic> json) {
    return ProjectIdeaModel(
      title: json['title'] as String? ?? 'Untitled Project',
      description: json['description'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? []),
      estimatedDurationWeeks: json['estimatedDurationWeeks'] as int? ?? 4,
      complexity: _parseComplexity(json['complexity'] as String?),
      feasibilityScore: (json['feasibilityScore'] as num?)?.toInt() ?? 7,
      isTeamProject: json['isTeamProject'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'skills': skills,
      'estimatedDurationWeeks': estimatedDurationWeeks,
      'complexity': complexity.name,
      'feasibilityScore': feasibilityScore,
      'isTeamProject': isTeamProject,
    };
  }

  static ProjectComplexity _parseComplexity(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return ProjectComplexity.low;
      case 'medium':
        return ProjectComplexity.medium;
      case 'high':
        return ProjectComplexity.high;
      default:
        return ProjectComplexity.medium;
    }
  }
}

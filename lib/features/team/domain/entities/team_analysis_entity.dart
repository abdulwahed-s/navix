class RoleSuggestion {
  final String suggestedRole;

  final String reasoning;

  final double confidence;

  const RoleSuggestion({
    required this.suggestedRole,
    required this.reasoning,
    this.confidence = 0.8,
  });
}

class SkillRequirement {
  final String skillName;

  final String level;

  final bool isCritical;

  const SkillRequirement({
    required this.skillName,
    required this.level,
    this.isCritical = false,
  });
}

class MissingRoleInfo {
  final String roleName;

  final List<SkillRequirement> requiredSkills;

  final String priority;

  final int taskCount;

  const MissingRoleInfo({
    required this.roleName,
    required this.requiredSkills,
    this.priority = 'medium',
    this.taskCount = 0,
  });
}

class TeamAnalysisEntity {
  final String id;

  final String projectId;

  final DateTime analyzedAt;

  final Map<String, RoleSuggestion> memberSuggestions;

  final List<MissingRoleInfo> missingRoles;

  final List<String> projectRoles;

  const TeamAnalysisEntity({
    required this.id,
    required this.projectId,
    required this.analyzedAt,
    required this.memberSuggestions,
    required this.missingRoles,
    required this.projectRoles,
  });

  bool get isStale {
    final now = DateTime.now();
    return now.difference(analyzedAt).inHours > 24;
  }
}

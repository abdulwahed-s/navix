import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/team_analysis_entity.dart';

class TeamAnalysisModel extends TeamAnalysisEntity {
  const TeamAnalysisModel({
    required super.id,
    required super.projectId,
    required super.analyzedAt,
    required super.memberSuggestions,
    required super.missingRoles,
    required super.projectRoles,
  });

  factory TeamAnalysisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final suggestionsMap = <String, RoleSuggestion>{};
    final rawSuggestions =
        data['memberRoleSuggestions'] as Map<String, dynamic>? ?? {};
    for (final entry in rawSuggestions.entries) {
      final suggestionData = entry.value as Map<String, dynamic>;
      suggestionsMap[entry.key] = RoleSuggestion(
        suggestedRole: suggestionData['suggestedRole'] as String? ?? '',
        reasoning: suggestionData['reasoning'] as String? ?? '',
        confidence: (suggestionData['confidence'] as num?)?.toDouble() ?? 0.8,
      );
    }

    final missingRolesList = <MissingRoleInfo>[];
    final rawMissingRoles = data['missingRoles'] as List<dynamic>? ?? [];
    for (final roleData in rawMissingRoles) {
      final role = roleData as Map<String, dynamic>;
      final skillsList = <SkillRequirement>[];
      final rawSkills = role['requiredSkills'] as List<dynamic>? ?? [];
      for (final skillData in rawSkills) {
        final skill = skillData as Map<String, dynamic>;
        skillsList.add(
          SkillRequirement(
            skillName: skill['skillName'] as String? ?? '',
            level: skill['level'] as String? ?? 'intermediate',
            isCritical: skill['isCritical'] as bool? ?? false,
          ),
        );
      }
      missingRolesList.add(
        MissingRoleInfo(
          roleName: role['roleName'] as String? ?? '',
          requiredSkills: skillsList,
          priority: role['priority'] as String? ?? 'medium',
          taskCount: role['taskCount'] as int? ?? 0,
        ),
      );
    }

    final projectRoles =
        (data['projectRoles'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    return TeamAnalysisModel(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      analyzedAt:
          (data['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberSuggestions: suggestionsMap,
      missingRoles: missingRolesList,
      projectRoles: projectRoles,
    );
  }

  Map<String, dynamic> toJson() {
    final suggestionsJson = <String, dynamic>{};
    for (final entry in memberSuggestions.entries) {
      suggestionsJson[entry.key] = {
        'suggestedRole': entry.value.suggestedRole,
        'reasoning': entry.value.reasoning,
        'confidence': entry.value.confidence,
      };
    }

    final missingRolesJson = <Map<String, dynamic>>[];
    for (final role in missingRoles) {
      final skillsJson = <Map<String, dynamic>>[];
      for (final skill in role.requiredSkills) {
        skillsJson.add({
          'skillName': skill.skillName,
          'level': skill.level,
          'isCritical': skill.isCritical,
        });
      }
      missingRolesJson.add({
        'roleName': role.roleName,
        'priority': role.priority,
        'taskCount': role.taskCount,
        'requiredSkills': skillsJson,
      });
    }

    return {
      'projectId': projectId,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
      'memberRoleSuggestions': suggestionsJson,
      'missingRoles': missingRolesJson,
      'projectRoles': projectRoles,
    };
  }

  factory TeamAnalysisModel.fromEntity(TeamAnalysisEntity entity) {
    return TeamAnalysisModel(
      id: entity.id,
      projectId: entity.projectId,
      analyzedAt: entity.analyzedAt,
      memberSuggestions: entity.memberSuggestions,
      missingRoles: entity.missingRoles,
      projectRoles: entity.projectRoles,
    );
  }
}

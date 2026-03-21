import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/skill_level.dart';
import '../../domain/entities/skill_status.dart';

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.skillName,
    super.status = SkillStatus.approved,
    super.isVerified = false,
    super.skillLevel,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillName: json['skillName'] as String? ?? '',
      status: SkillStatus.fromString(json['status'] as String? ?? 'APPROVED'),
      isVerified: json['isVerified'] as bool? ?? false,
      skillLevel: SkillLevel.fromString(json['skillLevel'] as String?),
    );
  }

  factory SkillModel.fromLegacyString(String skillName) {
    return SkillModel(
      skillName: skillName,
      status: SkillStatus.approved,
      isVerified: false,
    );
  }

  factory SkillModel.fromEntity(SkillEntity entity) {
    return SkillModel(
      skillName: entity.skillName,
      status: entity.status,
      isVerified: entity.isVerified,
      skillLevel: entity.skillLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillName': skillName,
      'status': status.toJson(),
      'isVerified': isVerified,
      'skillLevel': skillLevel?.toJson(),
    };
  }

  static List<SkillEntity> parseSkillsList(dynamic skillsData) {
    if (skillsData == null) return [];
    if (skillsData is! List) return [];

    return skillsData.map<SkillEntity>((item) {
      if (item is String) {
        return SkillModel.fromLegacyString(item);
      } else if (item is Map<String, dynamic>) {
        return SkillModel.fromJson(item);
      } else {
        return SkillModel.fromLegacyString(item.toString());
      }
    }).toList();
  }

  @override
  SkillModel copyWith({
    String? skillName,
    SkillStatus? status,
    bool? isVerified,
    SkillLevel? skillLevel,
  }) {
    return SkillModel(
      skillName: skillName ?? this.skillName,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/skill_entity.dart';
import 'skill_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.name,
    super.organization,
    super.profilePicUrl,
    super.skills = const [],
    super.portfolioLink,
    super.githubLink,
    super.otherLinks = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final userId = doc.reference.parent.parent?.id ?? '';

    final skillsData = data['skills'] as List? ?? [];
    final skills = _parseSkills(skillsData);

    return ProfileModel(
      userId: userId,
      name: data['name'] as String? ?? '',
      organization: data['organization'] as String?,
      profilePicUrl: data['profilePicUrl'] as String?,
      skills: skills,
      portfolioLink: data['portfolioLink'] as String?,
      githubLink: data['githubLink'] as String?,
      otherLinks: List<String>.from(data['otherLinks'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static List<SkillModel> _parseSkills(List<dynamic> skillsData) {
    return skillsData
        .map((skill) {
          if (skill is String) {
            return SkillModel.fromLegacyString(skill);
          } else if (skill is Map<String, dynamic>) {
            return SkillModel.fromJson(skill);
          }
          return SkillModel.fromLegacyString('');
        })
        .where((s) => s.skillName.isNotEmpty)
        .toList();
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final skillsData = json['skills'] as List? ?? [];

    return ProfileModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      organization: json['organization'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      skills: _parseSkills(skillsData),
      portfolioLink: json['portfolioLink'] as String?,
      githubLink: json['githubLink'] as String?,
      otherLinks: List<String>.from(json['otherLinks'] as List? ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      userId: entity.userId,
      name: entity.name,
      organization: entity.organization,
      profilePicUrl: entity.profilePicUrl,
      skills: entity.skills
          .map((s) => s is SkillModel ? s : SkillModel.fromEntity(s))
          .toList(),
      portfolioLink: entity.portfolioLink,
      githubLink: entity.githubLink,
      otherLinks: entity.otherLinks,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final skillsJson = skills
        .map(
          (s) =>
              s is SkillModel ? s.toJson() : SkillModel.fromEntity(s).toJson(),
        )
        .toList();

    return {
      'name': name,
      'organization': organization,
      'profilePicUrl': profilePicUrl,
      'skills': skillsJson,
      'portfolioLink': portfolioLink,
      'githubLink': githubLink,
      'otherLinks': otherLinks,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ProfileModel copyWith({
    String? userId,
    String? name,
    String? organization,
    String? profilePicUrl,
    List<SkillEntity>? skills,
    String? portfolioLink,
    String? githubLink,
    List<String>? otherLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      skills: skills ?? this.skills,
      portfolioLink: portfolioLink ?? this.portfolioLink,
      githubLink: githubLink ?? this.githubLink,
      otherLinks: otherLinks ?? this.otherLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

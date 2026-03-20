import 'package:equatable/equatable.dart';

import 'skill_entity.dart';

class ProfileEntity extends Equatable {
  final String userId;

  final String name;

  final String? organization;

  final String? profilePicUrl;

  final List<SkillEntity> skills;

  final String? portfolioLink;

  final String? githubLink;

  final List<String> otherLinks;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  const ProfileEntity({
    required this.userId,
    required this.name,
    this.organization,
    this.profilePicUrl,
    this.skills = const [],
    this.portfolioLink,
    this.githubLink,
    this.otherLinks = const [],
    this.createdAt,
    this.updatedAt,
  });

  List<String> get skillNames => skills.map((s) => s.skillName).toList();

  List<SkillEntity> get verifiedSkills =>
      skills.where((s) => s.isVerified).toList();

  List<SkillEntity> get unverifiedSkills =>
      skills.where((s) => s.canBeVerified).toList();

  List<SkillEntity> get rejectedSkills =>
      skills.where((s) => s.isRejected).toList();

  List<SkillEntity> get pendingSkills =>
      skills.where((s) => s.isPending).toList();

  bool get hasUnverifiedSkills => unverifiedSkills.isNotEmpty;

  bool get hasRejectedSkills => rejectedSkills.isNotEmpty;

  @override
  List<Object?> get props => [
    userId,
    name,
    organization,
    profilePicUrl,
    skills,
    portfolioLink,
    githubLink,
    otherLinks,
    createdAt,
    updatedAt,
  ];
}

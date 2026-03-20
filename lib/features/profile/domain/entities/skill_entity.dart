import 'package:equatable/equatable.dart';

import 'skill_level.dart';
import 'skill_status.dart';

class SkillEntity extends Equatable {
  final String skillName;

  final SkillStatus status;

  final bool isVerified;

  final SkillLevel? skillLevel;

  const SkillEntity({
    required this.skillName,
    this.status = SkillStatus.approved,
    this.isVerified = false,
    this.skillLevel,
  });

  factory SkillEntity.predefined(String name) {
    return SkillEntity(
      skillName: name,
      status: SkillStatus.approved,
      isVerified: false,
    );
  }

  factory SkillEntity.custom(String name) {
    return SkillEntity(
      skillName: name,
      status: SkillStatus.pending,
      isVerified: false,
    );
  }

  SkillEntity copyWith({
    String? skillName,
    SkillStatus? status,
    bool? isVerified,
    SkillLevel? skillLevel,
  }) {
    return SkillEntity(
      skillName: skillName ?? this.skillName,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  bool get canBeVerified => status == SkillStatus.approved && !isVerified;

  bool get isRejected => status == SkillStatus.rejected;

  bool get isPending => status == SkillStatus.pending;

  bool get isApproved => status == SkillStatus.approved;

  @override
  List<Object?> get props => [skillName, status, isVerified, skillLevel];
}

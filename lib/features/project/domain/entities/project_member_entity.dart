import 'package:equatable/equatable.dart';

enum ProjectMemberRole {
  leader,
  member;

  String get displayName {
    switch (this) {
      case ProjectMemberRole.leader:
        return 'Project Leader';
      case ProjectMemberRole.member:
        return 'Team Member';
    }
  }
}

class ProjectMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String projectId;
  final ProjectMemberRole role;
  final DateTime joinedAt;

  const ProjectMemberEntity({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, userId, projectId, role, joinedAt];
}

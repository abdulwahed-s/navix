import 'package:equatable/equatable.dart';

import 'open_role.dart';

class ProjectListingEntity extends Equatable {
  final String id;

  final String projectId;

  final String leaderId;

  final String projectName;

  final String projectDescription;

  final String? leaderMessage;

  final bool hasApplied;

  final List<OpenRole> openRoles;

  final String status;

  final DateTime createdAt;

  final DateTime updatedAt;

  const ProjectListingEntity({
    required this.id,
    required this.projectId,
    required this.leaderId,
    required this.projectName,
    required this.projectDescription,
    this.leaderMessage,
    this.hasApplied = false,
    required this.openRoles,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [
    id,
    projectId,
    leaderId,
    projectName,
    projectDescription,
    leaderMessage,
    hasApplied,
    openRoles,
    status,
    createdAt,
    updatedAt,
  ];
}

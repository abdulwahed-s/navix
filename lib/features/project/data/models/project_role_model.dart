import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project_role_entity.dart';

class ProjectRoleModel extends ProjectRoleEntity {
  const ProjectRoleModel({
    required super.roleName,
    super.assignedUserId,
    super.assignedUserName,
    required super.taskCount,
  });

  factory ProjectRoleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProjectRoleModel(
      roleName: doc.id,
      assignedUserId: data['assignedUserId'] as String?,
      assignedUserName: data['assignedUserName'] as String?,
      taskCount: data['taskCount'] as int? ?? 0,
    );
  }

  factory ProjectRoleModel.fromEntity(ProjectRoleEntity entity) {
    return ProjectRoleModel(
      roleName: entity.roleName,
      assignedUserId: entity.assignedUserId,
      assignedUserName: entity.assignedUserName,
      taskCount: entity.taskCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignedUserId': assignedUserId,
      'assignedUserName': assignedUserName,
      'taskCount': taskCount,
    };
  }
}

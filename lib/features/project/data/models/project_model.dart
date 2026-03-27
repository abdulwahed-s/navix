import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.leaderId,
    super.memberIds = const [],
    super.status = ProjectStatus.active,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    super.updatedAt,
    super.completionPercentage = 0.0,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProjectModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      leaderId: data['leaderId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      status: _parseStatus(data['status'] as String?),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completionPercentage:
          (data['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      leaderId: entity.leaderId,
      memberIds: entity.memberIds,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completionPercentage: entity.completionPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completionPercentage': completionPercentage,
    };
  }

  static ProjectStatus _parseStatus(String? value) {
    switch (value) {
      case 'active':
        return ProjectStatus.active;
      case 'completed':
        return ProjectStatus.completed;
      case 'paused':
        return ProjectStatus.paused;
      default:
        return ProjectStatus.active;
    }
  }
}

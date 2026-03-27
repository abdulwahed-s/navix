import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/milestone_entity.dart';

class MilestoneModel extends MilestoneEntity {
  const MilestoneModel({
    required super.id,
    required super.projectId,
    required super.name,
    super.description = '',
    required super.deadline,
    super.completed = false,
    required super.order,
  });

  factory MilestoneModel.fromFirestore(DocumentSnapshot doc, String projectId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MilestoneModel(
      id: doc.id,
      projectId: projectId,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completed: data['completed'] as bool? ?? false,
      order: data['order'] as int? ?? 0,
    );
  }

  factory MilestoneModel.fromJson(Map<String, dynamic> json, String projectId) {
    return MilestoneModel(
      id: json['id'] as String? ?? '',
      projectId: projectId,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      completed: json['completed'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  factory MilestoneModel.fromEntity(MilestoneEntity entity) {
    return MilestoneModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      description: entity.description,
      deadline: entity.deadline,
      completed: entity.completed,
      order: entity.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'completed': completed,
      'order': order,
    };
  }
}

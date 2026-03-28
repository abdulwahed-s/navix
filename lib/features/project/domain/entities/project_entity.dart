import 'package:equatable/equatable.dart';

enum ProjectStatus {
  active,
  completed,
  paused;

  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.paused:
        return 'Paused';
    }
  }
}

class ProjectEntity extends Equatable {
  final String id;

  final String name;

  final String description;

  final String leaderId;

  final List<String> memberIds;

  final ProjectStatus status;

  final DateTime startDate;

  final DateTime endDate;

  final DateTime createdAt;

  final DateTime? updatedAt;

  final double completionPercentage;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    this.memberIds = const [],
    this.status = ProjectStatus.active,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    this.completionPercentage = 0.0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    leaderId,
    memberIds,
    status,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    completionPercentage,
  ];
}

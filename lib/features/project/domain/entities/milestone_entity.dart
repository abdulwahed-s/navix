import 'package:equatable/equatable.dart';

class MilestoneEntity extends Equatable {
  final String id;

  final String projectId;

  final String name;

  final String description;

  final DateTime deadline;

  final bool completed;

  final int order;

  const MilestoneEntity({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    required this.deadline,
    this.completed = false,
    required this.order,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    name,
    description,
    deadline,
    completed,
    order,
  ];
}

import 'package:equatable/equatable.dart';

enum CalendarEventType {
  milestoneDeadline,
  taskDeadline,
  meeting;

  String get displayName {
    switch (this) {
      case CalendarEventType.milestoneDeadline:
        return 'Milestone Deadline';
      case CalendarEventType.taskDeadline:
        return 'Task Deadline';
      case CalendarEventType.meeting:
        return 'Meeting';
    }
  }
}

class CalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String projectId;
  final String projectName;
  final DateTime date;
  final CalendarEventType type;
  final String description;
  final String? relatedId;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.projectId,
    required this.projectName,
    required this.date,
    required this.type,
    this.description = '',
    this.relatedId,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isOverdue => date.isBefore(DateTime.now()) && !isToday;

  @override
  List<Object?> get props => [
    id,
    title,
    projectId,
    projectName,
    date,
    type,
    description,
    relatedId,
  ];
}

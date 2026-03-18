import 'package:equatable/equatable.dart';

enum NotificationType {
  taskAssigned,
  taskDueSoon,
  taskOverdue,
  milestoneReached,
  highRiskDetected,
  newMessage,
  projectInvitation,
  connectionRequest,
  newComment,
  commentReply,
  general,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;
  final String? relatedId;
  final String? actionStatus;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.read = false,
    required this.createdAt,
    this.relatedId,
    this.actionStatus,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
    String? relatedId,
    String? actionStatus,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      relatedId: relatedId ?? this.relatedId,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    data,
    read,
    createdAt,
    relatedId,
    actionStatus,
  ];
}

import 'package:equatable/equatable.dart';

class TaskCommentEntity extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String? userProfilePicUrl;
  final String comment;
  final DateTime createdAt;

  const TaskCommentEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    this.userProfilePicUrl,
    required this.comment,
    required this.createdAt,
  });

  TaskCommentEntity copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? userName,
    String? userProfilePicUrl,
    String? comment,
    DateTime? createdAt,
  }) {
    return TaskCommentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePicUrl: userProfilePicUrl ?? this.userProfilePicUrl,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    userId,
    userName,
    userProfilePicUrl,
    comment,
    createdAt,
  ];
}

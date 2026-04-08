import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_comment_entity.dart';

class TaskCommentModel extends TaskCommentEntity {
  const TaskCommentModel({
    required super.id,
    required super.taskId,
    required super.userId,
    required super.userName,
    super.userProfilePicUrl,
    required super.comment,
    required super.createdAt,
  });

  factory TaskCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskCommentModel(
      id: doc.id,
      taskId: data['taskId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown',
      userProfilePicUrl: data['userProfilePicUrl'] as String?,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TaskCommentModel.fromEntity(TaskCommentEntity entity) {
    return TaskCommentModel(
      id: entity.id,
      taskId: entity.taskId,
      userId: entity.userId,
      userName: entity.userName,
      userProfilePicUrl: entity.userProfilePicUrl,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

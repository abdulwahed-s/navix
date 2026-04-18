import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    super.parentCommentId,
    required super.authorId,
    required super.content,
    super.upvotes = 0,
    super.downvotes = 0,
    super.userVote = VoteType.none,
    super.replyCount = 0,
    super.depth = 0,
    required super.createdAt,
    required super.updatedAt,
    super.edited = false,
  });

  factory CommentModel.fromFirestore(
    DocumentSnapshot doc,
    String postId,
    VoteType userVote,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: doc.id,
      postId: postId,
      parentCommentId: data['parentCommentId'] as String?,
      authorId: data['authorId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (data['downvotes'] as num?)?.toInt() ?? 0,
      userVote: userVote,
      replyCount: (data['replyCount'] as num?)?.toInt() ?? 0,
      depth: (data['depth'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edited: data['edited'] as bool? ?? false,
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      postId: entity.postId,
      parentCommentId: entity.parentCommentId,
      authorId: entity.authorId,
      content: entity.content,
      upvotes: entity.upvotes,
      downvotes: entity.downvotes,
      userVote: entity.userVote,
      replyCount: entity.replyCount,
      depth: entity.depth,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      edited: entity.edited,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'parentCommentId': parentCommentId,
      'authorId': authorId,
      'content': content,
      'voteScore': voteScore,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'replyCount': replyCount,
      'depth': depth,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'edited': edited,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? parentCommentId,
    String? authorId,
    String? content,
    int? upvotes,
    int? downvotes,
    VoteType? userVote,
    int? replyCount,
    int? depth,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? edited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      userVote: userVote ?? this.userVote,
      replyCount: replyCount ?? this.replyCount,
      depth: depth ?? this.depth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      edited: edited ?? this.edited,
    );
  }
}

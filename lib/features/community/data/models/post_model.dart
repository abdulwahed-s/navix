import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.postType,
    super.upvotes = 0,
    super.downvotes = 0,
    super.userVote = VoteType.none,
    super.commentCount = 0,
    required super.createdAt,
    required super.updatedAt,
    super.edited = false,
    super.surveyId,
    super.surveyProjectId,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc, VoteType userVote) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      postType: _parsePostType(data['postType'] as String?),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (data['downvotes'] as num?)?.toInt() ?? 0,
      userVote: userVote,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edited: data['edited'] as bool? ?? false,
      surveyId: data['surveyId'] as String?,
      surveyProjectId: data['surveyProjectId'] as String?,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      authorId: entity.authorId,
      title: entity.title,
      content: entity.content,
      imageUrl: entity.imageUrl,
      postType: entity.postType,
      upvotes: entity.upvotes,
      downvotes: entity.downvotes,
      userVote: entity.userVote,
      commentCount: entity.commentCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      edited: entity.edited,
      surveyId: entity.surveyId,
      surveyProjectId: entity.surveyProjectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'postType': postType.name,
      'voteScore': voteScore,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'edited': edited,
      if (surveyId != null) 'surveyId': surveyId,
      if (surveyProjectId != null) 'surveyProjectId': surveyProjectId,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    String? imageUrl,
    PostType? postType,
    int? upvotes,
    int? downvotes,
    VoteType? userVote,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? edited,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      postType: postType ?? this.postType,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      userVote: userVote ?? this.userVote,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      edited: edited ?? this.edited,
    );
  }

  static PostType _parsePostType(String? value) {
    switch (value) {
      case 'text':
        return PostType.text;
      case 'textWithImage':
        return PostType.textWithImage;
      case 'survey':
        return PostType.survey;
      default:
        return PostType.text;
    }
  }
}

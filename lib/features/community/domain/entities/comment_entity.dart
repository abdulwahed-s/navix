import 'package:equatable/equatable.dart';

import 'post_entity.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String authorId;
  final String content;
  final int upvotes;
  final int downvotes;
  final VoteType userVote;
  final int replyCount;
  final int depth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool edited;

  const CommentEntity({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.authorId,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVote = VoteType.none,
    this.replyCount = 0,
    this.depth = 0,
    required this.createdAt,
    required this.updatedAt,
    this.edited = false,
  });

  bool get isTopLevel => parentCommentId == null;

  bool get canReply => depth < 5;

  int get voteScore => upvotes - downvotes;

  @override
  List<Object?> get props => [
    id,
    postId,
    parentCommentId,
    authorId,
    content,
    upvotes,
    downvotes,
    userVote,
    replyCount,
    depth,
    createdAt,
    updatedAt,
    edited,
  ];
}

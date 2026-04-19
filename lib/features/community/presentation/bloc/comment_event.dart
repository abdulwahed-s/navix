part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentEvent {
  final String postId;
  final String currentUserId;

  const LoadComments({required this.postId, required this.currentUserId});

  @override
  List<Object?> get props => [postId, currentUserId];
}

class AddCommentEvent extends CommentEvent {
  final String postId;
  final String authorId;
  final String content;

  const AddCommentEvent({
    required this.postId,
    required this.authorId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, authorId, content];
}

class ReplyToCommentEvent extends CommentEvent {
  final String postId;
  final String parentCommentId;
  final int parentDepth;
  final String authorId;
  final String content;

  const ReplyToCommentEvent({
    required this.postId,
    required this.parentCommentId,
    required this.parentDepth,
    required this.authorId,
    required this.content,
  });

  @override
  List<Object?> get props => [
    postId,
    parentCommentId,
    parentDepth,
    authorId,
    content,
  ];
}

class VoteCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;
  final String userId;
  final String voteType;

  const VoteCommentEvent({
    required this.postId,
    required this.commentId,
    required this.userId,
    required this.voteType,
  });

  @override
  List<Object?> get props => [postId, commentId, userId, voteType];
}

class DeleteCommentEvent extends CommentEvent {
  final String postId;
  final String commentId;

  const DeleteCommentEvent({required this.postId, required this.commentId});

  @override
  List<Object?> get props => [postId, commentId];
}

class SubscribeToComments extends CommentEvent {
  final String postId;
  final String currentUserId;

  const SubscribeToComments({
    required this.postId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [postId, currentUserId];
}

class CommentsUpdated extends CommentEvent {
  final List<CommentEntity> comments;
  final String postId;

  const CommentsUpdated({required this.comments, required this.postId});

  @override
  List<Object?> get props => [comments, postId];
}

part of 'comment_bloc.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentState {
  const CommentsInitial();
}

class CommentsLoading extends CommentState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentState {
  final List<CommentEntity> comments;
  final String postId;

  const CommentsLoaded({required this.comments, required this.postId});

  @override
  List<Object?> get props => [comments, postId];

  CommentsLoaded copyWith({List<CommentEntity>? comments, String? postId}) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      postId: postId ?? this.postId,
    );
  }
}

class CommentAdding extends CommentState {
  final List<CommentEntity> currentComments;

  const CommentAdding({required this.currentComments});

  @override
  List<Object?> get props => [currentComments];
}

class CommentAdded extends CommentState {
  final CommentEntity comment;

  const CommentAdded({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class CommentError extends CommentState {
  final String message;
  final String code;

  const CommentError({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}

class CommentsEmpty extends CommentState {
  final String postId;

  const CommentsEmpty({required this.postId});

  @override
  List<Object?> get props => [postId];
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/get_post_comments_usecase.dart';
import '../../domain/usecases/reply_to_comment_usecase.dart';
import '../../domain/usecases/vote_comment_usecase.dart';
import '../../domain/usecases/watch_post_comments_usecase.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final ReplyToCommentUseCase replyToCommentUseCase;
  final VoteCommentUseCase voteCommentUseCase;
  final WatchPostCommentsUseCase watchPostCommentsUseCase;

  List<CommentEntity> _currentComments = [];
  StreamSubscription? _commentsSubscription;
  String _currentPostId = '';

  CommentBloc({
    required this.getPostCommentsUseCase,
    required this.addCommentUseCase,
    required this.replyToCommentUseCase,
    required this.voteCommentUseCase,
    required this.watchPostCommentsUseCase,
  }) : super(const CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<ReplyToCommentEvent>(_onReplyToComment);
    on<VoteCommentEvent>(_onVoteComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<SubscribeToComments>(_onSubscribeToComments);
    on<CommentsUpdated>(_onCommentsUpdated);
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentsLoading());

    final result = await getPostCommentsUseCase(
      GetPostCommentsParams(
        postId: event.postId,
        currentUserId: event.currentUserId,
      ),
    );

    result.fold(
      (failure) =>
          emit(CommentError(message: failure.message, code: failure.code!)),
      (comments) {
        _currentComments = comments;
        if (comments.isEmpty) {
          emit(CommentsEmpty(postId: event.postId));
        } else {
          emit(CommentsLoaded(comments: comments, postId: event.postId));
        }

        add(
          SubscribeToComments(
            postId: event.postId,
            currentUserId: event.currentUserId,
          ),
        );
      },
    );
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (state is CommentsLoaded) {
      emit(CommentAdding(currentComments: _currentComments));
    }

    final result = await addCommentUseCase(
      AddCommentParams(
        postId: event.postId,
        authorId: event.authorId,
        content: event.content,
      ),
    );

    result.fold(
      (failure) =>
          emit(CommentError(message: failure.message, code: failure.code!)),
      (comment) {
        _currentComments = [comment, ..._currentComments];
        emit(CommentsLoaded(comments: _currentComments, postId: event.postId));
      },
    );
  }

  Future<void> _onReplyToComment(
    ReplyToCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (state is CommentsLoaded) {
      emit(CommentAdding(currentComments: _currentComments));
    }

    final result = await replyToCommentUseCase(
      ReplyToCommentParams(
        postId: event.postId,
        parentCommentId: event.parentCommentId,
        authorId: event.authorId,
        content: event.content,
        parentDepth: event.parentDepth,
      ),
    );

    result.fold(
      (failure) =>
          emit(CommentError(message: failure.message, code: failure.code!)),
      (reply) {
        final updatedComments = _insertReplyAfterParent(
          _currentComments,
          event.parentCommentId,
          reply,
        );
        _currentComments = updatedComments;
        emit(CommentsLoaded(comments: updatedComments, postId: event.postId));
      },
    );
  }

  Future<void> _onVoteComment(
    VoteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      final updatedComments = _updateCommentVoteOptimistically(
        currentState.comments,
        event.commentId,
        event.voteType,
      );

      emit(currentState.copyWith(comments: updatedComments));
    }

    final result = await voteCommentUseCase(
      VoteCommentParams(
        postId: event.postId,
        commentId: event.commentId,
        userId: event.userId,
        voteType: event.voteType,
      ),
    );

    result.fold(
      (failure) {
        if (state is CommentsLoaded) {
          final currentState = state as CommentsLoaded;
          emit(currentState.copyWith(comments: _currentComments));
        }
      },
      (_) {
        if (state is CommentsLoaded) {
          final currentState = state as CommentsLoaded;
          _currentComments = currentState.comments;
        }
      },
    );
  }

  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    _currentComments = _currentComments
        .where((comment) => comment.id != event.commentId)
        .toList();

    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      emit(currentState.copyWith(comments: _currentComments));
    }
  }

  List<CommentEntity> _insertReplyAfterParent(
    List<CommentEntity> comments,
    String parentId,
    CommentEntity reply,
  ) {
    final result = <CommentEntity>[];
    for (final comment in comments) {
      result.add(comment);
      if (comment.id == parentId) {
        result.add(reply);
      }
    }
    return result;
  }

  List<CommentEntity> _updateCommentVoteOptimistically(
    List<CommentEntity> comments,
    String commentId,
    String voteType,
  ) {
    return comments.map((comment) {
      if (comment.id != commentId) return comment;

      int upvotes = comment.upvotes;
      int downvotes = comment.downvotes;
      VoteType newUserVote = VoteType.none;

      if (comment.userVote == VoteType.up) {
        upvotes--;
      } else if (comment.userVote == VoteType.down) {
        downvotes--;
      }

      if (voteType == 'up') {
        upvotes++;
        newUserVote = VoteType.up;
      } else if (voteType == 'down') {
        downvotes++;
        newUserVote = VoteType.down;
      }

      return CommentEntity(
        id: comment.id,
        postId: comment.postId,
        parentCommentId: comment.parentCommentId,
        authorId: comment.authorId,
        content: comment.content,
        upvotes: upvotes,
        downvotes: downvotes,
        userVote: newUserVote,
        replyCount: comment.replyCount,
        depth: comment.depth,
        createdAt: comment.createdAt,
        updatedAt: comment.updatedAt,
        edited: comment.edited,
      );
    }).toList();
  }

  void _onSubscribeToComments(
    SubscribeToComments event,
    Emitter<CommentState> emit,
  ) {
    _commentsSubscription?.cancel();

    _currentPostId = event.postId;

    _commentsSubscription =
        watchPostCommentsUseCase(
          WatchPostCommentsParams(
            postId: event.postId,
            currentUserId: event.currentUserId,
          ),
        ).listen((result) {
          result.fold((failure) {}, (comments) {
            add(CommentsUpdated(comments: comments, postId: _currentPostId));
          });
        }, onError: (error) {});
  }

  void _onCommentsUpdated(CommentsUpdated event, Emitter<CommentState> emit) {
    _currentComments = event.comments;

    if (event.comments.isEmpty) {
      emit(CommentsEmpty(postId: event.postId));
    } else {
      emit(CommentsLoaded(comments: event.comments, postId: event.postId));
    }
  }
}

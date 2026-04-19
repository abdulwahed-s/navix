import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/vote_post_usecase.dart';
import '../../domain/usecases/watch_posts_usecase.dart';

part 'community_feed_event.dart';
part 'community_feed_state.dart';

class CommunityFeedBloc extends Bloc<CommunityFeedEvent, CommunityFeedState> {
  final GetPostsUseCase getPostsUseCase;
  final VotePostUseCase votePostUseCase;
  final WatchPostsUseCase watchPostsUseCase;
  final CommunityRepository repository;

  List<PostEntity> _currentPosts = [];
  StreamSubscription? _postsSubscription;
  PostSortType _currentSortType = PostSortType.hot;

  CommunityFeedBloc({
    required this.getPostsUseCase,
    required this.votePostUseCase,
    required this.watchPostsUseCase,
    required this.repository,
  }) : super(const FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<ChangeSortType>(_onChangeSortType);
    on<VotePostInFeed>(_onVotePostInFeed);
    on<SubscribeToFeed>(_onSubscribeToFeed);
    on<PostsUpdated>(_onPostsUpdated);
    on<OptimisticDeletePost>(_onOptimisticDeletePost);
    on<OptimisticUpdatePost>(_onOptimisticUpdatePost);
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadFeed(
    LoadFeed event,
    Emitter<CommunityFeedState> emit,
  ) async {
    emit(const FeedLoading());

    repository.resetPagination();
    _currentPosts = [];

    final result = await getPostsUseCase(
      GetPostsParams(
        sortType: event.sortType,
        limit: 20,
        currentUserId: event.currentUserId,
      ),
    );

    result.fold(
      (failure) => emit(
        FeedError(message: failure.message, code: failure.code ?? 'null'),
      ),
      (posts) {
        _currentPosts = posts;
        if (posts.isEmpty) {
          emit(FeedEmpty(sortType: event.sortType));
        } else {
          emit(
            FeedLoaded(
              posts: posts,
              sortType: event.sortType,
              hasMore: posts.length >= 20,
              lastDocument: repository.lastPostDocument,
            ),
          );
        }

        add(
          SubscribeToFeed(
            sortType: event.sortType,
            currentUserId: event.currentUserId,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<CommunityFeedState> emit,
  ) async {
    repository.resetPagination();
    _currentPosts = [];

    final result = await getPostsUseCase(
      GetPostsParams(
        sortType: event.sortType,
        limit: 20,
        currentUserId: event.currentUserId,
      ),
    );

    result.fold(
      (failure) => emit(
        FeedError(message: failure.message, code: failure.code ?? 'null'),
      ),
      (posts) {
        _currentPosts = posts;
        if (posts.isEmpty) {
          emit(FeedEmpty(sortType: event.sortType));
        } else {
          emit(
            FeedLoaded(
              posts: posts,
              sortType: event.sortType,
              hasMore: posts.length >= 20,
              lastDocument: repository.lastPostDocument,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<CommunityFeedState> emit,
  ) async {
    if (state is! FeedLoaded) return;

    final currentState = state as FeedLoaded;
    if (!currentState.hasMore) return;

    emit(
      FeedLoadingMore(currentPosts: _currentPosts, sortType: event.sortType),
    );

    final result = await getPostsUseCase(
      GetPostsParams(
        sortType: event.sortType,
        limit: 20,
        lastDocument: repository.lastPostDocument,
        currentUserId: event.currentUserId,
      ),
    );

    result.fold(
      (failure) => emit(
        FeedError(message: failure.message, code: failure.code ?? 'null'),
      ),
      (newPosts) {
        _currentPosts = [..._currentPosts, ...newPosts];
        emit(
          FeedLoaded(
            posts: _currentPosts,
            sortType: event.sortType,
            hasMore: newPosts.length >= 20,
            lastDocument: repository.lastPostDocument,
          ),
        );
      },
    );
  }

  Future<void> _onChangeSortType(
    ChangeSortType event,
    Emitter<CommunityFeedState> emit,
  ) async {
    emit(const FeedLoading());

    repository.resetPagination();
    _currentPosts = [];

    final result = await getPostsUseCase(
      GetPostsParams(
        sortType: event.sortType,
        limit: 20,
        currentUserId: event.currentUserId,
      ),
    );

    result.fold(
      (failure) => emit(
        FeedError(message: failure.message, code: failure.code ?? 'null'),
      ),
      (posts) {
        _currentPosts = posts;
        if (posts.isEmpty) {
          emit(FeedEmpty(sortType: event.sortType));
        } else {
          emit(
            FeedLoaded(
              posts: posts,
              sortType: event.sortType,
              hasMore: posts.length >= 20,
              lastDocument: repository.lastPostDocument,
            ),
          );
        }

        add(
          SubscribeToFeed(
            sortType: event.sortType,
            currentUserId: event.currentUserId,
          ),
        );
      },
    );
  }

  Future<void> _onVotePostInFeed(
    VotePostInFeed event,
    Emitter<CommunityFeedState> emit,
  ) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = _updatePostVoteOptimistically(
        currentState.posts,
        event.postId,
        event.voteType,
      );

      emit(currentState.copyWith(posts: updatedPosts));
    }

    final result = await votePostUseCase(
      VotePostParams(
        postId: event.postId,
        userId: event.userId,
        voteType: event.voteType,
      ),
    );

    result.fold(
      (failure) {
        if (state is FeedLoaded) {
          final currentState = state as FeedLoaded;
          emit(currentState.copyWith(posts: _currentPosts));
        }
      },
      (_) {
        if (state is FeedLoaded) {
          final currentState = state as FeedLoaded;
          _currentPosts = currentState.posts;
        }
      },
    );
  }

  List<PostEntity> _updatePostVoteOptimistically(
    List<PostEntity> posts,
    String postId,
    String voteType,
  ) {
    return posts.map((post) {
      if (post.id != postId) return post;

      int upvotes = post.upvotes;
      int downvotes = post.downvotes;
      VoteType newUserVote = VoteType.none;

      if (post.userVote == VoteType.up) {
        upvotes--;
      } else if (post.userVote == VoteType.down) {
        downvotes--;
      }

      if (voteType == 'up') {
        upvotes++;
        newUserVote = VoteType.up;
      } else if (voteType == 'down') {
        downvotes++;
        newUserVote = VoteType.down;
      }

      return PostEntity(
        id: post.id,
        authorId: post.authorId,
        title: post.title,
        content: post.content,
        imageUrl: post.imageUrl,
        postType: post.postType,
        upvotes: upvotes,
        downvotes: downvotes,
        userVote: newUserVote,
        commentCount: post.commentCount,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        edited: post.edited,
      );
    }).toList();
  }

  void _onSubscribeToFeed(
    SubscribeToFeed event,
    Emitter<CommunityFeedState> emit,
  ) {
    _postsSubscription?.cancel();

    _currentSortType = event.sortType;

    _postsSubscription =
        watchPostsUseCase(
          WatchPostsParams(
            sortType: event.sortType,
            limit: 20,
            currentUserId: event.currentUserId,
          ),
        ).listen((result) {
          result.fold(
            (failure) {
              if (state is! FeedError) {
                add(
                  PostsUpdated(
                    posts: _currentPosts,
                    sortType: _currentSortType,
                  ),
                );
              }
            },
            (posts) {
              add(PostsUpdated(posts: posts, sortType: _currentSortType));
            },
          );
        }, onError: (error) {});
  }

  void _onPostsUpdated(PostsUpdated event, Emitter<CommunityFeedState> emit) {
    _currentPosts = event.posts;

    if (event.posts.isEmpty) {
      emit(FeedEmpty(sortType: event.sortType));
    } else {
      emit(
        FeedLoaded(
          posts: event.posts,
          sortType: event.sortType,
          hasMore: event.posts.length >= 20,
          lastDocument: repository.lastPostDocument,
        ),
      );
    }
  }

  void _onOptimisticDeletePost(
    OptimisticDeletePost event,
    Emitter<CommunityFeedState> emit,
  ) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = _currentPosts
          .where((post) => post.id != event.postId)
          .toList();
      _currentPosts = updatedPosts;

      if (updatedPosts.isEmpty) {
        emit(FeedEmpty(sortType: currentState.sortType));
      } else {
        emit(currentState.copyWith(posts: updatedPosts));
      }
    }
  }

  void _onOptimisticUpdatePost(
    OptimisticUpdatePost event,
    Emitter<CommunityFeedState> emit,
  ) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = _currentPosts.map((post) {
        if (post.id != event.postId) return post;
        return PostEntity(
          id: post.id,
          authorId: post.authorId,
          title: event.title,
          content: event.content,
          imageUrl: post.imageUrl,
          postType: post.postType,
          upvotes: post.upvotes,
          downvotes: post.downvotes,
          userVote: post.userVote,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: DateTime.now(),
          edited: true,
        );
      }).toList();
      _currentPosts = updatedPosts;
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }
}

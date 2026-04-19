part of 'community_feed_bloc.dart';

abstract class CommunityFeedState extends Equatable {
  const CommunityFeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends CommunityFeedState {
  const FeedInitial();
}

class FeedLoading extends CommunityFeedState {
  const FeedLoading();
}

class FeedLoaded extends CommunityFeedState {
  final List<PostEntity> posts;
  final PostSortType sortType;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  const FeedLoaded({
    required this.posts,
    required this.sortType,
    this.hasMore = true,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [posts, sortType, hasMore, lastDocument];

  FeedLoaded copyWith({
    List<PostEntity>? posts,
    PostSortType? sortType,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      sortType: sortType ?? this.sortType,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

class FeedLoadingMore extends CommunityFeedState {
  final List<PostEntity> currentPosts;
  final PostSortType sortType;

  const FeedLoadingMore({required this.currentPosts, required this.sortType});

  @override
  List<Object?> get props => [currentPosts, sortType];
}

class FeedError extends CommunityFeedState {
  final String message;
  final String code;

  const FeedError({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}

class FeedEmpty extends CommunityFeedState {
  final PostSortType sortType;

  const FeedEmpty({required this.sortType});

  @override
  List<Object?> get props => [sortType];
}

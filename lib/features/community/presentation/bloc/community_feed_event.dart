part of 'community_feed_bloc.dart';

abstract class CommunityFeedEvent extends Equatable {
  const CommunityFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeed extends CommunityFeedEvent {
  final PostSortType sortType;
  final String currentUserId;

  const LoadFeed({required this.sortType, required this.currentUserId});

  @override
  List<Object?> get props => [sortType, currentUserId];
}

class RefreshFeed extends CommunityFeedEvent {
  final PostSortType sortType;
  final String currentUserId;

  const RefreshFeed({required this.sortType, required this.currentUserId});

  @override
  List<Object?> get props => [sortType, currentUserId];
}

class LoadMorePosts extends CommunityFeedEvent {
  final PostSortType sortType;
  final String currentUserId;

  const LoadMorePosts({required this.sortType, required this.currentUserId});

  @override
  List<Object?> get props => [sortType, currentUserId];
}

class ChangeSortType extends CommunityFeedEvent {
  final PostSortType sortType;
  final String currentUserId;

  const ChangeSortType({required this.sortType, required this.currentUserId});

  @override
  List<Object?> get props => [sortType, currentUserId];
}

class VotePostInFeed extends CommunityFeedEvent {
  final String postId;
  final String userId;
  final String voteType;

  const VotePostInFeed({
    required this.postId,
    required this.userId,
    required this.voteType,
  });

  @override
  List<Object?> get props => [postId, userId, voteType];
}

class SubscribeToFeed extends CommunityFeedEvent {
  final PostSortType sortType;
  final String currentUserId;

  const SubscribeToFeed({required this.sortType, required this.currentUserId});

  @override
  List<Object?> get props => [sortType, currentUserId];
}

class PostsUpdated extends CommunityFeedEvent {
  final List<PostEntity> posts;
  final PostSortType sortType;

  const PostsUpdated({required this.posts, required this.sortType});

  @override
  List<Object?> get props => [posts, sortType];
}

class OptimisticDeletePost extends CommunityFeedEvent {
  final String postId;

  const OptimisticDeletePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class OptimisticUpdatePost extends CommunityFeedEvent {
  final String postId;
  final String title;
  final String content;

  const OptimisticUpdatePost({
    required this.postId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, title, content];
}

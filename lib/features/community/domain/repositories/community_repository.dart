import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../entities/post_entity.dart';

enum PostSortType { hot, latest, top }

abstract class CommunityRepository {
  Future<Either<Failure, PostEntity>> createPost({
    required String authorId,
    required String title,
    required String content,
    String? imageUrl,
    required PostType postType,
    String? surveyId,
    String? surveyProjectId,
  });

  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    required String title,
    required String content,
  });

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, List<PostEntity>>> getPosts({
    required PostSortType sortType,
    required int limit,
    DocumentSnapshot? lastDocument,
    required String currentUserId,
  });

  Future<Either<Failure, PostEntity>> getPost({
    required String postId,
    required String currentUserId,
  });

  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 20,
  });

  DocumentSnapshot? get lastPostDocument;

  void resetPagination();

  Future<Either<Failure, String>> uploadPostImage({
    required String postId,
    required String imagePath,
  });

  Future<Either<Failure, void>> votePost({
    required String postId,
    required String userId,
    required String voteType,
  });

  Future<Either<Failure, void>> voteComment({
    required String postId,
    required String commentId,
    required String userId,
    required String voteType,
  });

  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String authorId,
    required String content,
  });

  Future<Either<Failure, CommentEntity>> replyToComment({
    required String postId,
    required String parentCommentId,
    required String authorId,
    required String content,
    required int parentDepth,
  });

  Future<Either<Failure, List<CommentEntity>>> getPostComments({
    required String postId,
    required String currentUserId,
  });

  Future<Either<Failure, CommentEntity>> updateComment({
    required String postId,
    required String commentId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  });

  Future<Either<Failure, void>> reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
    required String reason,
    String? description,
  });

  Stream<Either<Failure, List<PostEntity>>> watchPosts({
    required PostSortType sortType,
    required int limit,
    required String currentUserId,
  });

  Stream<Either<Failure, List<CommentEntity>>> watchPostComments({
    required String postId,
    required String currentUserId,
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CommunityRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  DocumentSnapshot? get lastPostDocument => remoteDataSource.lastPostDocument;

  @override
  void resetPagination() => remoteDataSource.resetPagination();

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String authorId,
    required String title,
    required String content,
    String? imageUrl,
    required PostType postType,
    String? surveyId,
    String? surveyProjectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final post = await remoteDataSource.createPost(
        authorId: authorId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        postType: postType,
        surveyId: surveyId,
        surveyProjectId: surveyProjectId,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final post = await remoteDataSource.updatePost(
        postId: postId,
        title: title,
        content: content,
      );
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    required PostSortType sortType,
    required int limit,
    DocumentSnapshot? lastDocument,
    required String currentUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final posts = await remoteDataSource.getPosts(
        sortType: sortType,
        limit: limit,
        lastDocument: lastDocument,
        currentUserId: currentUserId,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPost({
    required String postId,
    required String currentUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final post = await remoteDataSource.getPost(
        postId: postId,
        currentUserId: currentUserId,
      );
      if (post == null) {
        return const Left(
          ServerFailure(message: 'Post not found', code: 'not-found'),
        );
      }
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final posts = await remoteDataSource.getUserPosts(
        userId: userId,
        currentUserId: currentUserId,
        limit: limit,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadPostImage({
    required String postId,
    required String imagePath,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final imageUrl = await remoteDataSource.uploadPostImage(
        postId: postId,
        imagePath: imagePath,
      );
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> votePost({
    required String postId,
    required String userId,
    required String voteType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.votePost(
        postId: postId,
        userId: userId,
        voteType: voteType,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> voteComment({
    required String postId,
    required String commentId,
    required String userId,
    required String voteType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.voteComment(
        postId: postId,
        commentId: commentId,
        userId: userId,
        voteType: voteType,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final comment = await remoteDataSource.addComment(
        postId: postId,
        authorId: authorId,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> replyToComment({
    required String postId,
    required String parentCommentId,
    required String authorId,
    required String content,
    required int parentDepth,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final comment = await remoteDataSource.replyToComment(
        postId: postId,
        parentCommentId: parentCommentId,
        authorId: authorId,
        content: content,
        parentDepth: parentDepth,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getPostComments({
    required String postId,
    required String currentUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final comments = await remoteDataSource.getPostComments(
        postId: postId,
        currentUserId: currentUserId,
      );
      return Right(comments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final comment = await remoteDataSource.updateComment(
        postId: postId,
        commentId: commentId,
        content: content,
      );
      return Right(comment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.reportPost(
        postId: postId,
        reporterId: reporterId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await remoteDataSource.reportComment(
        postId: postId,
        commentId: commentId,
        reporterId: reporterId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'An unexpected error occurred',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<PostEntity>>> watchPosts({
    required PostSortType sortType,
    required int limit,
    required String currentUserId,
  }) {
    return remoteDataSource
        .watchPosts(
          sortType: sortType,
          limit: limit,
          currentUserId: currentUserId,
        )
        .map<Either<Failure, List<PostEntity>>>((posts) => Right(posts))
        .handleError(
          (error) => Left(
            ServerFailure(message: error.toString(), code: 'stream-error'),
          ),
        );
  }

  @override
  Stream<Either<Failure, List<CommentEntity>>> watchPostComments({
    required String postId,
    required String currentUserId,
  }) {
    return remoteDataSource
        .watchPostComments(postId: postId, currentUserId: currentUserId)
        .map<Either<Failure, List<CommentEntity>>>(
          (comments) => Right(comments),
        )
        .handleError(
          (error) => Left(
            ServerFailure(message: error.toString(), code: 'stream-error'),
          ),
        );
  }
}

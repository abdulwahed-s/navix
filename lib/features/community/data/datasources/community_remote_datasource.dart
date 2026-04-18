import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/helpers/comment_thread_helper.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

abstract class CommunityRemoteDataSource {
  Future<PostModel> createPost({
    required String authorId,
    required String title,
    required String content,
    String? imageUrl,
    required PostType postType,
    String? surveyId,
    String? surveyProjectId,
  });

  Future<PostModel> updatePost({
    required String postId,
    required String title,
    required String content,
  });

  Future<void> deletePost(String postId);

  Future<List<PostModel>> getPosts({
    required PostSortType sortType,
    required int limit,
    DocumentSnapshot? lastDocument,
    required String currentUserId,
  });

  Future<PostModel?> getPost({
    required String postId,
    required String currentUserId,
  });

  Future<List<PostModel>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 20,
  });

  DocumentSnapshot? get lastPostDocument;

  void resetPagination();

  Future<String> uploadPostImage({
    required String postId,
    required String imagePath,
  });

  Future<void> votePost({
    required String postId,
    required String userId,
    required String voteType,
  });

  Future<void> voteComment({
    required String postId,
    required String commentId,
    required String userId,
    required String voteType,
  });

  Future<CommentModel> addComment({
    required String postId,
    required String authorId,
    required String content,
  });

  Future<CommentModel> replyToComment({
    required String postId,
    required String parentCommentId,
    required String authorId,
    required String content,
    required int parentDepth,
  });

  Future<List<CommentModel>> getPostComments({
    required String postId,
    required String currentUserId,
  });

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
  });

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  });

  Future<void> reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
    required String reason,
    String? description,
  });

  Stream<List<PostModel>> watchPosts({
    required PostSortType sortType,
    required int limit,
    required String currentUserId,
  });

  Stream<List<CommentModel>> watchPostComments({
    required String postId,
    required String currentUserId,
  });
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  DocumentSnapshot? _lastPostDocument;

  @override
  DocumentSnapshot? get lastPostDocument => _lastPostDocument;

  @override
  void resetPagination() {
    _lastPostDocument = null;
  }

  CommunityRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  CollectionReference get _postsCollection => firestore.collection('posts');
  CollectionReference get _reportsCollection => firestore.collection('reports');

  @override
  Future<PostModel> createPost({
    required String authorId,
    required String title,
    required String content,
    String? imageUrl,
    required PostType postType,
    String? surveyId,
    String? surveyProjectId,
  }) async {
    try {
      final postRef = _postsCollection.doc();
      final now = DateTime.now();

      final post = PostModel(
        id: postRef.id,
        authorId: authorId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        postType: postType,
        upvotes: 0,
        downvotes: 0,
        userVote: VoteType.none,
        commentCount: 0,
        createdAt: now,
        updatedAt: now,
        edited: false,
        surveyId: surveyId,
        surveyProjectId: surveyProjectId,
      );

      await postRef.set(post.toJson());
      return post;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to create post: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred',
        code: e.toString(),
      );
    }
  }

  @override
  Future<PostModel> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    try {
      final postDoc = await _postsCollection.doc(postId).get();
      if (!postDoc.exists) {
        throw ServerException(
          message: 'Post not found',
          code: 'post-not-found',
        );
      }

      await _postsCollection.doc(postId).update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.now(),
        'edited': true,
      });

      final currentUserId =
          (postDoc.data() as Map<String, dynamic>)['authorId'] as String;
      final userVote = await _getUserVoteForPost(postId, currentUserId);

      return PostModel.fromFirestore(
        await _postsCollection.doc(postId).get(),
        userVote,
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update post: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();

      try {
        final imageRef = storage.ref().child('community/posts/$postId/image');
        await imageRef.delete();
      } catch (e) {}
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete post: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<PostModel>> getPosts({
    required PostSortType sortType,
    required int limit,
    DocumentSnapshot? lastDocument,
    required String currentUserId,
  }) async {
    try {
      Query query = _postsCollection;

      switch (sortType) {
        case PostSortType.hot:
          query = query.orderBy('voteScore', descending: true);
          break;
        case PostSortType.latest:
          query = query.orderBy('createdAt', descending: true);
          break;
        case PostSortType.top:
          query = query.orderBy('upvotes', descending: true);
          break;
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastPostDocument = snapshot.docs.last;
      }

      final posts = <PostModel>[];
      for (final doc in snapshot.docs) {
        final userVote = await _getUserVoteForPost(doc.id, currentUserId);
        posts.add(PostModel.fromFirestore(doc, userVote));
      }

      return posts;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get posts: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<PostModel?> getPost({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;

      final userVote = await _getUserVoteForPost(postId, currentUserId);
      return PostModel.fromFirestore(doc, userVote);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get post: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<PostModel>> getUserPosts({
    required String userId,
    required String currentUserId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _postsCollection
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final posts = <PostModel>[];
      for (final doc in snapshot.docs) {
        final userVote = await _getUserVoteForPost(doc.id, currentUserId);
        posts.add(PostModel.fromFirestore(doc, userVote));
      }

      return posts;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get user posts: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<String> uploadPostImage({
    required String postId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      final ref = storage.ref().child('community/posts/$postId/image');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to upload image: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to upload image',
        code: e.toString(),
      );
    }
  }

  @override
  Future<void> votePost({
    required String postId,
    required String userId,
    required String voteType,
  }) async {
    try {
      final voteRef = _postsCollection
          .doc(postId)
          .collection('votes')
          .doc(userId);

      if (voteType == 'none') {
        await voteRef.delete();
      } else {
        await voteRef.set({'voteType': voteType, 'createdAt': Timestamp.now()});
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to vote on post: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> voteComment({
    required String postId,
    required String commentId,
    required String userId,
    required String voteType,
  }) async {
    try {
      final voteRef = _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('votes')
          .doc(userId);

      if (voteType == 'none') {
        await voteRef.delete();
      } else {
        await voteRef.set({'voteType': voteType, 'createdAt': Timestamp.now()});
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to vote on comment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      final commentRef = _postsCollection
          .doc(postId)
          .collection('comments')
          .doc();
      final now = DateTime.now();

      final comment = CommentModel(
        id: commentRef.id,
        postId: postId,
        parentCommentId: null,
        authorId: authorId,
        content: content,
        upvotes: 0,
        downvotes: 0,
        userVote: VoteType.none,
        replyCount: 0,
        depth: 0,
        createdAt: now,
        updatedAt: now,
        edited: false,
      );

      await commentRef.set(comment.toJson());

      return comment;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to add comment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<CommentModel> replyToComment({
    required String postId,
    required String parentCommentId,
    required String authorId,
    required String content,
    required int parentDepth,
  }) async {
    try {
      final commentRef = _postsCollection
          .doc(postId)
          .collection('comments')
          .doc();
      final now = DateTime.now();

      final comment = CommentModel(
        id: commentRef.id,
        postId: postId,
        parentCommentId: parentCommentId,
        authorId: authorId,
        content: content,
        upvotes: 0,
        downvotes: 0,
        userVote: VoteType.none,
        replyCount: 0,
        depth: parentDepth + 1,
        createdAt: now,
        updatedAt: now,
        edited: false,
      );

      await commentRef.set(comment.toJson());

      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(parentCommentId)
          .update({'replyCount': FieldValue.increment(1)});

      return comment;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to reply to comment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<CommentModel>> getPostComments({
    required String postId,
    required String currentUserId,
  }) async {
    try {
      final snapshot = await _postsCollection
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      final comments = <CommentModel>[];
      for (final doc in snapshot.docs) {
        final userVote = await _getUserVoteForComment(
          postId,
          doc.id,
          currentUserId,
        );
        comments.add(CommentModel.fromFirestore(doc, postId, userVote));
      }

      return CommentThreadHelper.sortThreaded(comments).cast<CommentModel>();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get comments: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'content': content,
            'updatedAt': Timestamp.now(),
            'edited': true,
          });

      final doc = await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .get();

      final authorId =
          (doc.data() as Map<String, dynamic>)['authorId'] as String;
      final userVote = await _getUserVoteForComment(
        postId,
        commentId,
        authorId,
      );

      return CommentModel.fromFirestore(doc, postId, userVote);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update comment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to delete comment: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    try {
      final reportRef = _reportsCollection.doc();
      await reportRef.set({
        'targetId': postId,
        'targetType': 'post',
        'reporterId': reporterId,
        'reason': reason,
        'description': description,
        'createdAt': Timestamp.now(),
        'status': 'pending',
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to report post: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
    required String reason,
    String? description,
  }) async {
    try {
      final reportRef = _reportsCollection.doc();
      await reportRef.set({
        'targetId': commentId,
        'targetType': 'comment',
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'description': description,
        'createdAt': Timestamp.now(),
        'status': 'pending',
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to report comment: ${e.message}',
        code: e.code,
      );
    }
  }

  Future<VoteType> _getUserVoteForPost(String postId, String userId) async {
    try {
      final voteDoc = await _postsCollection
          .doc(postId)
          .collection('votes')
          .doc(userId)
          .get();

      if (!voteDoc.exists) return VoteType.none;

      final voteType =
          (voteDoc.data() as Map<String, dynamic>)['voteType'] as String?;
      if (voteType == 'up') return VoteType.up;
      if (voteType == 'down') return VoteType.down;
      return VoteType.none;
    } catch (e) {
      return VoteType.none;
    }
  }

  Future<VoteType> _getUserVoteForComment(
    String postId,
    String commentId,
    String userId,
  ) async {
    try {
      final voteDoc = await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('votes')
          .doc(userId)
          .get();

      if (!voteDoc.exists) return VoteType.none;

      final voteType =
          (voteDoc.data() as Map<String, dynamic>)['voteType'] as String?;
      if (voteType == 'up') return VoteType.up;
      if (voteType == 'down') return VoteType.down;
      return VoteType.none;
    } catch (e) {
      return VoteType.none;
    }
  }

  @override
  Stream<List<PostModel>> watchPosts({
    required PostSortType sortType,
    required int limit,
    required String currentUserId,
  }) {
    Query query = _postsCollection;

    switch (sortType) {
      case PostSortType.hot:
        query = query.orderBy('voteScore', descending: true);
        break;
      case PostSortType.latest:
        query = query.orderBy('createdAt', descending: true);
        break;
      case PostSortType.top:
        query = query.orderBy('upvotes', descending: true);
        break;
    }

    query = query.limit(limit);

    return query.snapshots().asyncMap((snapshot) async {
      final posts = <PostModel>[];
      for (final doc in snapshot.docs) {
        final userVote = await _getUserVoteForPost(doc.id, currentUserId);
        posts.add(PostModel.fromFirestore(doc, userVote));
      }
      return posts;
    });
  }

  @override
  Stream<List<CommentModel>> watchPostComments({
    required String postId,
    required String currentUserId,
  }) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final comments = <CommentModel>[];
          for (final doc in snapshot.docs) {
            final userVote = await _getUserVoteForComment(
              postId,
              doc.id,
              currentUserId,
            );
            comments.add(CommentModel.fromFirestore(doc, postId, userVote));
          }

          return CommentThreadHelper.sortThreaded(
            comments,
          ).cast<CommentModel>();
        });
  }
}

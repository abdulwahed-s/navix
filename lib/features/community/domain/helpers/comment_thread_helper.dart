import '../entities/comment_entity.dart';

class CommentThreadHelper {
  static List<CommentEntity> sortThreaded(List<CommentEntity> comments) {
    if (comments.isEmpty) return [];

    final topLevel = <CommentEntity>[];
    final repliesByParent = <String, List<CommentEntity>>{};

    for (final comment in comments) {
      if (comment.parentCommentId == null) {
        topLevel.add(comment);
      } else {
        repliesByParent
            .putIfAbsent(comment.parentCommentId!, () => [])
            .add(comment);
      }
    }

    topLevel.sort(_compareByVoteScore);

    for (final replies in repliesByParent.values) {
      replies.sort(_compareByVoteScore);
    }

    final result = <CommentEntity>[];
    for (final comment in topLevel) {
      _addCommentWithReplies(comment, repliesByParent, result);
    }

    return result;
  }

  static int _compareByVoteScore(CommentEntity a, CommentEntity b) {
    final scoreCompare = b.voteScore.compareTo(a.voteScore);
    if (scoreCompare != 0) return scoreCompare;

    return a.createdAt.compareTo(b.createdAt);
  }

  static void _addCommentWithReplies(
    CommentEntity comment,
    Map<String, List<CommentEntity>> repliesByParent,
    List<CommentEntity> result,
  ) {
    result.add(comment);

    final replies = repliesByParent[comment.id];
    if (replies != null) {
      for (final reply in replies) {
        _addCommentWithReplies(reply, repliesByParent, result);
      }
    }
  }
}

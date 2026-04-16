import 'package:equatable/equatable.dart';

enum PostType { text, textWithImage, survey }

enum VoteType { none, up, down }

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? imageUrl;
  final PostType postType;
  final int upvotes;
  final int downvotes;
  final VoteType userVote;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool edited;

  final String? surveyId;
  final String? surveyProjectId;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.postType,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVote = VoteType.none,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.edited = false,
    this.surveyId,
    this.surveyProjectId,
  });

  int get voteScore => upvotes - downvotes;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get isSurveyPost => postType == PostType.survey && surveyId != null;

  @override
  List<Object?> get props => [
    id,
    authorId,
    title,
    content,
    imageUrl,
    postType,
    upvotes,
    downvotes,
    userVote,
    commentCount,
    createdAt,
    updatedAt,
    edited,
    surveyId,
    surveyProjectId,
  ];
}

import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, sharedPost, sharedSurvey }

class SharedPostData extends Equatable {
  final String postId;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorId;

  const SharedPostData({
    required this.postId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorId,
  });

  factory SharedPostData.fromMap(Map<String, dynamic> map) {
    return SharedPostData(
      postId: map['postId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      authorId: map['authorId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorId': authorId,
    };
  }

  @override
  List<Object?> get props => [postId, title, content, imageUrl, authorId];
}

class SharedSurveyData extends Equatable {
  final String surveyId;
  final String projectId;
  final String title;
  final String description;
  final int questionCount;

  const SharedSurveyData({
    required this.surveyId,
    required this.projectId,
    required this.title,
    required this.description,
    this.questionCount = 0,
  });

  factory SharedSurveyData.fromMap(Map<String, dynamic> map) {
    return SharedSurveyData(
      surveyId: map['surveyId'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      questionCount: (map['questionCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surveyId': surveyId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'questionCount': questionCount,
    };
  }

  @override
  List<Object?> get props => [
    surveyId,
    projectId,
    title,
    description,
    questionCount,
  ];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final SharedPostData? sharedPost;
  final SharedSurveyData? sharedSurvey;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.sharedPost,
    this.sharedSurvey,
  });

  bool isMine(String currentUserId) => senderId == currentUserId;

  bool get isSharedPost => type == MessageType.sharedPost && sharedPost != null;

  bool get isSharedSurvey =>
      type == MessageType.sharedSurvey && sharedSurvey != null;

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderName,
    text,
    timestamp,
    status,
    type,
    sharedPost,
    sharedSurvey,
  ];
}

part of 'create_post_bloc.dart';

abstract class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

class ImageSelected extends CreatePostEvent {
  final String imagePath;

  const ImageSelected({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ImageRemoved extends CreatePostEvent {
  const ImageRemoved();
}

class ValidatePost extends CreatePostEvent {
  final String title;
  final String content;

  const ValidatePost({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class CreatePostSubmitted extends CreatePostEvent {
  final String authorId;
  final String title;
  final String content;
  final String? imagePath;
  final String? surveyId;
  final String? surveyProjectId;

  const CreatePostSubmitted({
    required this.authorId,
    required this.title,
    required this.content,
    this.imagePath,
    this.surveyId,
    this.surveyProjectId,
  });

  bool get isSurveyPost => surveyId != null && surveyProjectId != null;

  @override
  List<Object?> get props => [
    authorId,
    title,
    content,
    imagePath,
    surveyId,
    surveyProjectId,
  ];
}

class ResetCreatePost extends CreatePostEvent {
  const ResetCreatePost();
}

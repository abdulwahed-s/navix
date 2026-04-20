part of 'create_post_bloc.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

class CreatePostInitial extends CreatePostState {
  const CreatePostInitial();
}

class CreatePostValid extends CreatePostState {
  final String? selectedImagePath;

  const CreatePostValid({this.selectedImagePath});

  @override
  List<Object?> get props => [selectedImagePath];
}

class CreatePostInvalid extends CreatePostState {
  final String? titleError;
  final String? contentError;
  final String? selectedImagePath;

  const CreatePostInvalid({
    this.titleError,
    this.contentError,
    this.selectedImagePath,
  });

  @override
  List<Object?> get props => [titleError, contentError, selectedImagePath];
}

class CreatePostUploadingImage extends CreatePostState {
  final double progress;

  const CreatePostUploadingImage({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class CreatePostUploading extends CreatePostState {
  const CreatePostUploading();
}

class CreatePostSuccess extends CreatePostState {
  final PostEntity post;

  const CreatePostSuccess({required this.post});

  @override
  List<Object?> get props => [post];
}

class CreatePostError extends CreatePostState {
  final String message;
  final String code;

  const CreatePostError({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}

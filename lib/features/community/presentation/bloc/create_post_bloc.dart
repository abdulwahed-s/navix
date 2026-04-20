import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/upload_post_image_usecase.dart';

part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUseCase createPostUseCase;
  final UploadPostImageUseCase uploadPostImageUseCase;

  String? _selectedImagePath;

  CreatePostBloc({
    required this.createPostUseCase,
    required this.uploadPostImageUseCase,
  }) : super(const CreatePostInitial()) {
    on<ImageSelected>(_onImageSelected);
    on<ImageRemoved>(_onImageRemoved);
    on<ValidatePost>(_onValidatePost);
    on<CreatePostSubmitted>(_onCreatePostSubmitted);
    on<ResetCreatePost>(_onResetCreatePost);
  }

  void _onImageSelected(ImageSelected event, Emitter<CreatePostState> emit) {
    _selectedImagePath = event.imagePath;
    emit(CreatePostValid(selectedImagePath: _selectedImagePath));
  }

  void _onImageRemoved(ImageRemoved event, Emitter<CreatePostState> emit) {
    _selectedImagePath = null;
    emit(const CreatePostValid());
  }

  void _onValidatePost(ValidatePost event, Emitter<CreatePostState> emit) {
    String? titleError;
    String? contentError;

    if (event.title.trim().isEmpty) {
      titleError = 'Title is required';
    } else if (event.title.trim().length < 10) {
      titleError = 'Title must be at least 10 characters';
    } else if (event.title.trim().length > 300) {
      titleError = 'Title must be less than 300 characters';
    }

    if (event.content.trim().isEmpty) {
      contentError = 'Content is required';
    } else if (event.content.trim().length > 10000) {
      contentError = 'Content must be less than 10,000 characters';
    }

    if (titleError != null || contentError != null) {
      emit(
        CreatePostInvalid(
          titleError: titleError,
          contentError: contentError,
          selectedImagePath: _selectedImagePath,
        ),
      );
    } else {
      emit(CreatePostValid(selectedImagePath: _selectedImagePath));
    }
  }

  Future<void> _onCreatePostSubmitted(
    CreatePostSubmitted event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(const CreatePostUploading());

    String? imageUrl;

    if (event.imagePath != null && !event.isSurveyPost) {
      emit(const CreatePostUploadingImage(progress: 0.5));

      final tempPostId = DateTime.now().millisecondsSinceEpoch.toString();

      final uploadResult = await uploadPostImageUseCase(
        UploadPostImageParams(postId: tempPostId, imagePath: event.imagePath!),
      );

      final uploadFailed = uploadResult.fold(
        (failure) {
          emit(
            CreatePostError(
              message: failure.message,
              code: failure.code ?? 'null',
            ),
          );
          return true;
        },
        (url) {
          imageUrl = url;
          return false;
        },
      );

      if (uploadFailed) return;
    }

    PostType postType;
    if (event.isSurveyPost) {
      postType = PostType.survey;
    } else if (imageUrl != null) {
      postType = PostType.textWithImage;
    } else {
      postType = PostType.text;
    }

    final result = await createPostUseCase(
      CreatePostParams(
        authorId: event.authorId,
        title: event.title.trim(),
        content: event.content.trim(),
        imageUrl: imageUrl,
        postType: postType,
        surveyId: event.surveyId,
        surveyProjectId: event.surveyProjectId,
      ),
    );

    result.fold(
      (failure) => emit(
        CreatePostError(message: failure.message, code: failure.code ?? 'null'),
      ),
      (post) {
        print('CreatePostBloc: Emitting CreatePostSuccess for post ${post.id}');
        _selectedImagePath = null;
        emit(CreatePostSuccess(post: post));
        print('CreatePostBloc: CreatePostSuccess emitted');
      },
    );
  }

  void _onResetCreatePost(
    ResetCreatePost event,
    Emitter<CreatePostState> emit,
  ) {
    _selectedImagePath = null;
    emit(const CreatePostInitial());
  }
}

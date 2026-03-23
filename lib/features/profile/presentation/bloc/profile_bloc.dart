import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final CreateProfileUseCase createProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadProfilePictureUseCase uploadProfilePictureUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.createProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadProfilePictureUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
    on<UploadProfilePicture>(_onUploadProfilePicture);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading(message: 'Loading profile...'));

    final result = await getProfileUseCase(
      GetProfileParams(userId: event.userId),
    );

    result.fold(
      (failure) =>
          emit(ProfileError(message: failure.message, code: failure.code)),
      (profile) {
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileNotFound());
        }
      },
    );
  }

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSaving(message: 'Saving profile...'));

    final result = event.isNew
        ? await createProfileUseCase(event.profile)
        : await updateProfileUseCase(event.profile);

    result.fold(
      (failure) =>
          emit(ProfileError(message: failure.message, code: failure.code)),
      (profile) => emit(ProfileSaved(profile)),
    );
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfilePictureUploading());

    final result = await uploadProfilePictureUseCase(
      UploadProfilePictureParams(
        userId: event.userId,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) =>
          emit(ProfileError(message: failure.message, code: failure.code)),
      (imageUrl) => emit(ProfilePictureUploaded(imageUrl)),
    );
  }
}

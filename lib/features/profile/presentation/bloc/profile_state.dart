part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  final String? message;

  const ProfileLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileNotFound extends ProfileState {
  const ProfileNotFound();
}

class ProfileSaving extends ProfileState {
  final String? message;

  const ProfileSaving({this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileSaved extends ProfileState {
  final ProfileEntity profile;

  const ProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfilePictureUploading extends ProfileState {
  const ProfilePictureUploading();
}

class ProfilePictureUploaded extends ProfileState {
  final String imageUrl;

  const ProfilePictureUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ProfileError extends ProfileState {
  final String message;
  final String? code;

  const ProfileError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

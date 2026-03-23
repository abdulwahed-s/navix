part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SaveProfile extends ProfileEvent {
  final ProfileEntity profile;
  final bool isNew;

  const SaveProfile({required this.profile, required this.isNew});

  @override
  List<Object?> get props => [profile, isNew];
}

class UploadProfilePicture extends ProfileEvent {
  final String userId;
  final File imageFile;

  const UploadProfilePicture({required this.userId, required this.imageFile});

  @override
  List<Object?> get props => [userId, imageFile];
}

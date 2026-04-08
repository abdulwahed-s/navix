part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final String userId;

  const LoadSettings({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateNotificationPreference extends SettingsEvent {
  final String key;
  final bool value;

  const UpdateNotificationPreference({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class UpdatePrivacySetting extends SettingsEvent {
  final String key;
  final String value;

  const UpdatePrivacySetting({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class UpdateThemeMode extends SettingsEvent {
  final String themeMode;

  const UpdateThemeMode({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class ChangePassword extends SettingsEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class DeleteAccount extends SettingsEvent {
  final String userId;

  const DeleteAccount({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class Logout extends SettingsEvent {
  const Logout();
}

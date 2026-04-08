part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final UserSettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsSaved extends SettingsState {
  final UserSettingsEntity settings;

  const SettingsSaved(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PasswordChanged extends SettingsState {
  final SettingsLoaded previousState;

  const PasswordChanged(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class AccountDeleted extends SettingsState {
  const AccountDeleted();
}

class LoggedOut extends SettingsState {
  const LoggedOut();
}

class SettingsError extends SettingsState {
  final String message;
  final SettingsLoaded? previousState;

  const SettingsError(this.message, [this.previousState]);

  @override
  List<Object?> get props => [message, previousState];
}

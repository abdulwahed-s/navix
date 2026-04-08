import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  final FirebaseAuth firebaseAuth;
  final ThemeCubit themeCubit;

  String? _userId;
  UserSettingsEntity _currentSettings = UserSettingsEntity.defaults();

  SettingsBloc({
    required this.repository,
    required this.firebaseAuth,
    required this.themeCubit,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateNotificationPreference>(_onUpdateNotification);
    on<UpdatePrivacySetting>(_onUpdatePrivacy);
    on<UpdateThemeMode>(_onUpdateTheme);
    on<ChangePassword>(_onChangePassword);
    on<DeleteAccount>(_onDeleteAccount);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    _userId = event.userId;

    final result = await repository.getSettings(event.userId);

    result.fold((failure) => emit(SettingsError(failure.message)), (settings) {
      _currentSettings = settings;

      themeCubit.setTheme(settings.themeMode);
      emit(SettingsLoaded(settings));
    });
  }

  Future<void> _onUpdateNotification(
    UpdateNotificationPreference event,
    Emitter<SettingsState> emit,
  ) async {
    if (_userId == null) return;

    final newPrefs = Map<String, bool>.from(
      _currentSettings.notificationPreferences,
    );
    newPrefs[event.key] = event.value;

    _currentSettings = _currentSettings.copyWith(
      notificationPreferences: newPrefs,
    );

    emit(SettingsLoaded(_currentSettings));

    final result = await repository.updateSettings(
      userId: _userId!,
      settings: _currentSettings,
    );

    result.fold(
      (failure) => emit(
        SettingsError(failure.message, SettingsLoaded(_currentSettings)),
      ),
      (_) => emit(SettingsSaved(_currentSettings)),
    );
  }

  Future<void> _onUpdatePrivacy(
    UpdatePrivacySetting event,
    Emitter<SettingsState> emit,
  ) async {
    if (_userId == null) return;

    final newSettings = Map<String, String>.from(
      _currentSettings.privacySettings,
    );
    newSettings[event.key] = event.value;

    _currentSettings = _currentSettings.copyWith(privacySettings: newSettings);

    emit(SettingsLoaded(_currentSettings));

    final result = await repository.updateSettings(
      userId: _userId!,
      settings: _currentSettings,
    );

    result.fold(
      (failure) => emit(
        SettingsError(failure.message, SettingsLoaded(_currentSettings)),
      ),
      (_) => emit(SettingsSaved(_currentSettings)),
    );
  }

  Future<void> _onUpdateTheme(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (_userId == null) return;

    _currentSettings = _currentSettings.copyWith(themeMode: event.themeMode);

    themeCubit.setTheme(event.themeMode);

    emit(SettingsLoaded(_currentSettings));

    final result = await repository.updateSettings(
      userId: _userId!,
      settings: _currentSettings,
    );

    result.fold(
      (failure) => emit(
        SettingsError(failure.message, SettingsLoaded(_currentSettings)),
      ),
      (_) => emit(SettingsSaved(_currentSettings)),
    );
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(const SettingsLoading());

    final result = await repository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(SettingsError(failure.message, currentState)),
      (_) => emit(PasswordChanged(currentState)),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await repository.deleteAccount(event.userId);

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => emit(const AccountDeleted()),
    );
  }

  Future<void> _onLogout(Logout event, Emitter<SettingsState> emit) async {
    await firebaseAuth.signOut();
    emit(const LoggedOut());
  }
}

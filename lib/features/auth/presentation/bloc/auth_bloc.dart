import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
    required this.profileRepository,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<_AuthStateChanged>(_onAuthStateChanged);

    _authStateSubscription = authRepository.authStateChanges.listen(
      (user) => add(_AuthStateChanged(user)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.getCurrentUser();

    await result.fold(
      (failure) async =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (user) async {
        if (user != null) {
          await _checkProfileAndEmit(user, emit);
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Logging in...'));

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (user) async => await _checkProfileAndEmit(user, emit),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));

    final result = await registerUseCase(
      RegisterParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (user) async {
        emit(AuthenticatedNeedsProfile(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Logging out...'));

    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      await _checkProfileAndEmit(event.user!, emit);
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _checkProfileAndEmit(
    UserEntity user,
    Emitter<AuthState> emit,
  ) async {
    final profileResult = await profileRepository.getProfile(user.id);

    profileResult.fold((failure) => emit(Authenticated(user)), (profile) {
      if (profile == null) {
        emit(AuthenticatedNeedsProfile(user));
      } else {
        emit(Authenticated(user));
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

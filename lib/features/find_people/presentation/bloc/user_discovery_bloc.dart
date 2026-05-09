import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/repositories/user_discovery_repository.dart';
import '../../domain/usecases/search_users_usecase.dart';

part 'user_discovery_event.dart';
part 'user_discovery_state.dart';

class UserDiscoveryBloc extends Bloc<UserDiscoveryEvent, UserDiscoveryState> {
  final UserDiscoveryRepository repository;
  final SearchUsersUseCase searchUsersUseCase;

  String _currentQuery = '';
  List<String> _currentFilters = [];

  UserDiscoveryBloc({
    required this.repository,
    required this.searchUsersUseCase,
  }) : super(const UserDiscoveryInitial()) {
    on<LoadInitialUsers>(_onLoadInitialUsers);
    on<SearchUsers>(_onSearchUsers);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
    on<SendConnection>(_onSendConnection);
    on<CancelConnection>(_onCancelConnection);
    on<RemoveConnection>(_onRemoveConnection);
  }

  Future<void> _onLoadInitialUsers(
    LoadInitialUsers event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    emit(const UserDiscoveryLoading());

    final result = await searchUsersUseCase(
      const SearchUsersParams(query: '', limit: 50),
    );

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (users) async {
        final statuses = await _getConnectionStatuses(users);
        emit(UserDiscoveryLoaded(users: users, connectionStatuses: statuses));
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    _currentQuery = event.query;

    emit(const UserDiscoveryLoading());

    final result = await searchUsersUseCase(
      SearchUsersParams(
        query: event.query,
        skills: _currentFilters.isEmpty ? null : _currentFilters,
        limit: 50,
      ),
    );

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (users) async {
        final statuses = await _getConnectionStatuses(users);
        emit(
          UserDiscoveryLoaded(
            users: users,
            searchQuery: event.query,
            activeFilters: _currentFilters,
            connectionStatuses: statuses,
          ),
        );
      },
    );
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    _currentFilters = event.skills;

    emit(const UserDiscoveryLoading());

    final result = await searchUsersUseCase(
      SearchUsersParams(
        query: _currentQuery,
        skills: event.skills.isEmpty ? null : event.skills,
        limit: 50,
      ),
    );

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (users) async {
        final statuses = await _getConnectionStatuses(users);
        emit(
          UserDiscoveryLoaded(
            users: users,
            searchQuery: _currentQuery,
            activeFilters: event.skills,
            connectionStatuses: statuses,
          ),
        );
      },
    );
  }

  void _onClearFilters(ClearFilters event, Emitter<UserDiscoveryState> emit) {
    _currentFilters = [];
    add(SearchUsers(query: _currentQuery));
  }

  Future<void> _onSendConnection(
    SendConnection event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    final currentState = _getLoadedState();
    if (currentState == null) return;

    final result = await repository.sendConnectionRequest(
      toUserId: event.userId,
      message: event.message,
    );

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (_) async {
        final updatedStatuses = Map<String, ConnectionStatus>.from(
          currentState.connectionStatuses,
        )..[event.userId] = ConnectionStatus.pendingOut;

        final updatedState = currentState.copyWith(
          connectionStatuses: updatedStatuses,
        );
        emit(updatedState);
      },
    );
  }

  UserDiscoveryLoaded? _getLoadedState() {
    final s = state;
    if (s is UserDiscoveryLoaded) return s;
    if (s is ConnectionSent) return s.previousState;
    if (s is ConnectionCancelled) return s.previousState;
    if (s is ConnectionRemoved) return s.previousState;
    return null;
  }

  Future<Map<String, ConnectionStatus>> _getConnectionStatuses(
    List<ProfileEntity> users,
  ) async {
    if (users.isEmpty) return {};

    final userIds = users.map((u) => u.userId).toList();
    final result = await repository.getConnectionStatuses(userIds);

    return result.fold((_) => {}, (statuses) => statuses);
  }

  Future<void> _onCancelConnection(
    CancelConnection event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    final currentState = _getLoadedState();
    if (currentState == null) return;

    final result = await repository.cancelConnectionRequest(
      toUserId: event.userId,
    );

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (_) async {
        final updatedStatuses = Map<String, ConnectionStatus>.from(
          currentState.connectionStatuses,
        )..[event.userId] = ConnectionStatus.none;

        final updatedState = currentState.copyWith(
          connectionStatuses: updatedStatuses,
        );
        emit(updatedState);
      },
    );
  }

  Future<void> _onRemoveConnection(
    RemoveConnection event,
    Emitter<UserDiscoveryState> emit,
  ) async {
    final currentState = _getLoadedState();
    if (currentState == null) return;

    final result = await repository.removeConnection(userId: event.userId);

    await result.fold(
      (failure) async => emit(UserDiscoveryError(failure.message)),
      (_) async {
        final updatedStatuses = Map<String, ConnectionStatus>.from(
          currentState.connectionStatuses,
        )..[event.userId] = ConnectionStatus.none;

        final updatedState = currentState.copyWith(
          connectionStatuses: updatedStatuses,
        );
        emit(updatedState);
      },
    );
  }
}

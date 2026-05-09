part of 'user_discovery_bloc.dart';

abstract class UserDiscoveryState extends Equatable {
  const UserDiscoveryState();

  @override
  List<Object?> get props => [];
}

class UserDiscoveryInitial extends UserDiscoveryState {
  const UserDiscoveryInitial();
}

class UserDiscoveryLoading extends UserDiscoveryState {
  const UserDiscoveryLoading();
}

class UserDiscoveryLoaded extends UserDiscoveryState {
  final List<ProfileEntity> users;
  final String searchQuery;
  final List<String> activeFilters;
  final Map<String, ConnectionStatus> connectionStatuses;

  const UserDiscoveryLoaded({
    required this.users,
    this.searchQuery = '',
    this.activeFilters = const [],
    this.connectionStatuses = const {},
  });

  UserDiscoveryLoaded copyWith({
    List<ProfileEntity>? users,
    String? searchQuery,
    List<String>? activeFilters,
    Map<String, ConnectionStatus>? connectionStatuses,
  }) {
    return UserDiscoveryLoaded(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      connectionStatuses: connectionStatuses ?? this.connectionStatuses,
    );
  }

  @override
  List<Object?> get props => [
    users,
    searchQuery,
    activeFilters,
    connectionStatuses,
  ];
}

class ConnectionSent extends UserDiscoveryState {
  final UserDiscoveryLoaded previousState;

  const ConnectionSent(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class UserDiscoveryError extends UserDiscoveryState {
  final String message;

  const UserDiscoveryError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConnectionCancelled extends UserDiscoveryState {
  final UserDiscoveryLoaded previousState;

  const ConnectionCancelled(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class ConnectionRemoved extends UserDiscoveryState {
  final UserDiscoveryLoaded previousState;

  const ConnectionRemoved(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

part of 'user_discovery_bloc.dart';

abstract class UserDiscoveryEvent extends Equatable {
  const UserDiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class SearchUsers extends UserDiscoveryEvent {
  final String query;

  const SearchUsers({required this.query});

  @override
  List<Object?> get props => [query];
}

class ApplyFilters extends UserDiscoveryEvent {
  final List<String> skills;

  const ApplyFilters({required this.skills});

  @override
  List<Object?> get props => [skills];
}

class ClearFilters extends UserDiscoveryEvent {
  const ClearFilters();
}

class SendConnection extends UserDiscoveryEvent {
  final String userId;
  final String? message;

  const SendConnection({required this.userId, this.message});

  @override
  List<Object?> get props => [userId, message];
}

class LoadInitialUsers extends UserDiscoveryEvent {
  const LoadInitialUsers();
}

class CancelConnection extends UserDiscoveryEvent {
  final String userId;

  const CancelConnection({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RemoveConnection extends UserDiscoveryEvent {
  final String userId;

  const RemoveConnection({required this.userId});

  @override
  List<Object?> get props => [userId];
}

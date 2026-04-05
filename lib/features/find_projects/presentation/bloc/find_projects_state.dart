part of 'find_projects_bloc.dart';

abstract class FindProjectsState extends Equatable {
  const FindProjectsState();

  @override
  List<Object?> get props => [];
}

class FindProjectsInitial extends FindProjectsState {
  const FindProjectsInitial();
}

class FindProjectsLoading extends FindProjectsState {
  const FindProjectsLoading();
}

class FindProjectsLoaded extends FindProjectsState {
  final List<ProjectListingEntity> listings;

  const FindProjectsLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

class FindProjectsError extends FindProjectsState {
  final String message;

  const FindProjectsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ApplicationSubmitted extends FindProjectsState {
  const ApplicationSubmitted();
}

class ListingPublished extends FindProjectsState {
  const ListingPublished();
}

class ListingRemoved extends FindProjectsState {
  const ListingRemoved();
}

class ProjectListingLoaded extends FindProjectsState {
  final ProjectListingEntity? listing;

  const ProjectListingLoaded({this.listing});

  @override
  List<Object?> get props => [listing];
}

class JoinRequestsLoaded extends FindProjectsState {
  final List<ProjectJoinRequestEntity> requests;

  const JoinRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class JoinRequestResponded extends FindProjectsState {
  final bool accepted;

  const JoinRequestResponded({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

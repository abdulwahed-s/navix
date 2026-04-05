part of 'find_projects_bloc.dart';

abstract class FindProjectsEvent extends Equatable {
  const FindProjectsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectListings extends FindProjectsEvent {
  const LoadProjectListings();
}

class ApplyToProject extends FindProjectsEvent {
  final String listingId;
  final String projectId;
  final String leaderId;
  final String roleName;
  final String? message;

  const ApplyToProject({
    required this.listingId,
    required this.projectId,
    required this.leaderId,
    required this.roleName,
    this.message,
  });

  @override
  List<Object?> get props => [
    listingId,
    projectId,
    leaderId,
    roleName,
    message,
  ];
}

class PublishListing extends FindProjectsEvent {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final String leaderId;
  final String? leaderMessage;
  final List<OpenRole> openRoles;

  const PublishListing({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.leaderId,
    this.leaderMessage,
    required this.openRoles,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    projectDescription,
    leaderId,
    leaderMessage,
    openRoles,
  ];
}

class RemoveListing extends FindProjectsEvent {
  final String listingId;

  const RemoveListing({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

class LoadListingForProject extends FindProjectsEvent {
  final String projectId;

  const LoadListingForProject({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class LoadJoinRequests extends FindProjectsEvent {
  final String projectId;

  const LoadJoinRequests({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class RespondToJoinRequest extends FindProjectsEvent {
  final String requestId;
  final bool accepted;
  final String projectId;
  final String applicantId;
  final String projectName;

  const RespondToJoinRequest({
    required this.requestId,
    required this.accepted,
    required this.projectId,
    required this.applicantId,
    required this.projectName,
  });

  @override
  List<Object?> get props => [
    requestId,
    accepted,
    projectId,
    applicantId,
    projectName,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/open_role.dart';
import '../../domain/entities/project_join_request_entity.dart';
import '../../domain/entities/project_listing_entity.dart';
import '../../domain/repositories/find_projects_repository.dart';

part 'find_projects_event.dart';
part 'find_projects_state.dart';

class FindProjectsBloc extends Bloc<FindProjectsEvent, FindProjectsState> {
  final FindProjectsRepository repository;

  FindProjectsBloc({required this.repository})
    : super(const FindProjectsInitial()) {
    on<LoadProjectListings>(_onLoadProjectListings);
    on<ApplyToProject>(_onApplyToProject);
    on<PublishListing>(_onPublishListing);
    on<RemoveListing>(_onRemoveListing);
    on<LoadListingForProject>(_onLoadListingForProject);
    on<LoadJoinRequests>(_onLoadJoinRequests);
    on<RespondToJoinRequest>(_onRespondToJoinRequest);
  }

  Future<void> _onLoadProjectListings(
    LoadProjectListings event,
    Emitter<FindProjectsState> emit,
  ) async {
    emit(const FindProjectsLoading());

    final result = await repository.getProjectListings();
    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (listings) => emit(FindProjectsLoaded(listings: listings)),
    );
  }

  Future<void> _onApplyToProject(
    ApplyToProject event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.applyToProject(
      listingId: event.listingId,
      projectId: event.projectId,
      leaderId: event.leaderId,
      roleName: event.roleName,
      message: event.message,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (_) => emit(const ApplicationSubmitted()),
    );
  }

  Future<void> _onPublishListing(
    PublishListing event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.publishProjectListing(
      projectId: event.projectId,
      projectName: event.projectName,
      projectDescription: event.projectDescription,
      leaderId: event.leaderId,
      leaderMessage: event.leaderMessage,
      openRoles: event.openRoles,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (_) => emit(const ListingPublished()),
    );
  }

  Future<void> _onRemoveListing(
    RemoveListing event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.removeProjectListing(
      listingId: event.listingId,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (_) => emit(const ListingRemoved()),
    );
  }

  Future<void> _onLoadListingForProject(
    LoadListingForProject event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.getListingForProject(
      projectId: event.projectId,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (listing) => emit(ProjectListingLoaded(listing: listing)),
    );
  }

  Future<void> _onLoadJoinRequests(
    LoadJoinRequests event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.getJoinRequestsForProject(
      projectId: event.projectId,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (requests) => emit(JoinRequestsLoaded(requests: requests)),
    );
  }

  Future<void> _onRespondToJoinRequest(
    RespondToJoinRequest event,
    Emitter<FindProjectsState> emit,
  ) async {
    final result = await repository.respondToJoinRequest(
      requestId: event.requestId,
      accepted: event.accepted,
      projectId: event.projectId,
      applicantId: event.applicantId,
      projectName: event.projectName,
    );

    result.fold(
      (failure) => emit(FindProjectsError(failure.message)),
      (_) => emit(JoinRequestResponded(accepted: event.accepted)),
    );
  }
}

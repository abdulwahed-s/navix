import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/invitation_entity.dart';
import '../../domain/repositories/team_repository.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRepository repository;

  StreamSubscription<List<InvitationEntity>>? _invitationSubscription;
  String? _currentProjectId;

  TeamBloc({required this.repository}) : super(const TeamInitial()) {
    on<LoadTeamMembers>(_onLoadTeamMembers);
    on<SendInvitation>(_onSendInvitation);
    on<LoadPendingInvitations>(_onLoadPendingInvitations);
    on<SubscribeToPendingInvitations>(_onSubscribe);
    on<InvitationsUpdated>(_onInvitationsUpdated);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
    on<RemoveMember>(_onRemoveMember);
    on<ChangeMemberRole>(_onChangeMemberRole);
    on<CancelInvitation>(_onCancelInvitation);
  }

  Future<void> _onLoadTeamMembers(
    LoadTeamMembers event,
    Emitter<TeamState> emit,
  ) async {
    emit(const TeamLoading());
    _currentProjectId = event.projectId;

    final result = await repository.getTeamMembers(event.projectId);

    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (members) => emit(TeamMembersLoaded(members)),
    );
  }

  Future<void> _onSendInvitation(
    SendInvitation event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.sendInvitation(
      projectId: event.projectId,
      projectName: event.projectName,
      inviterId: event.inviterId,
      inviterName: event.inviterName,
      inviteeId: event.inviteeId,
      inviteeName: event.inviteeName,
      message: event.message,
    );

    result.fold((failure) => emit(TeamError(failure.message)), (_) {
      emit(const InvitationSent());

      if (_currentProjectId != null) {
        add(LoadTeamMembers(projectId: _currentProjectId!));
      }
    });
  }

  Future<void> _onLoadPendingInvitations(
    LoadPendingInvitations event,
    Emitter<TeamState> emit,
  ) async {
    emit(const TeamLoading());

    final result = await repository.getPendingInvitations(event.userId);

    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (invitations) => emit(PendingInvitationsLoaded(invitations)),
    );
  }

  void _onSubscribe(
    SubscribeToPendingInvitations event,
    Emitter<TeamState> emit,
  ) {
    _invitationSubscription?.cancel();
    _invitationSubscription = repository
        .watchPendingInvitations(event.userId)
        .listen((invitations) {
          add(InvitationsUpdated(invitations));
        });
  }

  void _onInvitationsUpdated(
    InvitationsUpdated event,
    Emitter<TeamState> emit,
  ) {
    emit(PendingInvitationsLoaded(event.invitations));
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.acceptInvitation(event.invitationId);

    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(const InvitationResponseProcessed(accepted: true)),
    );
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.declineInvitation(event.invitationId);

    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(const InvitationResponseProcessed(accepted: false)),
    );
  }

  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.removeMember(
      projectId: event.projectId,
      memberId: event.memberId,
    );

    result.fold((failure) => emit(TeamError(failure.message)), (_) {
      emit(const MemberRemoved());

      if (_currentProjectId != null) {
        add(LoadTeamMembers(projectId: _currentProjectId!));
      }
    });
  }

  Future<void> _onChangeMemberRole(
    ChangeMemberRole event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.changeMemberRole(
      projectId: event.projectId,
      memberId: event.memberId,
      newRole: event.newRole,
    );

    result.fold((failure) => emit(TeamError(failure.message)), (_) {
      emit(const RoleChanged());

      if (_currentProjectId != null) {
        add(LoadTeamMembers(projectId: _currentProjectId!));
      }
    });
  }

  Future<void> _onCancelInvitation(
    CancelInvitation event,
    Emitter<TeamState> emit,
  ) async {
    final result = await repository.cancelInvitation(event.invitationId);

    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (_) => emit(const InvitationCancelled()),
    );
  }

  @override
  Future<void> close() {
    _invitationSubscription?.cancel();
    return super.close();
  }
}

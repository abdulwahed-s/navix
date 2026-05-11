part of 'team_bloc.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamMembers extends TeamEvent {
  final String projectId;

  const LoadTeamMembers({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class SendInvitation extends TeamEvent {
  final String projectId;
  final String projectName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeName;
  final String? message;

  const SendInvitation({
    required this.projectId,
    required this.projectName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeName,
    this.message,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    inviterId,
    inviterName,
    inviteeId,
    inviteeName,
    message,
  ];
}

class LoadPendingInvitations extends TeamEvent {
  final String userId;

  const LoadPendingInvitations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubscribeToPendingInvitations extends TeamEvent {
  final String userId;

  const SubscribeToPendingInvitations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class InvitationsUpdated extends TeamEvent {
  final List<InvitationEntity> invitations;

  const InvitationsUpdated(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class AcceptInvitation extends TeamEvent {
  final String invitationId;

  const AcceptInvitation({required this.invitationId});

  @override
  List<Object?> get props => [invitationId];
}

class DeclineInvitation extends TeamEvent {
  final String invitationId;

  const DeclineInvitation({required this.invitationId});

  @override
  List<Object?> get props => [invitationId];
}

class RemoveMember extends TeamEvent {
  final String projectId;
  final String memberId;

  const RemoveMember({required this.projectId, required this.memberId});

  @override
  List<Object?> get props => [projectId, memberId];
}

class ChangeMemberRole extends TeamEvent {
  final String projectId;
  final String memberId;
  final MemberRole newRole;

  const ChangeMemberRole({
    required this.projectId,
    required this.memberId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [projectId, memberId, newRole];
}

class CancelInvitation extends TeamEvent {
  final String invitationId;
  final String projectId;

  const CancelInvitation({required this.invitationId, required this.projectId});

  @override
  List<Object?> get props => [invitationId, projectId];
}

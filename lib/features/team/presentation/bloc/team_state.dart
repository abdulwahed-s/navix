part of 'team_bloc.dart';

abstract class TeamState extends Equatable {
  const TeamState();

  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {
  const TeamInitial();
}

class TeamLoading extends TeamState {
  const TeamLoading();
}

class TeamMembersLoaded extends TeamState {
  final List<TeamMemberInfo> members;

  const TeamMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class PendingInvitationsLoaded extends TeamState {
  final List<InvitationEntity> invitations;

  const PendingInvitationsLoaded(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class InvitationSent extends TeamState {
  const InvitationSent();
}

class InvitationResponseProcessed extends TeamState {
  final bool accepted;

  const InvitationResponseProcessed({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

class MemberRemoved extends TeamState {
  const MemberRemoved();
}

class RoleChanged extends TeamState {
  const RoleChanged();
}

class TeamError extends TeamState {
  final String message;

  const TeamError(this.message);

  @override
  List<Object?> get props => [message];
}

class InvitationCancelled extends TeamState {
  const InvitationCancelled();
}

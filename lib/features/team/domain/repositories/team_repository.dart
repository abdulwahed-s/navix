import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invitation_entity.dart';

enum MemberRole { leader, member }

abstract class TeamRepository {
  Future<Either<Failure, void>> sendInvitation({
    required String projectId,
    required String projectName,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    required String inviteeName,
    String? message,
  });

  Future<Either<Failure, void>> acceptInvitation(String invitationId);

  Future<Either<Failure, void>> declineInvitation(String invitationId);

  Future<Either<Failure, void>> cancelInvitation(String invitationId);

  Future<Either<Failure, List<InvitationEntity>>> getPendingInvitations(
    String userId,
  );

  Stream<List<InvitationEntity>> watchPendingInvitations(String userId);

  Future<Either<Failure, List<TeamMemberInfo>>> getTeamMembers(
    String projectId,
  );

  Future<Either<Failure, void>> removeMember({
    required String projectId,
    required String memberId,
  });

  Future<Either<Failure, void>> changeMemberRole({
    required String projectId,
    required String memberId,
    required MemberRole newRole,
  });
}

class TeamMemberInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final MemberRole role;
  final int assignedTasks;
  final int completedTasks;

  const TeamMemberInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.assignedTasks,
    required this.completedTasks,
  });

  int get completionRate =>
      assignedTasks > 0 ? ((completedTasks / assignedTasks) * 100).round() : 0;
}

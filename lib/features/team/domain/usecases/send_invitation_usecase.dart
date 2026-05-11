import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/team_repository.dart';

class SendInvitationUseCase implements UseCase<void, SendInvitationParams> {
  final TeamRepository repository;

  SendInvitationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendInvitationParams params) {
    return repository.sendInvitation(
      projectId: params.projectId,
      projectName: params.projectName,
      inviterId: params.inviterId,
      inviterName: params.inviterName,
      inviteeId: params.inviteeId,
      inviteeName: params.inviteeName,
    );
  }
}

class SendInvitationParams extends Equatable {
  final String projectId;
  final String projectName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeName;

  const SendInvitationParams({
    required this.projectId,
    required this.projectName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeName,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    inviterId,
    inviterName,
    inviteeId,
    inviteeName,
  ];
}

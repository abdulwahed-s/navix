import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined }

class InvitationEntity extends Equatable {
  final String id;
  final String projectId;
  final String projectName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeName;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const InvitationEntity({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeName,
    this.status = InvitationStatus.pending,
    required this.createdAt,
    this.respondedAt,
  });

  InvitationEntity copyWith({
    String? id,
    String? projectId,
    String? projectName,
    String? inviterId,
    String? inviterName,
    String? inviteeId,
    String? inviteeName,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return InvitationEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      inviterId: inviterId ?? this.inviterId,
      inviterName: inviterName ?? this.inviterName,
      inviteeId: inviteeId ?? this.inviteeId,
      inviteeName: inviteeName ?? this.inviteeName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    projectName,
    inviterId,
    inviterName,
    inviteeId,
    inviteeName,
    status,
    createdAt,
    respondedAt,
  ];
}

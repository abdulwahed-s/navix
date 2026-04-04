import 'package:equatable/equatable.dart';

class ProjectJoinRequestEntity extends Equatable {
  final String id;

  final String projectId;

  final String listingId;

  final String applicantId;

  final String leaderId;

  final String roleName;

  final String? message;

  final String status;

  final DateTime createdAt;

  final DateTime? respondedAt;

  const ProjectJoinRequestEntity({
    required this.id,
    required this.projectId,
    required this.listingId,
    required this.applicantId,
    required this.leaderId,
    required this.roleName,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    id,
    projectId,
    listingId,
    applicantId,
    leaderId,
    roleName,
    message,
    status,
    createdAt,
    respondedAt,
  ];
}

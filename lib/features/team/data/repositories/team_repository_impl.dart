import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  final NotificationRepository notificationRepository;

  TeamRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
    required this.notificationRepository,
  });

  @override
  Future<Either<Failure, void>> sendInvitation({
    required String projectId,
    required String projectName,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    required String inviteeName,
    String? message,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final existing = await firestore
          .collection('invitations')
          .where('projectId', isEqualTo: projectId)
          .where('inviteeId', isEqualTo: inviteeId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        return const Left(
          ServerFailure(
            message: 'Invitation already pending',
            code: 'invitation-exists',
          ),
        );
      }

      String actualInviterName = inviterName;
      try {
        final profileDoc = await firestore
            .collection('users')
            .doc(inviterId)
            .collection('profile')
            .doc('main')
            .get();

        if (profileDoc.exists) {
          actualInviterName =
              profileDoc.data()?['name'] as String? ?? inviterName;
        }
      } catch (e) {
        actualInviterName = inviterName;
      }

      final invitationData = <String, dynamic>{
        'projectId': projectId,
        'projectName': projectName,
        'inviterId': inviterId,
        'inviteeId': inviteeId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (message != null && message.isNotEmpty) {
        invitationData['message'] = message;
      }

      final invitationDoc = await firestore
          .collection('invitations')
          .add(invitationData);

      final notificationBody = message != null && message.isNotEmpty
          ? '$actualInviterName invited you to join $projectName: "$message"'
          : '$actualInviterName invited you to join $projectName';

      final notificationData = <String, dynamic>{
        'projectId': projectId,
        'projectName': projectName,
        'inviterId': inviterId,
        'inviterName': actualInviterName,
        'invitationId': invitationDoc.id,
      };

      if (message != null && message.isNotEmpty) {
        notificationData['message'] = message;
      }

      await notificationRepository.createNotification(
        NotificationEntity(
          id: '',
          userId: inviteeId,
          type: NotificationType.projectInvitation,
          title: 'Project Invitation',
          body: notificationBody,
          data: notificationData,
          createdAt: DateTime.now(),
          relatedId: projectId,
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send invitation: $e',
          code: 'invitation-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(String invitationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final invitationDoc = await firestore
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (!invitationDoc.exists) {
        return const Left(
          ServerFailure(message: 'Invitation not found', code: 'not-found'),
        );
      }

      final data = invitationDoc.data()!;
      final projectId = data['projectId'] as String;
      final inviteeId = data['inviteeId'] as String;

      await firestore.collection('invitations').doc(invitationId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('projects').doc(projectId).update({
        'memberIds': FieldValue.arrayUnion([inviteeId]),
      });

      final projectName = data['projectName'] as String;
      String inviteeName = 'Unknown';
      try {
        final inviteeProfileDoc = await firestore
            .collection('users')
            .doc(inviteeId)
            .collection('profile')
            .doc('main')
            .get();
        if (inviteeProfileDoc.exists) {
          inviteeName =
              inviteeProfileDoc.data()?['name'] as String? ?? 'Unknown';
        }
      } catch (_) {}

      await notificationRepository.createNotification(
        NotificationEntity(
          id: '',
          userId: data['inviterId'] as String,
          type: NotificationType.general,
          title: 'Invitation Accepted',
          body: '$inviteeName accepted your invitation to join $projectName',
          data: {
            'projectId': projectId,
            'projectName': projectName,
            'memberId': inviteeId,
          },
          createdAt: DateTime.now(),
          relatedId: projectId,
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to accept invitation: $e',
          code: 'invitation-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String invitationId) async {
    try {
      await firestore.collection('invitations').doc(invitationId).update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to decline invitation: $e',
          code: 'invitation-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvitation(String invitationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore.collection('invitations').doc(invitationId).delete();

      final notifications = await firestore
          .collection('notifications')
          .where('data.invitationId', isEqualTo: invitationId)
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.delete();
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to cancel invitation: $e',
          code: 'invitation-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> getPendingInvitations(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('invitations')
          .where('inviteeId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final invitations = snapshot.docs
          .map((doc) => _invitationFromDoc(doc))
          .toList();

      return Right(invitations);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get invitations: $e',
          code: 'invitation-error',
        ),
      );
    }
  }

  Future<List<String>> getPendingInvitationUserIds(String projectId) async {
    try {
      final snapshot = await firestore
          .collection('invitations')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['inviteeId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<InvitationEntity>> watchPendingInvitations(String userId) {
    return firestore
        .collection('invitations')
        .where('inviteeId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _invitationFromDoc(doc)).toList(),
        );
  }

  @override
  Future<Either<Failure, List<TeamMemberInfo>>> getTeamMembers(
    String projectId,
  ) async {
    try {
      final projectDoc = await firestore
          .collection('projects')
          .doc(projectId)
          .get();

      if (!projectDoc.exists) {
        return const Left(
          ServerFailure(message: 'Project not found', code: 'not-found'),
        );
      }

      final data = projectDoc.data()!;
      final memberIds = List<String>.from(data['memberIds'] ?? []);
      final leaderId = data['leaderId'] as String?;

      if (leaderId != null && !memberIds.contains(leaderId)) {
        memberIds.insert(0, leaderId);
      }

      final members = <TeamMemberInfo>[];

      for (final memberId in memberIds) {
        final userDoc = await firestore
            .collection('users')
            .doc(memberId)
            .collection('profile')
            .doc('main')
            .get();
        if (!userDoc.exists) {
          continue;
        }

        final userData = userDoc.data()!;

        final tasksSnapshot = await firestore
            .collection('projects')
            .doc(projectId)
            .collection('tasks')
            .where('assignedTo', isEqualTo: memberId)
            .get();

        final completedTasks = tasksSnapshot.docs
            .where((doc) => doc.data()['status'] == 'done')
            .length;

        members.add(
          TeamMemberInfo(
            id: memberId,
            name: userData['name'] as String? ?? 'Unknown',
            avatarUrl: userData['profilePicUrl'] as String?,
            role: memberId == leaderId ? MemberRole.leader : MemberRole.member,
            assignedTasks: tasksSnapshot.docs.length,
            completedTasks: completedTasks,
          ),
        );
      }

      return Right(members);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get team members: $e',
          code: 'team-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({
    required String projectId,
    required String memberId,
  }) async {
    try {
      await firestore.collection('projects').doc(projectId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
      });

      final tasks = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .where('assignedTo', isEqualTo: memberId)
          .get();

      for (final task in tasks.docs) {
        await task.reference.update({'assignedTo': null});
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to remove member: $e',
          code: 'team-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> changeMemberRole({
    required String projectId,
    required String memberId,
    required MemberRole newRole,
  }) async {
    try {
      if (newRole == MemberRole.leader) {
        await firestore.collection('projects').doc(projectId).update({
          'leaderId': memberId,
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to change role: $e', code: 'team-error'),
      );
    }
  }

  InvitationEntity _invitationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    InvitationStatus status;
    switch (data['status'] as String?) {
      case 'accepted':
        status = InvitationStatus.accepted;
        break;
      case 'declined':
        status = InvitationStatus.declined;
        break;
      default:
        status = InvitationStatus.pending;
    }

    return InvitationEntity(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      projectName: data['projectName'] as String? ?? '',
      inviterId: data['inviterId'] as String? ?? '',
      inviterName: data['inviterName'] as String? ?? '',
      inviteeId: data['inviteeId'] as String? ?? '',
      inviteeName: data['inviteeName'] as String? ?? '',
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }
}

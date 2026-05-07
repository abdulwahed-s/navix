import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/connection_status.dart';
import '../../domain/repositories/user_discovery_repository.dart';

class UserDiscoveryRepositoryImpl implements UserDiscoveryRepository {
  final FirebaseFirestore firestore;

  UserDiscoveryRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, List<ProfileEntity>>> searchUsers({
    required String query,
    List<String>? skills,
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      Query queryRef = firestore.collectionGroup('profile');

      if (limit != null) {
        queryRef = queryRef.limit(limit);
      }

      final snapshot = await queryRef.get();

      var profiles = snapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .where((p) => p.userId != currentUserId)
          .toList();

      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        profiles = profiles
            .where(
              (p) =>
                  p.name.toLowerCase().contains(lowerQuery) ||
                  (p.organization ?? '').toLowerCase().contains(lowerQuery),
            )
            .toList();
      }

      if (skills != null && skills.isNotEmpty) {
        profiles = profiles
            .where(
              (p) => skills.any(
                (s) => p.skills
                    .map((e) => e.skillName.toLowerCase())
                    .contains(s.toLowerCase()),
              ),
            )
            .toList();
      }

      return Right(profiles);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to search users: $e',
          code: 'search-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> filterBySkills({
    required List<String> skills,
    int? limit,
  }) async {
    return searchUsers(query: '', skills: skills, limit: limit);
  }

  @override
  Future<Either<Failure, void>> sendConnectionRequest({
    required String toUserId,
    String? message,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      final requestDoc = await firestore.collection('connection_requests').add({
        'fromUserId': currentUser.uid,
        'fromUserName': currentUser.displayName ?? 'User',
        'toUserId': toUserId,
        'status': 'pending',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String senderName = 'Someone';
      try {
        final profileDoc = await firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('profile')
            .doc('main')
            .get();

        if (profileDoc.exists) {
          senderName = profileDoc.data()?['name'] as String? ?? 'Someone';
        }
      } catch (e) {
        senderName = currentUser.displayName ?? 'Someone';
      }

      await firestore.collection('notifications').add({
        'userId': toUserId,
        'type': 'connectionRequest',
        'title': 'Connection Request',
        'body': '$senderName wants to connect',
        'data': {
          'requestId': requestDoc.id,
          'fromUserId': currentUser.uid,
          'fromUserName': senderName,
          'message': message,
        },
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'actionStatus': null,
      });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send connection request: $e',
          code: 'connection-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendProjectInvitation({
    required String toUserId,
    required String projectId,
    required String projectName,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      await firestore.collection('project_invitations').add({
        'fromUserId': currentUser.uid,
        'fromUserName': currentUser.displayName ?? 'User',
        'toUserId': toUserId,
        'projectId': projectId,
        'projectName': projectName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

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
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('main')
          .get();
      if (!doc.exists) {
        return const Left(
          ServerFailure(
            message: 'Profile not found',
            code: 'profile-not-found',
          ),
        );
      }
      return Right(ProfileModel.fromFirestore(doc));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get profile: $e',
          code: 'profile-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, ConnectionStatus>>> getConnectionStatuses(
    List<String> userIds,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      if (userIds.isEmpty) {
        return const Right({});
      }

      final statuses = <String, ConnectionStatus>{};

      for (final userId in userIds) {
        statuses[userId] = ConnectionStatus.none;
      }

      final connectionsSnapshot = await firestore
          .collection('connections')
          .where('userIds', arrayContainsAny: [currentUser.uid])
          .get();

      for (final doc in connectionsSnapshot.docs) {
        final userIdsList = List<String>.from(doc.data()['userIds'] ?? []);
        for (final userId in userIds) {
          if (userIdsList.contains(userId) &&
              userIdsList.contains(currentUser.uid)) {
            statuses[userId] = ConnectionStatus.connected;
          }
        }
      }

      final outgoingSnapshot = await firestore
          .collection('connection_requests')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', whereIn: userIds)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in outgoingSnapshot.docs) {
        final toUserId = doc.data()['toUserId'] as String?;
        if (toUserId != null && statuses[toUserId] == ConnectionStatus.none) {
          statuses[toUserId] = ConnectionStatus.pendingOut;
        }
      }

      final incomingSnapshot = await firestore
          .collection('connection_requests')
          .where('fromUserId', whereIn: userIds)
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in incomingSnapshot.docs) {
        final fromUserId = doc.data()['fromUserId'] as String?;
        if (fromUserId != null &&
            statuses[fromUserId] == ConnectionStatus.none) {
          statuses[fromUserId] = ConnectionStatus.pendingIn;
        }
      }

      return Right(statuses);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get connection statuses: $e',
          code: 'connection-status-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> acceptConnectionRequest({
    required String requestId,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      final requestDoc = await firestore
          .collection('connection_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return const Left(
          ServerFailure(
            message: 'Connection request not found',
            code: 'request-not-found',
          ),
        );
      }

      final requestData = requestDoc.data()!;
      final fromUserId = requestData['fromUserId'] as String;

      await firestore.collection('connection_requests').doc(requestId).update({
        'status': 'accepted',
      });

      await firestore.collection('connections').add({
        'userIds': [fromUserId, currentUser.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      final notifications = await firestore
          .collection('notifications')
          .where('data.requestId', isEqualTo: requestId)
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.update({'actionStatus': 'accepted'});
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to accept connection request: $e',
          code: 'accept-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> rejectConnectionRequest({
    required String requestId,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      await firestore.collection('connection_requests').doc(requestId).update({
        'status': 'rejected',
      });

      final notifications = await firestore
          .collection('notifications')
          .where('data.requestId', isEqualTo: requestId)
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.update({'actionStatus': 'rejected'});
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to reject connection request: $e',
          code: 'reject-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelConnectionRequest({
    required String toUserId,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      final requestSnapshot = await firestore
          .collection('connection_requests')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in requestSnapshot.docs) {
        final notifications = await firestore
            .collection('notifications')
            .where('data.requestId', isEqualTo: doc.id)
            .get();

        for (final notifDoc in notifications.docs) {
          await notifDoc.reference.delete();
        }

        await doc.reference.delete();
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to cancel connection request: $e',
          code: 'cancel-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeConnection({
    required String userId,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      final connectionsSnapshot = await firestore
          .collection('connections')
          .where('userIds', arrayContains: currentUser.uid)
          .get();

      for (final doc in connectionsSnapshot.docs) {
        final userIds = List<String>.from(doc.data()['userIds'] ?? []);
        if (userIds.contains(userId) && userIds.contains(currentUser.uid)) {
          await doc.reference.delete();
          break;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to remove connection: $e',
          code: 'remove-error',
        ),
      );
    }
  }
}

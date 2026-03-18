import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final notifications = snapshot.docs.map((doc) {
        return _notificationFromDoc(doc);
      }).toList();

      return Right(notifications);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get notifications: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _notificationFromDoc(doc)).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to mark as read: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to mark all as read: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to clear notifications: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      await firestore.collection('notifications').add({
        'userId': notification.userId,
        'type': notification.type.name,
        'title': notification.title,
        'body': notification.body,
        'data': notification.data,
        'read': notification.read,
        'createdAt': Timestamp.fromDate(notification.createdAt),
        'relatedId': notification.relatedId,
        'actionStatus': notification.actionStatus,
      });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to create notification: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get unread count: $e',
          code: 'notification-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String token,
    required String deviceType,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .set({
            'token': token,
            'deviceType': deviceType,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to save FCM token: $e',
          code: 'fcm-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFcmToken(
    String userId,
    String token,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(token)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to remove FCM token: $e',
          code: 'fcm-error',
        ),
      );
    }
  }

  NotificationEntity _notificationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationEntity(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: _parseType(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedId: data['relatedId'] as String?,
      actionStatus: data['actionStatus'] as String?,
    );
  }

  NotificationType _parseType(String? value) {
    switch (value) {
      case 'taskAssigned':
        return NotificationType.taskAssigned;
      case 'taskDueSoon':
        return NotificationType.taskDueSoon;
      case 'taskOverdue':
        return NotificationType.taskOverdue;
      case 'milestoneReached':
        return NotificationType.milestoneReached;
      case 'highRiskDetected':
        return NotificationType.highRiskDetected;
      case 'newMessage':
        return NotificationType.newMessage;
      case 'projectInvitation':
        return NotificationType.projectInvitation;
      case 'connectionRequest':
        return NotificationType.connectionRequest;
      case 'newComment':
        return NotificationType.newComment;
      case 'commentReply':
        return NotificationType.commentReply;
      default:
        return NotificationType.general;
    }
  }

  @override
  Future<Either<Failure, void>> updateActionStatus({
    required String notificationId,
    required String actionStatus,
  }) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'actionStatus': actionStatus,
      });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to update action status: $e',
          code: 'notification-error',
        ),
      );
    }
  }
}

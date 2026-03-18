import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  );

  Stream<List<NotificationEntity>> watchNotifications(String userId);

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead(String userId);

  Future<Either<Failure, void>> clearAllNotifications(String userId);

  Future<Either<Failure, void>> createNotification(
    NotificationEntity notification,
  );

  Future<Either<Failure, int>> getUnreadCount(String userId);

  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String token,
    required String deviceType,
  });

  Future<Either<Failure, void>> removeFcmToken(String userId, String token);

  Future<Either<Failure, void>> updateActionStatus({
    required String notificationId,
    required String actionStatus,
  });
}

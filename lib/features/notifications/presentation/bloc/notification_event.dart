part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;

  const LoadNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubscribeToNotifications extends NotificationEvent {
  final String userId;

  const SubscribeToNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class NotificationsUpdated extends NotificationEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

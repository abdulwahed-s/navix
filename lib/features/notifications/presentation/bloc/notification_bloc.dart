import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  StreamSubscription<List<NotificationEntity>>? _subscription;
  String? _userId;

  NotificationBloc({required this.repository})
    : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<SubscribeToNotifications>(_onSubscribe);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearAllNotifications>(_onClearAll);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    _userId = event.userId;

    final result = await repository.getNotifications(event.userId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  void _onSubscribe(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) {
    _userId = event.userId;
    _subscription?.cancel();
    _subscription = repository.watchNotifications(event.userId).listen((
      notifications,
    ) {
      add(NotificationsUpdated(notifications));
    });
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoaded(event.notifications));
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(read: true);
      }
      return n;
    }).toList();

    emit(NotificationLoaded(updatedNotifications));

    await repository.markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;
    if (_userId == null) return;

    final updatedNotifications = currentState.notifications.map((n) {
      return n.copyWith(read: true);
    }).toList();

    emit(AllMarkedAsRead(NotificationLoaded(updatedNotifications)));

    await repository.markAllAsRead(_userId!);
  }

  Future<void> _onClearAll(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (_userId == null) return;

    final result = await repository.clearAllNotifications(_userId!);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const AllCleared()),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

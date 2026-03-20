import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:navix/features/notifications/domain/repositories/notification_repository.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../find_people/domain/repositories/user_discovery_repository.dart';
import '../../../find_people/presentation/bloc/user_discovery_bloc.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../team/presentation/bloc/team_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../widgets/notification_center/connection_request_tile.dart';
import '../widgets/notification_center/notification_animated_background.dart';
import '../widgets/notification_center/notification_empty_state.dart';
import '../widgets/notification_center/notification_error_state.dart';
import '../widgets/notification_center/notification_floating_decorations.dart';
import '../widgets/notification_center/notification_loading_state.dart';
import '../widgets/notification_center/notification_tile.dart';
import '../widgets/project_invitation_tile.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotifications();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _loadNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<NotificationBloc>().add(LoadNotifications(userId: userId));
      context.read<NotificationBloc>().add(
        SubscribeToNotifications(userId: userId),
      );
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme, l10n, isDark),
      body: Stack(
        children: [
          NotificationAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          NotificationFloatingDecorations(
            isDark: isDark,
            screenSize: size,
            floatingAnimation: _floatingAnimation,
          ),
          SafeArea(
            child: BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is AllMarkedAsRead) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.markAllAsRead),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (state is AllCleared) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.notificationsCleared),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (state is NotificationLoaded) {
                  _listAnimationController.forward(from: 0);
                }
              },
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return NotificationLoadingState(
                    floatingAnimation: _floatingAnimation,
                  );
                }

                if (state is NotificationError) {
                  return NotificationErrorState(
                    message: state.message,
                    isDark: isDark,
                    onRetry: _loadNotifications,
                  );
                }

                if (state is NotificationLoaded ||
                    state is AllMarkedAsRead ||
                    state is AllCleared) {
                  final notifications = state is NotificationLoaded
                      ? state.notifications
                      : state is AllMarkedAsRead
                      ? state.previousState.notifications
                      : <NotificationEntity>[];
                  return _buildNotificationsList(
                    notifications,
                    l10n,
                    theme,
                    isDark,
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        l10n.notificationCenter,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
              onSelected: (value) {
                switch (value) {
                  case 'markAllRead':
                    context.read<NotificationBloc>().add(const MarkAllAsRead());
                    break;
                  case 'clearAll':
                    _showClearConfirmation(context, l10n, isDark);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'markAllRead',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.markAllAsRead),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clearAll',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep, color: AppColors.riskHigh),
                      const SizedBox(width: 8),
                      Text(l10n.clearAll),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    List<NotificationEntity> notifications,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    if (notifications.isEmpty) {
      return NotificationEmptyState(
        isDark: isDark,
        floatingAnimation: _floatingAnimation,
        title: l10n.noNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadNotifications();
      },
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return AnimatedBuilder(
            animation: _listAnimationController,
            builder: (context, child) {
              final delay = index * 0.06;
              final animationValue = Curves.easeOutCubic.transform(
                (_listAnimationController.value - delay).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: _buildNotificationItem(notification, l10n, isDark),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationEntity notification,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (notification.type == NotificationType.projectInvitation) {
      return ProjectInvitationTile(
        notification: notification,
        isDark: isDark,
        onAccept: () => _handleInvitationAccept(notification, l10n),
        onReject: () => _handleInvitationReject(notification, l10n),
      );
    }

    if (notification.type == NotificationType.connectionRequest) {
      return ConnectionRequestTile(
        notification: notification,
        isDark: isDark,
        onAccept: () => _handleConnectionAccept(notification, l10n),
        onReject: () => _handleConnectionReject(notification, l10n),
        onViewProfile: () => _handleViewProfile(notification),
      );
    }

    return NotificationTile(
      notification: notification,
      isDark: isDark,
      onTap: () {
        context.read<NotificationBloc>().add(
          MarkAsRead(notificationId: notification.id),
        );
      },
    );
  }

  Future<void> _handleInvitationAccept(
    NotificationEntity notification,
    AppLocalizations l10n,
  ) async {
    final teamBloc = sl<TeamBloc>();
    final invitationId = notification.data['invitationId'] as String?;

    if (invitationId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid invitation')));
      }
      return;
    }

    teamBloc.add(AcceptInvitation(invitationId: invitationId));

    await for (final state in teamBloc.stream) {
      if (state is InvitationResponseProcessed) {
        await sl<NotificationRepository>().updateActionStatus(
          notificationId: notification.id,
          actionStatus: 'accepted',
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.invitationAccepted)));
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            context.read<NotificationBloc>().add(
              LoadNotifications(userId: userId),
            );
          }
        }
        break;
      } else if (state is TeamError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        break;
      }
    }
  }

  Future<void> _handleInvitationReject(
    NotificationEntity notification,
    AppLocalizations l10n,
  ) async {
    final teamBloc = sl<TeamBloc>();
    final invitationId = notification.data['invitationId'] as String?;

    if (invitationId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid invitation')));
      }
      return;
    }

    teamBloc.add(DeclineInvitation(invitationId: invitationId));

    await for (final state in teamBloc.stream) {
      if (state is InvitationResponseProcessed) {
        await sl<NotificationRepository>().updateActionStatus(
          notificationId: notification.id,
          actionStatus: 'declined',
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.invitationDeclined)));
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            context.read<NotificationBloc>().add(
              LoadNotifications(userId: userId),
            );
          }
        }
        break;
      } else if (state is TeamError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        break;
      }
    }
  }

  Future<void> _handleConnectionAccept(
    NotificationEntity notification,
    AppLocalizations l10n,
  ) async {
    final repository = sl<UserDiscoveryRepository>();
    final requestId = notification.data['requestId'] as String?;

    if (requestId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final notificationBloc = context.read<NotificationBloc>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userDiscoveryBloc = sl<UserDiscoveryBloc>();

    final result = await repository.acceptConnectionRequest(
      requestId: requestId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.connectionAccepted)),
        );
        if (userId != null) {
          notificationBloc.add(LoadNotifications(userId: userId));
        }

        userDiscoveryBloc.add(const LoadInitialUsers());
      },
    );
  }

  Future<void> _handleConnectionReject(
    NotificationEntity notification,
    AppLocalizations l10n,
  ) async {
    final repository = sl<UserDiscoveryRepository>();
    final requestId = notification.data['requestId'] as String?;

    if (requestId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final notificationBloc = context.read<NotificationBloc>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userDiscoveryBloc = sl<UserDiscoveryBloc>();

    final result = await repository.rejectConnectionRequest(
      requestId: requestId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.connectionRejected)),
        );
        if (userId != null) {
          notificationBloc.add(LoadNotifications(userId: userId));
        }

        userDiscoveryBloc.add(const LoadInitialUsers());
      },
    );
  }

  Future<void> _handleViewProfile(NotificationEntity notification) async {
    final fromUserId = notification.data['fromUserId'] as String?;
    if (fromUserId == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final profileRepository = sl<ProfileRepository>();
    final result = await profileRepository.getProfile(fromUserId);

    if (!mounted) return;

    result.fold(
      (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (profile) {
        context.push(AppRoutes.profile, extra: profile);
      },
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.confirmClearNotifications),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.riskHigh, AppColors.riskCritical],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(dialogContext);
                  this.context.read<NotificationBloc>().add(
                    const ClearAllNotifications(),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    l10n.clearAll,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;

  final VoidCallback onTap;

  final bool isDark;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getIconColor(notification.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: notification.read
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.7))
                  : (isDark
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.15,
                          )
                        : theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.4,
                          )),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notification.read
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.5))
                    : iconColor.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              iconColor.withValues(alpha: 0.2),
                              iconColor.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(notification.type),
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.read
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTime(notification.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!notification.read)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                AppColors.accentGold,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return Icons.assignment_rounded;
      case NotificationType.taskDueSoon:
        return Icons.schedule_rounded;
      case NotificationType.taskOverdue:
        return Icons.warning_rounded;
      case NotificationType.milestoneReached:
        return Icons.flag_rounded;
      case NotificationType.highRiskDetected:
        return Icons.error_rounded;
      case NotificationType.newMessage:
        return Icons.message_rounded;
      case NotificationType.projectInvitation:
        return Icons.mail_rounded;
      case NotificationType.connectionRequest:
        return Icons.person_add_rounded;
      case NotificationType.newComment:
        return Icons.comment_rounded;
      case NotificationType.commentReply:
        return Icons.reply_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return AppColors.accentLavender;
      case NotificationType.taskDueSoon:
        return AppColors.accentGold;
      case NotificationType.taskOverdue:
        return AppColors.riskHigh;
      case NotificationType.milestoneReached:
        return AppColors.accentMint;
      case NotificationType.highRiskDetected:
        return AppColors.riskCritical;
      case NotificationType.newMessage:
        return AppColors.accentLavender;
      case NotificationType.projectInvitation:
        return AppColors.accentGold;
      case NotificationType.connectionRequest:
        return AppColors.accentMint;
      case NotificationType.newComment:
        return AppColors.accentRose;
      case NotificationType.commentReply:
        return AppColors.accentRose;
      case NotificationType.general:
        return AppColors.accentGold;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

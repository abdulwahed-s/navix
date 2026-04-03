import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ai_action.dart';
import '../../domain/entities/supervisor_message.dart';

class SupervisorMessageBubble extends StatelessWidget {
  final SupervisorMessage message;
  final ThemeData theme;
  final bool isDark;
  final Function(AIAction)? onActionConfirmed;
  final Function()? onActionRejected;

  const SupervisorMessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.isDark,
    this.onActionConfirmed,
    this.onActionRejected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = message.role == SupervisorRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.shade200,
                          ),
                  ),
                  child: isUser
                      ? SelectableText(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            height: 1.4,
                          ),
                        )
                      : _buildMarkdownContent(),
                ),

                if (!isUser &&
                    message.hasActions &&
                    message.actionsPending &&
                    !message.hasExecutedAction)
                  _buildActionButtons(l10n),

                if (!isUser && message.hasExecutedAction)
                  _buildExecutedAction(l10n),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: theme.colorScheme.onPrimaryContainer,
        size: 20,
      ),
    );
  }

  Widget _buildMarkdownContent() {
    final textColor = theme.colorScheme.onSurface;
    final config = isDark
        ? MarkdownConfig.darkConfig.copy(
            configs: [
              H1Config(
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              H2Config(
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              H3Config(
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              PConfig(
                textStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              ListConfig(
                marker: (isOrdered, depth, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: isOrdered
                        ? Text(
                            '${index + 1}.',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Icon(
                            Icons.circle,
                            size: 6,
                            color: theme.colorScheme.primary,
                          ),
                  );
                },
              ),
              CodeConfig(
                style: TextStyle(
                  backgroundColor: Colors.black26,
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
              BlockquoteConfig(
                sideColor: theme.colorScheme.primary,
                textColor: textColor.withValues(alpha: 0.8),
              ),
            ],
          )
        : MarkdownConfig.defaultConfig.copy(
            configs: [
              H1Config(
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              H2Config(
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              H3Config(
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              PConfig(
                textStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: textColor.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              ListConfig(
                marker: (isOrdered, depth, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: isOrdered
                        ? Text(
                            '${index + 1}.',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Icon(
                            Icons.circle,
                            size: 6,
                            color: theme.colorScheme.primary,
                          ),
                  );
                },
              ),
              CodeConfig(
                style: TextStyle(
                  backgroundColor: Colors.grey.shade200,
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
              BlockquoteConfig(
                sideColor: theme.colorScheme.primary,
                textColor: textColor.withValues(alpha: 0.8),
              ),
            ],
          );

    return MarkdownBlock(
      data: message.content,
      config: config,
      selectable: true,
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.suggestedActions,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...message.suggestedActions!.map(
            (action) => _buildActionButton(action, l10n),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onActionRejected,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.rejectAction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(AIAction action, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => onActionConfirmed?.call(action),
          icon: Icon(_getActionIcon(action.type), size: 18),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (action.description.isNotEmpty)
                Text(
                  action.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutedAction(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${l10n.actionExecuted}: ${message.executedAction!.title}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(AIActionType type) {
    switch (type) {
      case AIActionType.changeProjectDeadline:
      case AIActionType.changeMilestoneDeadline:
      case AIActionType.changeTaskDeadline:
        return Icons.event;
      case AIActionType.addFeature:
        return Icons.add_box;
      case AIActionType.addMilestone:
        return Icons.flag;
      case AIActionType.addTasks:
        return Icons.add_task;
      case AIActionType.adjustTaskPriority:
        return Icons.priority_high;
      case AIActionType.reassignTask:
        return Icons.person_add;
      case AIActionType.simplifyScope:
        return Icons.compress;
      case AIActionType.markTasksBlocked:
        return Icons.block;
      case AIActionType.noAction:
        return Icons.check;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

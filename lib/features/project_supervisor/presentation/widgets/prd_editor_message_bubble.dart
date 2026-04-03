import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../domain/entities/prd_editor_message.dart';

class PrdEditorMessageBubble extends StatelessWidget {
  final PrdEditorMessage message;
  final ThemeData theme;
  final bool isDark;
  final Function(Map<String, dynamic>)? onAcceptUpdate;
  final VoidCallback? onRejectUpdate;

  const PrdEditorMessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.isDark,
    this.onAcceptUpdate,
    this.onRejectUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == PrdEditorRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(isUser),
                if (message.hasSuggestedUpdates && message.updatePending)
                  _buildUpdateActions(),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 12),
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
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: theme.colorScheme.primary, size: 20),
    );
  }

  Widget _buildMessageContent(bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary
            : isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
      ),
      child: isUser
          ? Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            )
          : _buildMarkdownContent(),
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

  Widget _buildUpdateActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
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
                  Icons.edit_note,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'PRD Update Suggested',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRejectUpdate,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        onAcceptUpdate?.call(message.suggestedPrdUpdates!),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

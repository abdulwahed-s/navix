import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/chat_entities.dart';

class AIChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  final bool isDark;

  const AIChatMessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final dateFormat = DateFormat('HH:mm');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isUser ? 0 : 6,
              sigmaY: isUser ? 0 : 6,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          AppColors.accentGold.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isUser
                    ? null
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.85)),
                borderRadius: BorderRadius.circular(18),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                AppColors.accentGold.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.smart_toy_rounded,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          message.role.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  if (!isUser) const SizedBox(height: 6),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

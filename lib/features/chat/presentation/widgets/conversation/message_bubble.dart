import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import 'shared_post_card.dart';
import 'shared_survey_card.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  final bool isMine;

  final bool isDark;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    if (message.isSharedPost) {
      return SharedPostCard(
        message: message,
        isMine: isMine,
        isDark: isDark,
        timeFormat: timeFormat,
      );
    }

    if (message.isSharedSurvey) {
      return SharedSurveyCard(
        message: message,
        isMine: isMine,
        isDark: isDark,
        timeFormat: timeFormat,
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMine ? 60 : 0,
          right: isMine ? 0 : 60,
        ),
        decoration: BoxDecoration(
          gradient: isMine
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.darkPrimary, AppColors.accentRose]
                      : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
                )
              : null,
          color: isMine
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isMine
                  ? (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                        .withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isMine ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: isMine
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isMine
                      ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                      : theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMine
                          ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                                .withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.read
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color: message.status == MessageStatus.read
                          ? (isDark
                                ? AppColors.accentMint
                                : AppColors.accentGold)
                          : (isDark ? AppColors.darkOnPrimary : Colors.white)
                                .withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

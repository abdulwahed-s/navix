import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class InvitationHeader extends StatelessWidget {
  final String title;

  final String inviterName;

  final String? inviterProfilePicUrl;

  final String projectName;

  final String formattedTime;

  final bool isRead;

  final String? message;

  final bool isLoading;

  const InvitationHeader({
    super.key,
    required this.title,
    required this.inviterName,
    this.inviterProfilePicUrl,
    required this.projectName,
    required this.formattedTime,
    required this.isRead,
    this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: message != null ? 70 : 50,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.3),
                AppColors.accentGold.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: inviterProfilePicUrl != null
                ? CachedNetworkImageProvider(inviterProfilePicUrl!)
                : null,
            child: inviterProfilePicUrl == null
                ? (isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentGold,
                          ),
                        )
                      : Icon(
                          Icons.mail_rounded,
                          color: AppColors.accentGold,
                          size: 18,
                        ))
                : null,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: inviterName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(text: ' invited you to join '),
                    TextSpan(
                      text: projectName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: AppColors.accentGold, width: 3),
                    ),
                  ),
                  child: Text(
                    '"$message"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

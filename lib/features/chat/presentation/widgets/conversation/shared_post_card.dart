import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/message_entity.dart';

class SharedPostCard extends StatelessWidget {
  final MessageEntity message;

  final bool isMine;

  final bool isDark;

  final DateFormat timeFormat;

  const SharedPostCard({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharedPost = message.sharedPost!;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMine ? 48 : 0,
          right: isMine ? 0 : 48,
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: isMine
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.darkPrimary.withValues(alpha: 0.9),
                                AppColors.accentRose.withValues(alpha: 0.9),
                              ]
                            : [
                                AppColors.brandPrimary.withValues(alpha: 0.95),
                                AppColors.brandPrimaryDark.withValues(
                                  alpha: 0.95,
                                ),
                              ],
                      )
                    : null,
                color: isMine
                    ? null
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMine ? 20 : 6),
                  bottomRight: Radius.circular(isMine ? 6 : 20),
                ),
                border: isMine
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isMine
                        ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.brandPrimary)
                              .withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToPost(context, sharedPost.postId),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMine ? 20 : 6),
                    bottomRight: Radius.circular(isMine ? 6 : 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sharedPost.imageUrl != null)
                        _buildImage(theme, sharedPost.imageUrl!),

                      _buildContent(theme, sharedPost),
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

  Widget _buildImage(ThemeData theme, String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: theme.colorScheme.surface,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: theme.colorScheme.errorContainer,
          child: Icon(
            Icons.broken_image_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, SharedPostData sharedPost) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_rounded,
                size: 14,
                color: isMine
                    ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Shared Post',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isMine
                      ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                            .withValues(alpha: 0.8)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            sharedPost.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isMine
                  ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                  : theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Text(
            sharedPost.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMine
                  ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                        .withValues(alpha: 0.85)
                  : theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
                    ? (isDark ? AppColors.accentMint : AppColors.accentGold)
                    : (isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isMine
                    ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isMine
                  ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                        .withValues(alpha: 0.8)
                  : theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToPost(BuildContext context, String postId) {
    context.push('/community/post/$postId');
  }
}

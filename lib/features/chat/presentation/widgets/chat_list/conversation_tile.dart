import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/conversation_entity.dart';

class ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;

  final String currentUserId;

  final bool isDark;

  final VoidCallback onDelete;

  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.isDark,
    required this.onDelete,
    required this.onTap,
  });

  Future<String?> _fetchProfilePicUrl(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('main')
          .get();
      if (doc.exists) {
        return doc.data()?['profilePicUrl'] as String?;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherName = conversation.getOtherParticipantName(currentUserId);
    final otherUserId = conversation.getOtherParticipantId(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.riskHigh.withValues(alpha: 0.8),
              AppColors.brandPrimary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.7),
                border: Border.all(
                  color: hasUnread
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.8)),
                  width: hasUnread ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasUnread
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: hasUnread ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildAvatar(theme, otherName, otherUserId, hasUnread),
                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildContent(
                            theme,
                            otherName,
                            hasUnread,
                            unreadCount,
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
      ),
    );
  }

  Widget _buildAvatar(
    ThemeData theme,
    String otherName,
    String otherUserId,
    bool hasUnread,
  ) {
    return Container(
      decoration: hasUnread
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: FutureBuilder<String?>(
        future: _fetchProfilePicUrl(otherUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              radius: 26,
              backgroundColor: hasUnread
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primaryContainer,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: hasUnread
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            );
          }

          final profilePicUrl = snapshot.data;

          return CircleAvatar(
            radius: 26,
            backgroundColor: hasUnread
                ? theme.colorScheme.primary
                : theme.colorScheme.primaryContainer,
            backgroundImage: profilePicUrl != null
                ? CachedNetworkImageProvider(profilePicUrl)
                : null,
            child: profilePicUrl == null
                ? Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: hasUnread
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    String otherName,
    bool hasUnread,
    int unreadCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                otherName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (conversation.lastMessageTime != null)
              Text(
                _formatTime(conversation.lastMessageTime!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: hasUnread
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasUnread
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (hasUnread)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkPrimary, AppColors.accentRose]
                        : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: isDark ? AppColors.darkOnPrimary : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String otherUserName;

  final String otherUserId;

  final bool isDark;

  final VoidCallback onBack;

  const ConversationAppBar({
    super.key,
    required this.otherUserName,
    required this.otherUserId,
    required this.isDark,
    required this.onBack,
  });

  Future<String?> _fetchProfilePicUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
        ),
        onPressed: onBack,
      ),
      title: Row(
        children: [
          FutureBuilder<String?>(
            future: _fetchProfilePicUrl(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }

              final profilePicUrl = snapshot.data;
              return CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: profilePicUrl != null
                    ? CachedNetworkImageProvider(profilePicUrl)
                    : null,
                child: profilePicUrl == null
                    ? Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUserName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Online',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.accentMint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

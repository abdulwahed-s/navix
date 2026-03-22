import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileViewAvatar extends StatelessWidget {
  final String? profilePicUrl;

  final bool isDark;

  const ProfileViewAvatar({
    super.key,
    required this.profilePicUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentLavender,
            AppColors.brandPrimary,
            AppColors.accentRose,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.darkSurface : Colors.white,
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: profilePicUrl != null
              ? CachedNetworkImageProvider(profilePicUrl!)
              : null,
          child: profilePicUrl == null
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
      ),
    );
  }
}

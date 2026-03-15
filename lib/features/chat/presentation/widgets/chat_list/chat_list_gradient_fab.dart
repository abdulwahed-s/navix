import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class ChatListGradientFab extends StatelessWidget {
  final bool isDark;

  final VoidCallback onTap;

  const ChatListGradientFab({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkPrimary, AppColors.accentRose]
              : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                .withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_comment_rounded,
                  color: isDark ? AppColors.darkOnPrimary : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.startNewChat,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.darkOnPrimary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

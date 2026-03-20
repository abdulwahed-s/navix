import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class InvitationStatusBadge extends StatelessWidget {
  final String actionStatus;

  const InvitationStatusBadge({super.key, required this.actionStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAccepted = actionStatus == 'accepted';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAccepted
            ? AppColors.success.withValues(alpha: 0.15)
            : theme.colorScheme.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: isAccepted ? AppColors.success : theme.colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Text(
            isAccepted ? l10n.invitationAccepted : l10n.invitationDeclined,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isAccepted ? AppColors.success : theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

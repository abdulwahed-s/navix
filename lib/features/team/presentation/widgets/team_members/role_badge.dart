import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final bool isLeader;
  final String leaderLabel;
  final String memberLabel;

  const RoleBadge({
    super.key,
    required this.isLeader,
    required this.leaderLabel,
    required this.memberLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: isLeader
            ? LinearGradient(
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.2),
                  AppColors.accentGold.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isLeader
            ? null
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeader)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.star_rounded,
                size: 12,
                color: AppColors.accentGold,
              ),
            ),
          Text(
            isLeader ? leaderLabel : memberLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isLeader
                  ? AppColors.accentGold
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

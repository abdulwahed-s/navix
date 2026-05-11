import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/repositories/team_repository.dart';
import 'role_badge.dart';

class TeamMemberCard extends StatelessWidget {
  final TeamMemberInfo member;
  final bool isDark;
  final String leaderLabel;
  final String memberLabel;
  final String assignedTasksLabel;
  final String completionRateLabel;
  final String makeLeaderLabel;
  final String removeMemberLabel;
  final VoidCallback? onMakeLeader;
  final VoidCallback? onRemove;

  const TeamMemberCard({
    super.key,
    required this.member,
    required this.isDark,
    required this.leaderLabel,
    required this.memberLabel,
    required this.assignedTasksLabel,
    required this.completionRateLabel,
    required this.makeLeaderLabel,
    required this.removeMemberLabel,
    this.onMakeLeader,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLeader = member.role == MemberRole.leader;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isLeader
                    ? AppColors.accentGold.withValues(alpha: 0.3)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(theme, isLeader),
                const SizedBox(width: 14),
                Expanded(child: _buildMemberInfo(theme, isLeader)),
                if (!isLeader) _buildActionsMenu(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isLeader) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isLeader
            ? LinearGradient(
                colors: [AppColors.accentGold, theme.colorScheme.primary],
              )
            : null,
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: member.avatarUrl != null
            ? NetworkImage(member.avatarUrl!)
            : null,
        child: member.avatarUrl == null
            ? Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildMemberInfo(ThemeData theme, bool isLeader) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                member.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            RoleBadge(
              isLeader: isLeader,
              leaderLabel: leaderLabel,
              memberLabel: memberLabel,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              assignedTasksLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                completionRateLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'remove') {
          onRemove?.call();
        } else if (value == 'makeLeader') {
          onMakeLeader?.call();
        }
      },
      icon: Icon(
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'makeLeader',
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.accentGold),
              const SizedBox(width: 10),
              Text(makeLeaderLabel),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove_rounded, color: AppColors.riskHigh),
              const SizedBox(width: 10),
              Text(
                removeMemberLabel,
                style: const TextStyle(color: AppColors.riskHigh),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

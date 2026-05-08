import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../domain/entities/connection_status.dart';
import 'connection_status_widget.dart';

class UserCard extends StatelessWidget {
  final ProfileEntity user;

  final ConnectionStatus connectionStatus;

  final bool isDark;

  final int skillColorIndex;

  final VoidCallback onConnect;

  final VoidCallback? onCancelConnection;

  final VoidCallback? onRemoveConnection;

  const UserCard({
    super.key,
    required this.user,
    required this.connectionStatus,
    required this.isDark,
    required this.skillColorIndex,
    required this.onConnect,
    this.onCancelConnection,
    this.onRemoveConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.push(AppRoutes.profile, extra: user);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _UserAvatar(user: user),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _UserInfo(
                          user: user,
                          isDark: isDark,
                          skillColorIndex: skillColorIndex,
                        ),
                      ),
                      ConnectionStatusWidget(
                        connectionStatus: connectionStatus,
                        isDark: isDark,
                        onConnect: onConnect,
                        onCancelConnection: onCancelConnection,
                        onRemoveConnection: onRemoveConnection,
                      ),
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
}

class _UserAvatar extends StatelessWidget {
  final ProfileEntity user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: user.profilePicUrl != null
            ? CachedNetworkImageProvider(user.profilePicUrl!)
            : null,
        child: user.profilePicUrl == null
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final ProfileEntity user;
  final bool isDark;
  final int skillColorIndex;

  const _UserInfo({
    required this.user,
    required this.isDark,
    required this.skillColorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final approvedSkills = user.skills.where((s) => s.isApproved).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if ((user.organization ?? '').isNotEmpty)
          Text(
            user.organization!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 10),
        if (approvedSkills.isNotEmpty)
          _SkillTags(
            skills: approvedSkills,
            isDark: isDark,
            colorIndex: skillColorIndex,
          ),
      ],
    );
  }
}

class _SkillTags extends StatelessWidget {
  final List<SkillEntity> skills;
  final bool isDark;
  final int colorIndex;

  const _SkillTags({
    required this.skills,
    required this.isDark,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final accentColors = [
      AppColors.accentLavender,
      AppColors.accentMint,
      AppColors.accentGold,
      AppColors.accentRose,
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: skills.take(3).toList().asMap().entries.map((entry) {
        final skill = entry.value;
        final color = accentColors[(colorIndex + entry.key) % 4];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (skill.isVerified)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.verified,
                    size: 10,
                    color: isDark ? color : color.withValues(alpha: 0.8),
                  ),
                ),
              Text(
                skill.skillName,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? color : color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (skill.isVerified && skill.skillLevel != null) ...[
                const SizedBox(width: 4),
                Text(
                  skill.skillLevel!.displayName[0],
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? color.withValues(alpha: 0.7)
                        : color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

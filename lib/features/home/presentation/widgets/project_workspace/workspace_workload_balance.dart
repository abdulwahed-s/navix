import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../profile/domain/entities/profile_entity.dart';

class MemberWorkload {
  final String memberId;
  final String memberName;
  final int taskCount;
  final bool isLeader;

  const MemberWorkload({
    required this.memberId,
    required this.memberName,
    required this.taskCount,
    this.isLeader = false,
  });
}

class WorkspaceWorkloadBalance extends StatelessWidget {
  final List<MemberWorkload> workloads;
  final int totalTasks;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceWorkloadBalance({
    super.key,
    required this.workloads,
    required this.totalTasks,
    required this.fetchUserProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (workloads.isEmpty) {
      return const _EmptyState(
        icon: Icons.people_outline,
        title: 'No team members',
      );
    }

    final maxTasks = workloads.map((w) => w.taskCount).reduce(math.max);
    final memberCount = workloads.length;
    final idealTaskCount = memberCount > 0
        ? (totalTasks / memberCount).round()
        : 0;

    final isBalanced = _isWorkloadBalanced(workloads, idealTaskCount);

    final statusColor = isBalanced ? AppColors.successDark : AppColors.warningDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isBalanced ? Icons.balance : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBalanced
                          ? l10n.workloadBalanced
                          : l10n.workloadUnbalanced,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.idealDistribution(idealTaskCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...workloads.map(
          (workload) =>
              _buildWorkloadBar(context, workload, maxTasks, idealTaskCount),
        ),
      ],
    );
  }

  Widget _buildWorkloadBar(
    BuildContext context,
    MemberWorkload workload,
    int maxTasks,
    int idealTaskCount,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final barWidth = maxTasks > 0 ? workload.taskCount / maxTasks : 0.0;
    final isOverloaded = workload.taskCount > idealTaskCount * 1.5;
    final isUnderloaded = workload.taskCount < idealTaskCount * 0.5;

    Color barColor;
    if (isOverloaded) {
      barColor = AppColors.lightError;
    } else if (isUnderloaded && workload.taskCount > 0) {
      barColor = AppColors.infoDark;
    } else {
      barColor = theme.colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FutureBuilder<ProfileEntity?>(
                future: fetchUserProfile(workload.memberId),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: profile?.profilePicUrl != null
                        ? CachedNetworkImageProvider(profile!.profilePicUrl!)
                        : null,
                    child: profile?.profilePicUrl == null
                        ? Text(
                            workload.memberName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            workload.memberName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (workload.isLeader) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.projectLeader,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${workload.taskCount} ${workload.taskCount == 1 ? 'task' : 'tasks'} assigned',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: barColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${workload.taskCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated workload bar
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: barWidth.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isWorkloadBalanced(List<MemberWorkload> workloads, int idealCount) {
    if (workloads.isEmpty || idealCount == 0) return true;

    final threshold = (idealCount * 0.5).ceil();
    for (final workload in workloads) {
      if ((workload.taskCount - idealCount).abs() > threshold) {
        return false;
      }
    }
    return true;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _EmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

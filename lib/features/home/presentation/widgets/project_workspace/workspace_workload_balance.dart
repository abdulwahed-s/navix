import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'No team members',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final maxTasks = workloads.map((w) => w.taskCount).reduce(math.max);
    final memberCount = workloads.length;
    final idealTaskCount = memberCount > 0
        ? (totalTasks / memberCount).round()
        : 0;

    final isBalanced = _isWorkloadBalanced(workloads, idealTaskCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isBalanced
                  ? [
                      Colors.green.withValues(alpha: 0.12),
                      Colors.green.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.orange.withValues(alpha: 0.12),
                      Colors.orange.withValues(alpha: 0.04),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBalanced
                  ? Colors.green.withValues(alpha: 0.25)
                  : Colors.orange.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isBalanced
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isBalanced ? Icons.balance : Icons.warning_amber_rounded,
                  color: isBalanced ? Colors.green : Colors.orange,
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
                        color: isBalanced
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
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
      barColor = Colors.red;
    } else if (isUnderloaded && workload.taskCount > 0) {
      barColor = Colors.blue;
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
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                ],
                              ),
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

          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              FractionallySizedBox(
                widthFactor: barWidth.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [barColor, barColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../profile/domain/entities/profile_entity.dart';
import '../../../../project/domain/entities/project_entity.dart';
import '../../../../project/domain/entities/project_roadmap_entity.dart';
import 'workspace_activity_feed.dart';
import 'workspace_deadline_alerts.dart';
import 'workspace_milestone_overview.dart';
import 'workspace_risk_section.dart';
import 'workspace_team_management.dart';
import 'workspace_workload_balance.dart';

class WorkspaceAdminDashboard extends StatelessWidget {
  final ProjectEntity project;
  final ProjectRoadmapEntity roadmap;
  final List<Map<String, String>> roleAssignments;
  final Future<String> Function(String userId) fetchUserName;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceAdminDashboard({
    super.key,
    required this.project,
    required this.roadmap,
    required this.roleAssignments,
    required this.fetchUserName,
    required this.fetchUserProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkspaceTeamManagement(
            project: project,
            roadmap: roadmap,
            roleAssignments: roleAssignments,
            fetchUserProfile: fetchUserProfile,
          ),
          const SizedBox(height: 28),

          _DashboardSection(
            title: l10n.nearingDeadlines,
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
            child: WorkspaceDeadlineAlerts(
              tasks: roadmap.tasks,
              fetchUserName: fetchUserName,
              fetchUserProfile: fetchUserProfile,
            ),
          ),
          const SizedBox(height: 28),

          _DashboardSection(
            title: l10n.workloadBalance,
            icon: Icons.balance,
            iconColor: theme.colorScheme.primary,
            child: _buildWorkloadBalanceSection(),
          ),
          const SizedBox(height: 28),

          _DashboardSection(
            title: l10n.milestoneOverview,
            icon: Icons.flag,
            iconColor: Colors.deepPurple,
            child: WorkspaceMilestoneOverview(
              milestones: roadmap.milestones,
              tasks: roadmap.tasks,
            ),
          ),
          const SizedBox(height: 28),

          _DashboardSection(
            title: l10n.activityFeed,
            icon: Icons.history,
            iconColor: Colors.teal,
            child: WorkspaceActivityFeed(
              projectId: project.id,
              fetchUserName: fetchUserName,
              fetchUserProfile: fetchUserProfile,
            ),
          ),
          const SizedBox(height: 28),

          WorkspaceRiskSection(
            projectId: project.id,
            projectName: project.name,
            roadmap: roadmap,
            startDate: project.startDate,
            endDate: project.endDate,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkloadBalanceSection() {
    final allMemberIds = [project.leaderId, ...project.memberIds];
    final workloads = <MemberWorkload>[];

    for (var i = 0; i < allMemberIds.length; i++) {
      final userId = allMemberIds[i];
      final isLeader = i == 0;
      final taskCount = roadmap.tasks
          .where((task) => task.assignedTo == userId)
          .length;

      workloads.add(
        MemberWorkload(
          memberId: userId,
          memberName: userId,
          taskCount: taskCount,
          isLeader: isLeader,
        ),
      );
    }

    return FutureBuilder<List<MemberWorkload>>(
      future: _fetchWorkloadsWithNames(workloads),
      builder: (context, snapshot) {
        final resolvedWorkloads = snapshot.data ?? workloads;
        return WorkspaceWorkloadBalance(
          workloads: resolvedWorkloads,
          totalTasks: roadmap.tasks.length,
          fetchUserProfile: fetchUserProfile,
        );
      },
    );
  }

  Future<List<MemberWorkload>> _fetchWorkloadsWithNames(
    List<MemberWorkload> workloads,
  ) async {
    final result = <MemberWorkload>[];
    for (final workload in workloads) {
      final name = await fetchUserName(workload.memberId);
      result.add(
        MemberWorkload(
          memberId: workload.memberId,
          memberName: name,
          taskCount: workload.taskCount,
          isLeader: workload.isLeader,
        ),
      );
    }
    return result;
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withValues(alpha: 0.15),
                iconColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

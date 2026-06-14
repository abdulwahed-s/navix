import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
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

class WorkspaceAdminDashboard extends StatefulWidget {
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
  State<WorkspaceAdminDashboard> createState() =>
      _WorkspaceAdminDashboardState();
}

class _WorkspaceAdminDashboardState extends State<WorkspaceAdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot 0 — summary stats
          _SectionReveal(
            index: 0,
            controller: _staggerController,
            child: _DashboardSummaryCard(
              project: widget.project,
              roadmap: widget.roadmap,
            ),
          ),
          const SizedBox(height: 20),

          // Slot 1 — team management
          _SectionReveal(
            index: 1,
            controller: _staggerController,
            child: WorkspaceTeamManagement(
              project: widget.project,
              roadmap: widget.roadmap,
              roleAssignments: widget.roleAssignments,
              fetchUserProfile: widget.fetchUserProfile,
            ),
          ),
          const SizedBox(height: 28),

          // Slot 2 — deadline alerts
          _SectionReveal(
            index: 2,
            controller: _staggerController,
            child: _DashboardSection(
              title: l10n.nearingDeadlines,
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warningDark,
              child: WorkspaceDeadlineAlerts(
                tasks: widget.roadmap.tasks,
                fetchUserName: widget.fetchUserName,
                fetchUserProfile: widget.fetchUserProfile,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Slot 3 — workload balance
          _SectionReveal(
            index: 3,
            controller: _staggerController,
            child: _DashboardSection(
              title: l10n.workloadBalance,
              icon: Icons.balance,
              iconColor: theme.colorScheme.primary,
              child: _buildWorkloadBalanceSection(),
            ),
          ),
          const SizedBox(height: 28),

          // Slot 4 — milestone overview
          _SectionReveal(
            index: 4,
            controller: _staggerController,
            child: _DashboardSection(
              title: l10n.milestoneOverview,
              icon: Icons.flag,
              iconColor: AppColors.infoDark,
              child: WorkspaceMilestoneOverview(
                milestones: widget.roadmap.milestones,
                tasks: widget.roadmap.tasks,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Slot 5 — activity feed
          _SectionReveal(
            index: 5,
            controller: _staggerController,
            child: _DashboardSection(
              title: l10n.activityFeed,
              icon: Icons.history,
              iconColor: AppColors.successDark,
              child: WorkspaceActivityFeed(
                projectId: widget.project.id,
                fetchUserName: widget.fetchUserName,
                fetchUserProfile: widget.fetchUserProfile,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Slot 6 — risk prediction
          _SectionReveal(
            index: 6,
            controller: _staggerController,
            child: _DashboardSection(
              title: l10n.riskPrediction,
              icon: Icons.shield_outlined,
              iconColor: AppColors.riskCritical,
              child: WorkspaceRiskSection(
                projectId: widget.project.id,
                projectName: widget.project.name,
                roadmap: widget.roadmap,
                startDate: widget.project.startDate,
                endDate: widget.project.endDate,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWorkloadBalanceSection() {
    final allMemberIds = [widget.project.leaderId, ...widget.project.memberIds];
    final workloads = <MemberWorkload>[];

    for (var i = 0; i < allMemberIds.length; i++) {
      final userId = allMemberIds[i];
      final isLeader = i == 0;
      final taskCount = widget.roadmap.tasks
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
          totalTasks: widget.roadmap.tasks.length,
          fetchUserProfile: widget.fetchUserProfile,
        );
      },
    );
  }

  Future<List<MemberWorkload>> _fetchWorkloadsWithNames(
    List<MemberWorkload> workloads,
  ) async {
    final result = <MemberWorkload>[];
    for (final workload in workloads) {
      final name = await widget.fetchUserName(workload.memberId);
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

// ─── Staggered section reveal ────────────────────────────────────────────────

class _SectionReveal extends StatelessWidget {
  final int index;
  final Animation<double> controller;
  final Widget child;

  const _SectionReveal({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.10).clamp(0.0, 0.65);
    final end = (start + 0.35).clamp(0.0, 1.0);

    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curve);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

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
        Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ─── Summary stats card ───────────────────────────────────────────────────────

class _DashboardSummaryCard extends StatelessWidget {
  final ProjectEntity project;
  final ProjectRoadmapEntity roadmap;

  const _DashboardSummaryCard({
    required this.project,
    required this.roadmap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysLeft = project.endDate.difference(now).inDays.clamp(0, 9999);
    final totalTasks = roadmap.tasks.length;
    final completedPct = (project.completionPercentage * 100).toInt();
    final teamSize = 1 + project.memberIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.task_alt,
            value: '$totalTasks',
            label: 'Tasks',
            color: theme.colorScheme.primary,
          ),
          _StatDivider(),
          _StatChip(
            icon: Icons.percent,
            value: '$completedPct%',
            label: 'Done',
            color: AppColors.successDark,
          ),
          _StatDivider(),
          _StatChip(
            icon: Icons.group_outlined,
            value: '$teamSize',
            label: 'Members',
            color: AppColors.infoDark,
          ),
          _StatDivider(),
          _StatChip(
            icon: Icons.event_outlined,
            value: '$daysLeft',
            label: daysLeft == 1 ? 'Day left' : 'Days left',
            color: daysLeft <= 7
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

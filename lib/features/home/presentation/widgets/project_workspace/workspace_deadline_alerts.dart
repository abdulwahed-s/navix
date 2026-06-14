import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../profile/domain/entities/profile_entity.dart';
import '../../../../project/domain/entities/task_entity.dart';

class WorkspaceDeadlineAlerts extends StatelessWidget {
  final List<TaskEntity> tasks;
  final Future<String> Function(String userId) fetchUserName;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceDeadlineAlerts({
    super.key,
    required this.tasks,
    required this.fetchUserName,
    required this.fetchUserProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nearDeadlineTasks = tasks.where((task) {
      if (task.deadline == null) return false;
      if (task.status == TaskStatus.completed) return false;
      final daysLeft = task.deadline!.difference(today).inDays;
      return daysLeft >= 0 && daysLeft <= 7;
    }).toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    if (nearDeadlineTasks.isEmpty) {
      return _buildSuccessState(l10n, Theme.of(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nearDeadlineTasks.map((task) {
        final daysLeft = task.deadline!.difference(today).inDays;
        return _DeadlineAlertCard(
          task: task,
          daysLeft: daysLeft,
          fetchUserProfile: fetchUserProfile,
          l10n: l10n,
        );
      }).toList(),
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successDark.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.successDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.successDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noNearingDeadlines,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All tasks are on track!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.successDark.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _getAlertColor(int daysLeft) {
  if (daysLeft <= 1) return AppColors.lightError;
  if (daysLeft <= 3) return AppColors.warningDark;
  return AppColors.warning;
}

class _DeadlineAlertCard extends StatefulWidget {
  final TaskEntity task;
  final int daysLeft;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;
  final AppLocalizations l10n;

  const _DeadlineAlertCard({
    required this.task,
    required this.daysLeft,
    required this.fetchUserProfile,
    required this.l10n,
  });

  @override
  State<_DeadlineAlertCard> createState() => _DeadlineAlertCardState();
}

class _DeadlineAlertCardState extends State<_DeadlineAlertCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.daysLeft == 0) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);

      _pulseAnimation = Tween<double>(
        begin: 0.6,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertColor = _getAlertColor(widget.daysLeft);
    final isUrgent = widget.daysLeft <= 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: alertColor.withValues(alpha: 0.06),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.35),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUrgent ? Icons.warning_rounded : Icons.schedule,
                color: alertColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (widget.task.assignedTo != null)
                    FutureBuilder<ProfileEntity?>(
                      future: widget.fetchUserProfile(widget.task.assignedTo!),
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        return Row(
                          children: [
                            if (profile?.profilePicUrl != null)
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: CachedNetworkImageProvider(
                                  profile!.profilePicUrl!,
                                ),
                              )
                            else
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  (profile?.name ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                profile?.name ?? '...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 16,
                          color: theme.colorScheme.error.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.l10n.unassigned,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            _buildUrgencyBadge(alertColor),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge(Color alertColor) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: alertColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.daysLeft == 0
            ? widget.l10n.dueToday
            : widget.l10n.daysLeft(widget.daysLeft),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );

    if (_pulseAnimation == null) return badge;

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) =>
          Opacity(opacity: _pulseAnimation!.value, child: child),
      child: badge,
    );
  }
}

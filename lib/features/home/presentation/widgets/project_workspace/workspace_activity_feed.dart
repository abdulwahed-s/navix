import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../profile/domain/entities/profile_entity.dart';

class ActivityItem {
  final String id;
  final ActivityType type;
  final String userId;
  final String userName;
  final String? userProfilePicUrl;
  final String taskId;
  final String taskName;
  final String? newStatus;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    this.userProfilePicUrl,
    required this.taskId,
    required this.taskName,
    this.newStatus,
    required this.timestamp,
  });
}

enum ActivityType { taskCompleted, taskStatusChanged, taskAssigned }

class WorkspaceActivityFeed extends StatefulWidget {
  final String projectId;
  final Future<String> Function(String userId) fetchUserName;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceActivityFeed({
    super.key,
    required this.projectId,
    required this.fetchUserName,
    required this.fetchUserProfile,
  });

  @override
  State<WorkspaceActivityFeed> createState() => _WorkspaceActivityFeedState();
}

class _WorkspaceActivityFeedState extends State<WorkspaceActivityFeed> {
  final List<ActivityItem> _activities = [];
  bool _isLoading = true;
  bool _hasMore = true;
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('tasks')
          .orderBy('updatedAt', descending: true)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      _lastDocument = snapshot.docs.last;

      final newActivities = <ActivityItem>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final updatedAt = data['updatedAt'] as Timestamp?;
        final status = data['status'] as String?;
        final assignedTo = data['assignedTo'] as String?;
        final lastUpdatedBy = data['lastUpdatedBy'] as String?;
        final taskName = data['name'] as String? ?? 'Unknown Task';

        if (updatedAt == null) continue;

        ActivityType type;

        String userId = lastUpdatedBy ?? assignedTo ?? '';
        String? newStatus;

        if (status == 'completed') {
          type = ActivityType.taskCompleted;
        } else if (status != null) {
          type = ActivityType.taskStatusChanged;
          newStatus = status;
        } else if (assignedTo != null) {
          type = ActivityType.taskAssigned;
        } else {
          continue;
        }

        String userName = 'Unknown';
        String? userProfilePicUrl;
        if (userId.isNotEmpty) {
          try {
            final profile = await widget.fetchUserProfile(userId);
            userName = profile?.name ?? 'Unknown';
            userProfilePicUrl = profile?.profilePicUrl;
          } catch (_) {
            try {
              userName = await widget.fetchUserName(userId);
            } catch (_) {}
          }
        }

        newActivities.add(
          ActivityItem(
            id: doc.id,
            type: type,
            userId: userId,
            userName: userName,
            userProfilePicUrl: userProfilePicUrl,
            taskId: doc.id,
            taskName: taskName,
            newStatus: newStatus,
            timestamp: updatedAt.toDate(),
          ),
        );
      }

      setState(() {
        _activities.addAll(newActivities);
        _hasMore = snapshot.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading && _activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_activities.isEmpty) {
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
              Icons.history,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.noRecentActivity,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _activities.length; i++)
          _buildActivityTile(
            context,
            _activities[i],
            isFirst: i == 0,
            isLast: i == _activities.length - 1 && !_hasMore,
          ),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadActivities,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more, size: 20),
                label: Text(l10n.loadMore),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityTile(
    BuildContext context,
    ActivityItem activity, {
    required bool isFirst,
    required bool isLast,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    IconData icon;
    Color iconColor;
    String description;

    switch (activity.type) {
      case ActivityType.taskCompleted:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        description = l10n.taskCompletedActivity(
          activity.userName,
          activity.taskName,
        );
        break;
      case ActivityType.taskStatusChanged:
        icon = Icons.sync;
        iconColor = Colors.blue;
        description = l10n.taskStatusChangedActivity(
          activity.userName,
          activity.taskName,
          activity.newStatus ?? '',
        );
        break;
      case ActivityType.taskAssigned:
        icon = Icons.person_add;
        iconColor = Colors.purple;
        description = l10n.taskAssignedActivity(
          activity.taskName,
          activity.userName,
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 8,
                    color: theme.colorScheme.outlineVariant,
                  ),

                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.08),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activity.userProfilePicUrl != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider(
                        activity.userProfilePicUrl!,
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: iconColor.withValues(alpha: 0.2),
                      child: Icon(icon, color: iconColor, size: 16),
                    ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(activity.timestamp),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

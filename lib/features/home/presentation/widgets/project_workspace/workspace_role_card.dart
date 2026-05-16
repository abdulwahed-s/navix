import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../project/domain/entities/project_role_entity.dart';

class WorkspaceRoleCard extends StatefulWidget {
  final ProjectRoleEntity role;
  final VoidCallback onAssignPressed;

  const WorkspaceRoleCard({
    super.key,
    required this.role,
    required this.onAssignPressed,
  });

  @override
  State<WorkspaceRoleCard> createState() => _WorkspaceRoleCardState();
}

class _WorkspaceRoleCardState extends State<WorkspaceRoleCard> {
  String? _photoUrl;
  bool _isLoadingPhoto = true;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  @override
  void didUpdateWidget(WorkspaceRoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role.assignedUserId != widget.role.assignedUserId) {
      _loadProfilePicture();
    }
  }

  Future<void> _loadProfilePicture() async {
    if (widget.role.assignedUserId == null ||
        widget.role.assignedUserId!.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingPhoto = false);
      }
      return;
    }

    setState(() => _isLoadingPhoto = true);

    try {
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.role.assignedUserId)
          .collection('profile')
          .doc('main')
          .get();

      if (userProfileDoc.exists && mounted) {
        setState(() {
          _photoUrl = userProfileDoc.data()?['profilePicUrl'] as String?;
          _isLoadingPhoto = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingPhoto = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAssigned =
        widget.role.assignedUserId != null &&
        widget.role.assignedUserId!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.role.roleName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tasksForRole(widget.role.taskCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned To',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isAssigned)
                        _isLoadingPhoto
                            ? ShimmerLoading(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 14,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    backgroundImage: _photoUrl != null
                                        ? CachedNetworkImageProvider(_photoUrl!)
                                        : null,
                                    child: _photoUrl == null
                                        ? Text(
                                            (widget.role.assignedUserName ??
                                                    'U')[0]
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.role.assignedUserName ??
                                        l10n.unassigned,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              )
                      else
                        Text(
                          l10n.unassigned,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: widget.onAssignPressed,
                  icon: Icon(isAssigned ? Icons.swap_horiz : Icons.person_add),
                  label: Text(isAssigned ? 'Reassign' : l10n.assignMember),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

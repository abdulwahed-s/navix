import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../../l10n/app_localizations.dart';

class TaskReassignDialog extends StatefulWidget {
  final List<String> memberIds;
  final String leaderId;
  final String? currentAssignee;
  final void Function(String userId) onReassign;

  const TaskReassignDialog({
    super.key,
    required this.memberIds,
    required this.leaderId,
    required this.currentAssignee,
    required this.onReassign,
  });

  @override
  State<TaskReassignDialog> createState() => _TaskReassignDialogState();
}

class _TaskReassignDialogState extends State<TaskReassignDialog> {
  final Map<String, _UserProfile> _profiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllProfiles();
  }

  Future<void> _loadAllProfiles() async {
    final allUserIds = [widget.leaderId, ...widget.memberIds];

    for (final userId in allUserIds) {
      try {
        final userProfileDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('main')
            .get();

        if (userProfileDoc.exists && mounted) {
          setState(() {
            _profiles[userId] = _UserProfile(
              name: userProfileDoc.data()?['name'] as String? ?? 'Unknown',
              photoUrl: userProfileDoc.data()?['profilePicUrl'] as String?,
            );
          });
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final allUserIds = [widget.leaderId, ...widget.memberIds];

    return AlertDialog(
      title: Text(l10n.reassignTask),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading && _profiles.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  allUserIds.length.clamp(1, 4),
                  (_) => const _MemberListItemSkeleton(),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: allUserIds.length,
                itemBuilder: (context, index) {
                  final isLeader = index == 0;
                  final userId = allUserIds[index];
                  final isCurrentlyAssigned = userId == widget.currentAssignee;
                  final profile = _profiles[userId];

                  if (profile == null) {
                    return const _MemberListItemSkeleton();
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentlyAssigned
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: profile.photoUrl != null
                          ? CachedNetworkImageProvider(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null
                          ? Text(
                              profile.name[0].toUpperCase(),
                              style: TextStyle(
                                color: isCurrentlyAssigned
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                    ),
                    title: Text(profile.name),
                    subtitle: Text(
                      isLeader ? l10n.projectLeader : l10n.projectMember,
                    ),
                    trailing: isCurrentlyAssigned
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      widget.onReassign(userId);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _UserProfile {
  final String name;
  final String? photoUrl;

  const _UserProfile({required this.name, this.photoUrl});
}

class _MemberListItemSkeleton extends StatelessWidget {
  const _MemberListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white),
        title: Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

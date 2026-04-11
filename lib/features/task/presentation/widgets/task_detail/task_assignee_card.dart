import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../../l10n/app_localizations.dart';

class TaskAssigneeCard extends StatefulWidget {
  final String? assignedTo;
  final bool showReassignButton;
  final VoidCallback onReassign;

  const TaskAssigneeCard({
    super.key,
    required this.assignedTo,
    this.showReassignButton = true,
    required this.onReassign,
  });

  @override
  State<TaskAssigneeCard> createState() => _TaskAssigneeCardState();
}

class _TaskAssigneeCardState extends State<TaskAssigneeCard> {
  String? _userName;
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void didUpdateWidget(TaskAssigneeCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assignedTo != widget.assignedTo) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (widget.assignedTo == null || widget.assignedTo!.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.assignedTo)
          .collection('profile')
          .doc('main')
          .get();

      if (userProfileDoc.exists && mounted) {
        setState(() {
          _userName = userProfileDoc.data()?['name'] as String? ?? 'Unknown';
          _photoUrl = userProfileDoc.data()?['profilePicUrl'] as String?;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _userName = 'Unknown';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userName = 'Unknown';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (widget.assignedTo == null || widget.assignedTo!.isEmpty) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.person_off,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(l10n.assignedTo),
          subtitle: Text(l10n.unassigned),
          trailing: widget.showReassignButton
              ? IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: widget.onReassign,
                  tooltip: l10n.reassignTask,
                )
              : null,
        ),
      );
    }

    if (_isLoading) {
      return ShimmerLoading(
        child: Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(
              height: 14,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: _photoUrl != null
              ? CachedNetworkImageProvider(_photoUrl!)
              : null,
          child: _photoUrl == null && _userName != null
              ? Text(
                  _userName![0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(l10n.assignedTo),
        subtitle: Text(_userName ?? 'Unknown'),
        trailing: widget.showReassignButton
            ? IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: widget.onReassign,
                tooltip: l10n.reassignTask,
              )
            : null,
      ),
    );
  }
}

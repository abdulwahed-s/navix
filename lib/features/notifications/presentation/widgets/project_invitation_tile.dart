import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import 'project_invitation/invitation_action_buttons.dart';
import 'project_invitation/invitation_header.dart';
import 'project_invitation/invitation_status_badge.dart';

class ProjectInvitationTile extends StatefulWidget {
  final NotificationEntity notification;

  final VoidCallback onAccept;

  final VoidCallback onReject;

  final bool isDark;

  const ProjectInvitationTile({
    super.key,
    required this.notification,
    required this.onAccept,
    required this.onReject,
    required this.isDark,
  });

  @override
  State<ProjectInvitationTile> createState() => _ProjectInvitationTileState();
}

class _ProjectInvitationTileState extends State<ProjectInvitationTile> {
  String? _inviterName;
  String? _inviterProfilePicUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInviterProfile();
  }

  Future<void> _loadInviterProfile() async {
    final inviterId = widget.notification.data['inviterId'] as String?;
    if (inviterId == null || inviterId.isEmpty) {
      setState(() {
        _inviterName =
            widget.notification.data['inviterName'] as String? ?? 'Someone';
        _isLoading = false;
      });
      return;
    }

    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(inviterId)
          .collection('profile')
          .doc('main')
          .get();

      if (profileDoc.exists && mounted) {
        final data = profileDoc.data()!;
        setState(() {
          _inviterName =
              data['name'] as String? ??
              widget.notification.data['inviterName'] as String? ??
              'Someone';
          _inviterProfilePicUrl = data['profilePicUrl'] as String?;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _inviterName =
              widget.notification.data['inviterName'] as String? ?? 'Someone';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _inviterName =
              widget.notification.data['inviterName'] as String? ?? 'Someone';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectName =
        widget.notification.data['projectName'] as String? ?? 'Project';
    final inviterName =
        _inviterName ??
        widget.notification.data['inviterName'] as String? ??
        'Someone';
    final message = widget.notification.data['message'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.notification.read
                  ? (widget.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.7))
                  : (widget.isDark
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.15,
                          )
                        : theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.4,
                          )),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InvitationHeader(
                  title: widget.notification.title,
                  inviterName: inviterName,
                  inviterProfilePicUrl: _inviterProfilePicUrl,
                  projectName: projectName,
                  formattedTime: _formatTime(widget.notification.createdAt),
                  isRead: widget.notification.read,
                  message: message,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                if (widget.notification.actionStatus != null)
                  InvitationStatusBadge(
                    actionStatus: widget.notification.actionStatus!,
                  )
                else
                  InvitationActionButtons(
                    onAccept: widget.onAccept,
                    onReject: widget.onReject,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project_join_request_entity.dart';

class JoinRequestCard extends StatefulWidget {
  final ProjectJoinRequestEntity request;
  final void Function(bool accepted) onRespond;

  const JoinRequestCard({
    super.key,
    required this.request,
    required this.onRespond,
  });

  @override
  State<JoinRequestCard> createState() => _JoinRequestCardState();
}

class _JoinRequestCardState extends State<JoinRequestCard> {
  String? _applicantName;
  String? _applicantAvatar;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadApplicantProfile();
  }

  Future<void> _loadApplicantProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.request.applicantId)
          .collection('profile')
          .doc('main')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _applicantName = doc.data()?['name'] as String?;
          _applicantAvatar = doc.data()?['profilePicUrl'] as String?;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    backgroundImage: _applicantAvatar != null
                        ? CachedNetworkImageProvider(_applicantAvatar!)
                        : null,
                    child: _applicantAvatar == null
                        ? Text(
                            (_applicantName ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          )
                        : null,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _applicantName ?? l10n.loading,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.request.roleName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (widget.request.message != null &&
                widget.request.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.request.message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (mounted) setState(() => _isProcessing = true);
                            widget.onRespond(false);
                          },
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(l10n.denyRequest),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (mounted) setState(() => _isProcessing = true);
                            widget.onRespond(true);
                          },
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(l10n.acceptRequest),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

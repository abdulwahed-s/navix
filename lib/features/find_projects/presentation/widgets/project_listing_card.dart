import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project_listing_entity.dart';

class ProjectListingCard extends StatefulWidget {
  final ProjectListingEntity listing;
  final VoidCallback? onApplied;

  const ProjectListingCard({super.key, required this.listing, this.onApplied});

  @override
  State<ProjectListingCard> createState() => _ProjectListingCardState();
}

class _ProjectListingCardState extends State<ProjectListingCard> {
  String? _leaderName;
  String? _leaderAvatar;
  bool _isLoadingLeader = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderProfile();
  }

  Future<void> _loadLeaderProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.listing.leaderId)
          .collection('profile')
          .doc('main')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _leaderName = doc.data()?['name'] as String?;
          _leaderAvatar = doc.data()?['profilePicUrl'] as String?;
          _isLoadingLeader = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingLeader = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLeader = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final listing = widget.listing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey.shade900.withValues(alpha: 0.8),
                  Colors.grey.shade800.withValues(alpha: 0.6),
                ]
              : [Colors.white, Colors.grey.shade50.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.projectName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          if (_isLoadingLeader)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          else ...[
                            CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              backgroundImage: _leaderAvatar != null
                                  ? CachedNetworkImageProvider(_leaderAvatar!)
                                  : null,
                              child: _leaderAvatar == null
                                  ? Text(
                                      (_leaderName ?? '?')[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _leaderName ?? l10n.loading,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        AppColors.accentGold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${listing.openRoles.length} ${listing.openRoles.length == 1 ? 'role' : 'roles'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              listing.projectDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (listing.leaderMessage != null &&
                listing.leaderMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        listing.leaderMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            Text(
              l10n.openRoles,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: listing.openRoles.map((role) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role.roleName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.darkPrimary, AppColors.accentRose]
                        : [theme.colorScheme.primary, AppColors.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: listing.hasApplied ? null : widget.onApplied,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            listing.hasApplied
                                ? Icons.check_circle_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            listing.hasApplied
                                ? 'Already Applied'
                                : l10n.applyToProject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

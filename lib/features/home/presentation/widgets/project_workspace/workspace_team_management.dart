import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../find_people/presentation/bloc/user_discovery_bloc.dart';
import '../../../../profile/domain/entities/profile_entity.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../project/domain/entities/project_entity.dart';
import '../../../../project/domain/entities/project_roadmap_entity.dart';
import '../../bloc/workspace_bloc.dart';
import '../../../../team/data/datasources/team_analysis_datasource.dart';
import '../../../../team/domain/entities/team_analysis_entity.dart';
import '../../../../team/presentation/bloc/team_bloc.dart';
import '../../../../team/presentation/widgets/invite_user_dialog.dart';
import '../../../../find_projects/domain/entities/open_role.dart';
import '../../../../find_projects/domain/entities/project_join_request_entity.dart';
import '../../../../find_projects/domain/entities/project_listing_entity.dart';
import '../../../../find_projects/presentation/bloc/find_projects_bloc.dart';
import '../../../../find_projects/presentation/widgets/publish_listing_dialog.dart';
import '../../../../find_projects/presentation/widgets/join_request_card.dart';

class WorkspaceTeamManagement extends StatefulWidget {
  final ProjectEntity project;
  final ProjectRoadmapEntity roadmap;
  final List<Map<String, String>> roleAssignments;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceTeamManagement({
    super.key,
    required this.project,
    required this.roadmap,
    required this.roleAssignments,
    required this.fetchUserProfile,
  });

  @override
  State<WorkspaceTeamManagement> createState() =>
      _WorkspaceTeamManagementState();
}

class _WorkspaceTeamManagementState extends State<WorkspaceTeamManagement> {
  TeamAnalysisEntity? _analysis;
  bool _isAnalyzing = false;
  bool _isLoadingMembers = true;
  bool _isLoadingPendingInvites = true;
  Map<String, ProfileEntity> _memberProfiles = {};
  List<_PendingInvite> _pendingInvites = [];
  late final FindProjectsBloc _findProjectsBloc;
  ProjectListingEntity? _currentListing;
  List<ProjectJoinRequestEntity> _joinRequests = [];

  @override
  void initState() {
    super.initState();
    _findProjectsBloc = sl<FindProjectsBloc>();
    _findProjectsBloc.add(LoadListingForProject(projectId: widget.project.id));
    _findProjectsBloc.add(LoadJoinRequests(projectId: widget.project.id));
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadMemberProfiles(),
      _loadCachedAnalysis(),
      _loadPendingInvites(),
    ]);
  }

  Future<void> _loadMemberProfiles() async {
    final allMemberIds = [widget.project.leaderId, ...widget.project.memberIds];
    final profiles = <String, ProfileEntity>{};

    for (final userId in allMemberIds) {
      final profile = await widget.fetchUserProfile(userId);
      if (profile != null) {
        profiles[userId] = profile;
      }
    }

    if (mounted) {
      setState(() {
        _memberProfiles = profiles;
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> _loadCachedAnalysis() async {
    try {
      final dataSource = TeamAnalysisDataSourceImpl(
        dio: sl<Dio>(),
        firestore: FirebaseFirestore.instance,
      );
      final cached = await dataSource.getCachedAnalysis(widget.project.id);
      if (cached != null && mounted) {
        setState(() => _analysis = cached);
      }
    } catch (_) {}
  }

  Future<void> _loadPendingInvites() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('projectId', isEqualTo: widget.project.id)
          .where('status', isEqualTo: 'pending')
          .get();

      final invites = <_PendingInvite>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final inviteeId = data['inviteeId'] as String? ?? '';

        String userName = 'Unknown';
        String? profilePicUrl;
        if (inviteeId.isNotEmpty) {
          final profile = await widget.fetchUserProfile(inviteeId);
          if (profile != null) {
            userName = profile.name;
            profilePicUrl = profile.profilePicUrl;
          }
        }

        invites.add(
          _PendingInvite(
            invitationId: doc.id,
            userId: inviteeId,
            userName: userName,
            profilePicUrl: profilePicUrl,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _pendingInvites = invites;
          _isLoadingPendingInvites = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPendingInvites = false);
      }
    }
  }

  Future<void> _runAnalysis() async {
    setState(() => _isAnalyzing = true);

    try {
      final dataSource = TeamAnalysisDataSourceImpl(
        dio: sl<Dio>(),
        firestore: FirebaseFirestore.instance,
      );

      final tasks = widget.roadmap.tasks
          .map(
            (t) => TaskRoleInfo(
              taskId: t.id,
              taskName: t.name,
              requiredRole: t.requiredRole,
            ),
          )
          .toList();

      final members = <TeamMemberSkillInfo>[];
      for (final entry in _memberProfiles.entries) {
        final profile = entry.value;
        final currentRole = widget.roleAssignments.firstWhere(
          (r) => r['assignedUserId'] == entry.key,
          orElse: () => <String, String>{},
        )['roleName'];

        members.add(
          TeamMemberSkillInfo(
            memberId: entry.key,
            memberName: profile.name,
            currentRole: currentRole,
            skills: profile.skills
                .where((s) => s.isApproved)
                .map(
                  (s) => SkillInfo(
                    skillName: s.skillName,
                    level: s.skillLevel?.displayName ?? 'Beginner',
                    isVerified: s.isVerified,
                  ),
                )
                .toList(),
          ),
        );
      }

      final assignedRoles = widget.roleAssignments
          .map((r) => r['roleName'] ?? '')
          .where((r) => r.isNotEmpty)
          .toList();

      final analysis = await dataSource.analyzeTeamRoles(
        AnalyzeTeamParams(
          projectId: widget.project.id,
          projectName: widget.project.name,
          projectDescription: widget.project.description,
          tasks: tasks,
          members: members,
          assignedRoles: assignedRoles,
        ),
      );

      if (mounted) setState(() => _analysis = analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showReasoningDialog(String memberName, RoleSuggestion suggestion) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.naviReasoning),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memberName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    suggestion.suggestedRole,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(suggestion.reasoning, style: theme.textTheme.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: sl<UserDiscoveryBloc>()),
          BlocProvider(create: (_) => sl<TeamBloc>()),
          BlocProvider(create: (_) => sl<ProfileBloc>()),
        ],
        child: InviteUserDialog(
          projectId: widget.project.id,
          projectName: widget.project.name,
        ),
      ),
    );

    _loadPendingInvites();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final allMemberIds = [widget.project.leaderId, ...widget.project.memberIds];

    return BlocListener<FindProjectsBloc, FindProjectsState>(
      bloc: _findProjectsBloc,
      listenWhen: (previous, current) {
        return current is ProjectListingLoaded ||
            current is JoinRequestsLoaded ||
            current is ListingPublished ||
            current is ListingRemoved ||
            current is JoinRequestResponded;
      },
      listener: (context, state) {
        if (state is ProjectListingLoaded) {
          setState(() {
            _currentListing = state.listing;
          });
        } else if (state is JoinRequestsLoaded) {
          setState(() {
            _joinRequests = state.requests;
          });
        } else if (state is ListingPublished || state is ListingRemoved) {
          _findProjectsBloc.add(
            LoadListingForProject(projectId: widget.project.id),
          );
        } else if (state is JoinRequestResponded) {
          _findProjectsBloc.add(LoadJoinRequests(projectId: widget.project.id));
          if (state.accepted) {
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            context.read<WorkspaceBloc>().add(
              LoadWorkspace(projectId: widget.project.id, userId: uid),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.teamManagementSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: _runAnalysis,
                  icon: const Icon(Icons.psychology, size: 18),
                  label: Text(l10n.analyzeTeam),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoadingMembers)
            ...List.generate(
              allMemberIds.length.clamp(1, 3),
              (_) => const TeamMemberCardSkeleton(),
            )
          else
            ...allMemberIds.asMap().entries.map((entry) {
              final index = entry.key;
              final userId = entry.value;
              final isLeader = index == 0;
              final profile = _memberProfiles[userId];
              final suggestion = _analysis?.memberSuggestions[userId];

              final currentRoles = widget.roleAssignments
                  .where((r) => r['assignedUserId'] == userId)
                  .map((r) => r['roleName'] ?? '')
                  .where((r) => r.isNotEmpty)
                  .toList();

              return _buildMemberCard(
                userId: userId,
                profile: profile,
                isLeader: isLeader,
                currentRoles: currentRoles,
                suggestion: suggestion,
                l10n: l10n,
                theme: theme,
              );
            }),

          const SizedBox(height: 16),
          if (_isLoadingPendingInvites) ...[
            Text(
              l10n.pendingInvitation,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const PendingInviteCardSkeleton(),
            const PendingInviteCardSkeleton(),
          ] else if (_pendingInvites.isNotEmpty) ...[
            Text(
              l10n.pendingInvitation,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingInvites.map(
              (invite) => _buildPendingCard(invite, theme),
            ),
          ],

          if (_joinRequests.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  l10n.joinRequests,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ..._joinRequests.map(
                  (request) => JoinRequestCard(
                    request: request,
                    onRespond: (accepted) {
                      _findProjectsBloc.add(
                        RespondToJoinRequest(
                          requestId: request.id,
                          accepted: accepted,
                          projectId: widget.project.id,
                          applicantId: request.applicantId,
                          projectName: widget.project.name,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          if (_analysis != null && _analysis!.missingRoles.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildMissingRolesSection(l10n, theme),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showInviteDialog,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(
                    l10n.inviteNewMember,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isPublished =
                        _currentListing != null &&
                        _currentListing!.status == 'active';

                    return FilledButton.icon(
                      onPressed: () async {
                        if (isPublished && _currentListing != null) {
                          _findProjectsBloc.add(
                            RemoveListing(listingId: _currentListing!.id),
                          );
                        } else {
                          final missingRoleNames =
                              _analysis?.missingRoles
                                  .map((e) => e.roleName)
                                  .toList() ??
                              [];

                          final result = await PublishListingDialog.show(
                            context,
                            projectName: widget.project.name,
                            projectDescription: widget.project.description,
                            existingRoles: missingRoleNames,
                          );

                          if (result != null) {
                            _findProjectsBloc.add(
                              PublishListing(
                                projectId: widget.project.id,
                                projectName: widget.project.name,
                                projectDescription: widget.project.description,
                                leaderId: widget.project.leaderId,
                                leaderMessage:
                                    result['leaderMessage'] as String?,
                                openRoles:
                                    result['openRoles'] as List<OpenRole>,
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        isPublished ? Icons.close : Icons.campaign_rounded,
                        size: 18,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: isPublished
                            ? theme.colorScheme.error
                            : null,
                      ),
                      label: Text(
                        isPublished
                            ? l10n.unpublishListing
                            : l10n.publishListing,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({
    required String userId,
    required ProfileEntity? profile,
    required bool isLeader,
    required List<String> currentRoles,
    required RoleSuggestion? suggestion,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final skills =
        profile?.skills.where((s) => s.isApproved).take(3).toList() ?? [];

    return GestureDetector(
      onLongPress: suggestion != null
          ? () => _showReasoningDialog(profile?.name ?? 'Member', suggestion)
          : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isLeader
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    backgroundImage: profile?.profilePicUrl != null
                        ? CachedNetworkImageProvider(profile!.profilePicUrl!)
                        : null,
                    child: profile?.profilePicUrl == null
                        ? Text(
                            profile?.name.isNotEmpty == true
                                ? profile!.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLeader
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSecondaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile?.name ?? userId,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isLeader) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.roleLeader,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (currentRoles.isNotEmpty)
                          Text(
                            l10n.currentRole(currentRoles.join(', ')),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              if (skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: skills.map((skill) {
                    final hasLevel = skill.skillLevel != null;
                    final isUnverified = !skill.isVerified;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isUnverified && !hasLevel
                            ? Colors.red.shade100
                            : theme.colorScheme.surfaceContainerHighest,
                        border: isUnverified && !hasLevel
                            ? Border.all(color: Colors.red.shade400, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (skill.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.verified,
                                size: 10,
                                color: AppColors.success,
                              ),
                            )
                          else if (!hasLevel)
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.close,
                                size: 10,
                                color: Colors.red.shade700,
                              ),
                            ),
                          Text(
                            hasLevel
                                ? '${skill.skillName} (${skill.skillLevel!.displayName})'
                                : skill.skillName,
                            style: TextStyle(
                              fontSize: 10,
                              color: isUnverified && !hasLevel
                                  ? Colors.red.shade700
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (suggestion != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        AppColors.accentGold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.suggestedRole(suggestion.suggestedRole),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.viewReasoning,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard(_PendingInvite invite, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
              backgroundImage: invite.profilePicUrl != null
                  ? CachedNetworkImageProvider(invite.profilePicUrl!)
                  : null,
              child: invite.profilePicUrl == null
                  ? Text(
                      invite.userName.isNotEmpty
                          ? invite.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(invite.userName, style: theme.textTheme.bodySmall),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.pendingInvitation,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),

            InkWell(
              onTap: () => _showCancelConfirmation(invite),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.cancelInvitation,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmation(_PendingInvite invite) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text(l10n.cancelInvitation),
          ],
        ),
        content: Text(l10n.cancelInvitationConfirm(invite.userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.cancelInvitation),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('invitations')
            .doc(invite.invitationId)
            .delete();

        final notifications = await FirebaseFirestore.instance
            .collection('notifications')
            .where('data.invitationId', isEqualTo: invite.invitationId)
            .get();

        for (final doc in notifications.docs) {
          await doc.reference.delete();
        }

        _loadPendingInvites();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.invitationCancelled)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel invitation: $e')),
          );
        }
      }
    }
  }

  Widget _buildMissingRolesSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              l10n.missingRolesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._analysis!.missingRoles.map((role) {
          final priorityColor = role.priority == 'high'
              ? Colors.red
              : role.priority == 'medium'
              ? Colors.orange
              : Colors.blue;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          role.roleName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        l10n.tasksRequiring(role.taskCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lookForSkills,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: role.requiredSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: skill.isCritical
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.skillLevel(skill.skillName, skill.level),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: skill.isCritical
                                ? FontWeight.bold
                                : null,
                            color: skill.isCritical
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PendingInvite {
  final String invitationId;
  final String userId;
  final String userName;
  final String? profilePicUrl;

  _PendingInvite({
    required this.invitationId,
    required this.userId,
    required this.userName,
    this.profilePicUrl,
  });
}

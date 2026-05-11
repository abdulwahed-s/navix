import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../find_people/presentation/bloc/user_discovery_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/repositories/team_repository.dart';
import '../bloc/team_bloc.dart';
import '../widgets/invite_user_dialog.dart';
import '../widgets/team_members/animated_background.dart';
import '../widgets/team_members/empty_state.dart';
import '../widgets/team_members/floating_decorations.dart';
import '../widgets/team_members/gradient_fab.dart';
import '../widgets/team_members/loading_state.dart';
import '../widgets/team_members/member_card.dart';
import '../widgets/team_members/remove_member_dialog.dart';

class TeamMembersScreen extends StatefulWidget {
  final String projectId;

  const TeamMembersScreen({super.key, required this.projectId});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    context.read<TeamBloc>().add(LoadTeamMembers(projectId: widget.projectId));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.teamManagement,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: TeamGradientFab(
        label: l10n.inviteMembers,
        onPressed: () => _showInviteDialog(context, l10n),
      ),
      body: Stack(
        children: [
          TeamAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          TeamFloatingDecorations(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          SafeArea(
            child: BlocConsumer<TeamBloc, TeamState>(
              listener: (context, state) {
                if (state is InvitationSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.invitationSent),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is MemberRemoved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.memberRemoved),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is RoleChanged) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.roleChanged),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is TeamError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.riskHigh,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TeamLoading) {
                  return TeamLoadingState(isDark: isDark);
                }

                if (state is TeamMembersLoaded) {
                  return _buildMembersList(state.members, l10n, isDark);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(
    List<TeamMemberInfo> members,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (members.isEmpty) {
      return TeamEmptyState(isDark: isDark, message: l10n.noTeamMembers);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return TeamMemberCard(
          member: member,
          isDark: isDark,
          leaderLabel: l10n.projectLeader,
          memberLabel: l10n.projectMember,
          assignedTasksLabel: l10n.assignedTasks(member.assignedTasks),
          completionRateLabel: l10n.completionRate(member.completionRate),
          makeLeaderLabel: l10n.makeLeader,
          removeMemberLabel: l10n.removeMember,
          onMakeLeader: () {
            context.read<TeamBloc>().add(
              ChangeMemberRole(
                projectId: widget.projectId,
                memberId: member.id,
                newRole: MemberRole.leader,
              ),
            );
          },
          onRemove: () =>
              _showRemoveConfirmation(context, member, l10n, isDark),
        );
      },
    );
  }

  void _showInviteDialog(BuildContext context, AppLocalizations l10n) async {
    final teamBloc = context.read<TeamBloc>();
    final profileBloc = context.read<ProfileBloc>();

    final projectDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .get();

    final projectName = projectDoc.data()?['name'] as String? ?? 'Project';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: sl<UserDiscoveryBloc>()),
          BlocProvider.value(value: teamBloc),
          BlocProvider.value(value: profileBloc),
        ],
        child: InviteUserDialog(
          projectId: widget.projectId,
          projectName: projectName,
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    TeamMemberInfo member,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final teamBloc = context.read<TeamBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => RemoveMemberDialog(
        isDark: isDark,
        memberName: l10n.confirmRemoveMember(member.name),
        title: l10n.removeMember,
        confirmButtonLabel: l10n.removeMember,
        cancelButtonLabel: l10n.cancel,
        warningMessage: l10n.taskReassignmentWarning,
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () {
          Navigator.pop(dialogContext);
          teamBloc.add(
            RemoveMember(projectId: widget.projectId, memberId: member.id),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../ai_chat/domain/entities/chat_entities.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../../profile/domain/entities/skill_level.dart';
import '../../../profile/domain/entities/skill_status.dart';
import '../../../project/domain/entities/project_member_entity.dart';
import '../../../project/domain/entities/project_role_entity.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../../../project/presentation/bloc/project_settings_bloc.dart';
import '../../../project/presentation/bloc/project_settings_event.dart';
import '../../../project/presentation/bloc/project_settings_state.dart';
import '../bloc/workspace_bloc.dart';
import '../widgets/project_workspace/workspace_animated_background.dart';
import '../widgets/project_workspace/workspace_assign_member_dialog.dart';
import '../widgets/project_workspace/workspace_chat_input.dart';
import '../widgets/project_workspace/workspace_chat_message.dart';
import '../widgets/project_workspace/workspace_empty_state.dart';
import '../widgets/project_workspace/workspace_error_state.dart';
import '../widgets/project_workspace/workspace_floating_decorations.dart';
import '../widgets/project_workspace/workspace_loading_state.dart';
import '../widgets/project_workspace/workspace_milestone_item.dart';
import '../widgets/project_workspace/workspace_progress_card.dart';
import '../widgets/project_workspace/workspace_admin_dashboard.dart';
import '../widgets/project_workspace/workspace_role_card.dart';
import '../widgets/project_workspace/workspace_tab_bar.dart';
import '../widgets/project_workspace/workspace_task_card.dart';
import '../widgets/project_workspace/workspace_task_filters.dart';
import '../widgets/project_workspace/workspace_task_group.dart';
import '../../../project_supervisor/presentation/widgets/project_supervisor_button.dart';
import '../../../survey/presentation/bloc/survey_bloc.dart';
import '../../../survey/presentation/bloc/survey_event.dart';
import '../../../survey/presentation/widgets/surveys_tab.dart';

class ProjectWorkspaceScreen extends StatefulWidget {
  final String projectId;

  const ProjectWorkspaceScreen({super.key, required this.projectId});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _messageController = TextEditingController();
  bool? _isLeader;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadWorkspace();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _loadWorkspace() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<WorkspaceBloc>().add(
        LoadWorkspace(projectId: widget.projectId, userId: userId),
      );
    }
  }

  void _openAIChat(TaskEntity task) {
    final state = context.read<WorkspaceBloc>().state;
    if (state is! WorkspaceLoaded) return;

    final profileState = context.read<ProfileBloc>().state;
    List<String> userSkills = [];

    if (profileState is ProfileLoaded) {
      userSkills = profileState.profile.skills
          .where((s) => s.isApproved)
          .map((s) => s.skillName)
          .toList();
    }

    final chatContext = ChatContext(
      projectId: state.project.id,
      projectName: state.project.name,
      projectDescription: state.project.description,
      skills: userSkills,
      taskId: task.id,
      taskName: task.name,
      taskDescription: task.description,
      taskDetailedDescription: task.detailedDescription,
    );

    context.push(AppRoutes.aiChat, extra: chatContext);
  }

  void _initTabController(bool isLeader) {
    if (_isLeader != isLeader || _tabController == null) {
      _tabController?.dispose();

      final tabCount = isLeader ? 6 : 4;
      _tabController = TabController(length: tabCount, vsync: this);
      _isLeader = isLeader;
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _tabController?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is WorkspaceLoading) {
          return _buildLoadingScaffold(l10n, isDark, size);
        }

        if (state is WorkspaceError) {
          return _buildErrorScaffold(state.message, l10n, isDark, size);
        }

        if (state is WorkspaceLoaded) {
          final isLeader = state.userRole == ProjectMemberRole.leader;
          _initTabController(isLeader);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                state.project.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: WorkspaceTabBar(
                  controller: _tabController!,
                  isDark: isDark,
                  isLeader: isLeader,
                ),
              ),
            ),
            body: Stack(
              children: [
                WorkspaceAnimatedBackground(
                  isDark: isDark,
                  floatingAnimation: _floatingAnimation,
                ),
                WorkspaceFloatingDecorations(
                  isDark: isDark,
                  size: size,
                  floatingAnimation: _floatingAnimation,
                ),
                SafeArea(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      if (isLeader) _buildDashboardTab(state, l10n, theme),
                      _buildOverviewTab(state, l10n, theme, isDark),
                      _buildTasksTab(state, l10n, theme),
                      _buildSurveysTab(state, l10n, theme),
                      _buildChatTab(state, l10n, theme),
                      if (isLeader) _buildSettingsTab(state, l10n, theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingScaffold(AppLocalizations l10n, bool isDark, Size size) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.workspace),
      ),
      body: Stack(
        children: [
          WorkspaceAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          WorkspaceFloatingDecorations(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),
          WorkspaceLoadingState(floatingAnimation: _floatingAnimation),
        ],
      ),
    );
  }

  Widget _buildErrorScaffold(
    String message,
    AppLocalizations l10n,
    bool isDark,
    Size size,
  ) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.workspace),
      ),
      body: Stack(
        children: [
          WorkspaceAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          WorkspaceFloatingDecorations(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),
          WorkspaceErrorState(
            message: message,
            isDark: isDark,
            onRetry: _loadWorkspace,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return WorkspaceAdminDashboard(
      project: state.project,
      roadmap: state.roadmap,
      roleAssignments: _getRoleAssignments(state),
      fetchUserName: _fetchUserName,
      fetchUserProfile: _fetchUserProfile,
    );
  }

  List<Map<String, String>> _getRoleAssignments(WorkspaceLoaded state) {
    final assignments = <Map<String, String>>[];
    final seenRoles = <String>{};
    for (final task in state.roadmap.tasks) {
      if (task.requiredRole != null &&
          task.assignedTo != null &&
          !seenRoles.contains(task.requiredRole)) {
        seenRoles.add(task.requiredRole!);
        assignments.add({
          'roleName': task.requiredRole!,
          'assignedUserId': task.assignedTo!,
        });
      }
    }
    return assignments;
  }

  Future<ProfileEntity?> _fetchUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('main')
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final skillsData = data['skills'] as List<dynamic>? ?? [];
      final skills = skillsData.map((s) {
        final skill = s as Map<String, dynamic>;
        return SkillEntity(
          skillName: skill['skillName'] as String? ?? '',
          skillLevel: SkillLevel.fromString(skill['skillLevel'] as String?),
          isVerified: skill['isVerified'] as bool? ?? false,
          status: SkillStatus.fromString(
            skill['status'] as String? ?? 'PENDING',
          ),
        );
      }).toList();

      return ProfileEntity(
        userId: userId,
        name: data['name'] as String? ?? 'Unknown',
        profilePicUrl: data['profilePicUrl'] as String?,
        skills: skills,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildOverviewTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final progress = state.overallProgress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkspaceProgressCard(progress: progress, isDark: isDark),
          const SizedBox(height: 24),

          Text(
            l10n.milestones,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...state.roadmap.milestones.map(
            (m) => WorkspaceMilestoneItem(milestone: m),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTasksTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLeader = state.userRole == ProjectMemberRole.leader;
    final baseTasks = isLeader ? state.roadmap.tasks : state.getMyTasks(userId);

    final roles =
        baseTasks
            .where((t) => t.requiredRole != null)
            .map((t) => t.requiredRole!)
            .toSet()
            .toList()
          ..sort();

    return Column(
      children: [
        WorkspaceTaskFilters(
          grouping: state.grouping,
          selectedRoleFilter: state.selectedRoleFilter,
          selectedTimeFilter: state.selectedTimeFilter,
          sortOrder: state.sortOrder,
          roles: roles,
          onGroupingChanged: (value) {
            if (value != null) {
              context.read<WorkspaceBloc>().add(ChangeTaskGrouping(value));
            }
          },
          onRoleFilterChanged: (role) {
            context.read<WorkspaceBloc>().add(FilterByRole(role));
          },
          onTimeFilterChanged: (time) {
            context.read<WorkspaceBloc>().add(FilterByTime(time));
          },
          onSortOrderChanged: (order) {
            context.read<WorkspaceBloc>().add(ChangeSortOrder(order));
          },
        ),

        Expanded(
          child: _buildTaskList(
            _sortTasks(baseTasks, state.sortOrder),
            state,
            l10n,
            theme,
          ),
        ),
      ],
    );
  }

  List<TaskEntity> _sortTasks(List<TaskEntity> tasks, TaskSortOrder sortOrder) {
    final sortedTasks = List<TaskEntity>.from(tasks);
    switch (sortOrder) {
      case TaskSortOrder.priorityHighToLow:
        sortedTasks.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
        break;
      case TaskSortOrder.priorityLowToHigh:
        sortedTasks.sort(
          (a, b) => a.priority.index.compareTo(b.priority.index),
        );
        break;
      case TaskSortOrder.deadlineAsc:
        sortedTasks.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case TaskSortOrder.deadlineDesc:
        sortedTasks.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return -1;
          if (b.deadline == null) return 1;
          return b.deadline!.compareTo(a.deadline!);
        });
        break;
      case TaskSortOrder.none:
        break;
    }
    return sortedTasks;
  }

  Widget _buildTaskList(
    List<TaskEntity> baseTasks,
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (baseTasks.isEmpty) {
      return WorkspaceEmptyState(icon: Icons.task_alt, message: l10n.noTasks);
    }

    if (state.grouping == TaskGrouping.byRole) {
      return _buildGroupedByRole(baseTasks, state, l10n);
    } else if (state.grouping == TaskGrouping.byTime) {
      return _buildGroupedByTime(baseTasks, state, l10n);
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: baseTasks.length,
        itemBuilder: (context, index) => _buildTaskCard(baseTasks[index]),
      );
    }
  }

  Widget _buildGroupedByRole(
    List<TaskEntity> tasks,
    WorkspaceLoaded state,
    AppLocalizations l10n,
  ) {
    final roles =
        tasks
            .where((t) => t.requiredRole != null)
            .map((t) => t.requiredRole!)
            .toSet()
            .toList()
          ..sort();

    final filteredRoles = state.selectedRoleFilter != null
        ? [state.selectedRoleFilter!]
        : roles;

    if (filteredRoles.isEmpty) {
      return Center(child: Text(l10n.noTasksInGroup));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRoles.length + 1,
      itemBuilder: (context, index) {
        final String? role = index < filteredRoles.length
            ? filteredRoles[index]
            : null;
        final groupTasks = tasks.where((t) => t.requiredRole == role).toList();
        final groupName = role ?? l10n.noRoleAssigned;

        return WorkspaceTaskGroup(
          groupName: groupName,
          tasks: groupTasks,
          taskCardBuilder: _buildTaskCard,
          icon: _getRoleIcon(role),
          accentColor: _getRoleColor(index),
        );
      },
    );
  }

  IconData _getRoleIcon(String? role) {
    if (role == null) return Icons.person_off_outlined;
    final lowerRole = role.toLowerCase();
    if (lowerRole.contains('design')) {
      return Icons.palette_outlined;
    }
    if (lowerRole.contains('backend') || lowerRole.contains('server')) {
      return Icons.dns_outlined;
    }
    if (lowerRole.contains('frontend') || lowerRole.contains('ui')) {
      return Icons.web_outlined;
    }
    if (lowerRole.contains('mobile') || lowerRole.contains('flutter')) {
      return Icons.phone_android_outlined;
    }
    if (lowerRole.contains('test') || lowerRole.contains('qa')) {
      return Icons.bug_report_outlined;
    }
    if (lowerRole.contains('devops') || lowerRole.contains('deploy')) {
      return Icons.cloud_outlined;
    }
    if (lowerRole.contains('manager') || lowerRole.contains('lead')) {
      return Icons.supervisor_account_outlined;
    }
    if (lowerRole.contains('data') ||
        lowerRole.contains('ml') ||
        lowerRole.contains('ai')) {
      return Icons.insights_outlined;
    }
    return Icons.work_outline;
  }

  Color _getRoleColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.green,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  Widget _buildGroupedByTime(
    List<TaskEntity> tasks,
    WorkspaceLoaded state,
    AppLocalizations l10n,
  ) {
    final timeGroups = [
      ('overdue', l10n.tasksOverdue),
      ('today', l10n.tasksDueToday),
      ('thisWeek', l10n.tasksDueThisWeek),
      ('later', l10n.tasksLater),
    ];

    final selectedGroup = state.selectedTimeFilter;
    final groupsToShow = selectedGroup != null
        ? timeGroups.where((g) => g.$1 == selectedGroup).toList()
        : timeGroups;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupsToShow.length,
      itemBuilder: (context, index) {
        final (key, label) = groupsToShow[index];
        final groupTasks = _filterTasksByTimeGroup(tasks, key);

        return WorkspaceTaskGroup(
          groupName: label,
          tasks: groupTasks,
          taskCardBuilder: _buildTaskCard,
          icon: _getTimeGroupIcon(key),
          accentColor: _getTimeGroupColor(key),
        );
      },
    );
  }

  IconData _getTimeGroupIcon(String key) {
    switch (key) {
      case 'overdue':
        return Icons.warning_rounded;
      case 'today':
        return Icons.today;
      case 'thisWeek':
        return Icons.date_range;
      case 'later':
        return Icons.event_outlined;
      default:
        return Icons.schedule;
    }
  }

  Color _getTimeGroupColor(String key) {
    switch (key) {
      case 'overdue':
        return Colors.red;
      case 'today':
        return Colors.orange;
      case 'thisWeek':
        return Colors.blue;
      case 'later':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<TaskEntity> _filterTasksByTimeGroup(
    List<TaskEntity> tasks,
    String timeGroup,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));

    switch (timeGroup) {
      case 'overdue':
        return tasks.where((t) => t.isOverdue).toList();
      case 'today':
        return tasks.where((t) {
          if (t.deadline == null || t.status == TaskStatus.completed) {
            return false;
          }
          final deadline = DateTime(
            t.deadline!.year,
            t.deadline!.month,
            t.deadline!.day,
          );
          return deadline.isAtSameMomentAs(today);
        }).toList();
      case 'thisWeek':
        return tasks.where((t) {
          if (t.deadline == null || t.status == TaskStatus.completed) {
            return false;
          }
          return t.deadline!.isAfter(today) &&
              t.deadline!.isBefore(weekFromNow);
        }).toList();
      case 'later':
        return tasks.where((t) {
          if (t.deadline == null) return true;
          if (t.status == TaskStatus.completed) return false;
          return t.deadline!.isAfter(weekFromNow);
        }).toList();
      default:
        return tasks;
    }
  }

  Widget _buildTaskCard(TaskEntity task) {
    return WorkspaceTaskCard(
      task: task,
      onStatusChanged: (status) {
        context.read<WorkspaceBloc>().add(
          UpdateTaskStatus(taskId: task.id, newStatus: status),
        );
      },
      onAIChatPressed: () => _openAIChat(task),
      onTap: () async {
        await context.push('/project/${widget.projectId}/task/${task.id}');

        if (mounted) {
          context.read<WorkspaceBloc>().add(const RefreshWorkspace());
        }
      },
    );
  }

  Widget _buildChatTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName = state.currentUserName;

    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? WorkspaceEmptyState(
                  icon: Icons.chat_bubble_outline,
                  message: l10n.noMessages,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: false,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == userId;

                    return WorkspaceChatMessage(message: message, isMe: isMe);
                  },
                ),
        ),

        WorkspaceChatInput(
          controller: _messageController,
          onSend: () => _sendMessage(userName),
        ),
      ],
    );
  }

  void _sendMessage(String userName) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<WorkspaceBloc>().add(
      SendChatMessage(content: content, senderName: userName),
    );

    _messageController.clear();
  }

  Widget _buildSurveysTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isLeader = state.userRole == ProjectMemberRole.leader;

    return BlocProvider(
      create: (context) =>
          sl<SurveyBloc>()..add(WatchSurveys(projectId: state.project.id)),
      child: SurveysTab(
        projectId: state.project.id,
        isLeader: isLeader,
        onCreateSurvey: () {
          context.push(
            '/project/${state.project.id}/survey/create',
            extra: {
              'projectName': state.project.name,
              'projectDescription': state.project.description,
            },
          );
        },
        onViewSurvey: (survey) {
          context.push('/project/${state.project.id}/survey/${survey.id}');
        },
        onEditSurvey: (survey) {
          context.push('/project/${state.project.id}/survey/${survey.id}/edit');
        },
      ),
    );
  }

  Widget _buildSettingsTab(
    WorkspaceLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return BlocProvider(
      create: (context) => ProjectSettingsBloc(
        getProjectRolesUseCase: sl(),
        assignRoleToMemberUseCase: sl(),
      )..add(LoadProjectSettings(projectId: state.project.id)),
      child: BlocBuilder<ProjectSettingsBloc, ProjectSettingsState>(
        builder: (context, settingsState) {
          if (settingsState is ProjectSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (settingsState is ProjectSettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settingsState.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProjectSettingsBloc>().add(
                      LoadProjectSettings(projectId: state.project.id),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final roles = settingsState is ProjectSettingsLoaded
              ? settingsState.roles
              : settingsState is RoleAssignedSuccess
              ? settingsState.roles
              : <ProjectRoleEntity>[];

          if (roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.noRoles, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'This project has no role-based tasks',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.projectSettings,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              ProjectSupervisorButton(
                project: state.project,
                milestones: state.roadmap.milestones,
                tasks: state.roadmap.tasks,
                roles: roles,
                memberNames: _getMemberNamesMap(state),
              ),

              Text(
                l10n.roleAssignments,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              ...roles.map(
                (role) => WorkspaceRoleCard(
                  role: role,
                  onAssignPressed: () =>
                      _showAssignMemberDialog(context, role, state, l10n),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignMemberDialog(
    BuildContext context,
    ProjectRoleEntity role,
    WorkspaceLoaded state,
    AppLocalizations l10n,
  ) {
    final settingsBloc = context.read<ProjectSettingsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => WorkspaceAssignMemberDialog(
        role: role,
        memberIds: state.project.memberIds,
        leaderId: state.project.leaderId,
        fetchUserName: _fetchUserName,
        onAssign: (userId, userName) {
          settingsBloc.add(
            AssignRoleToMember(
              projectId: state.project.id,
              roleName: role.roleName,
              userId: userId,
              userName: userName,
            ),
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.roleAssignedSuccess)));
        },
      ),
    );
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('main')
          .get();

      if (userProfileDoc.exists) {
        final name = userProfileDoc.data()?['name'] as String?;
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
    } catch (e) {}
    return userId;
  }

  Map<String, String> _getMemberNamesMap(WorkspaceLoaded state) {
    final Map<String, String> memberNames = {};

    memberNames[state.project.leaderId] = state.project.leaderId;

    for (final memberId in state.project.memberIds) {
      memberNames[memberId] = memberId;
    }

    return memberNames;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../project/domain/entities/milestone_entity.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/domain/entities/project_role_entity.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../../domain/entities/project_supervisor_context.dart';
import '../bloc/project_supervisor_bloc.dart';
import '../widgets/supervisor_input_field.dart';
import '../widgets/supervisor_message_bubble.dart';
import '../widgets/supervisor_welcome_message.dart';

class ProjectSupervisorScreen extends StatefulWidget {
  final ProjectEntity project;
  final List<MilestoneEntity> milestones;
  final List<TaskEntity> tasks;
  final List<ProjectRoleEntity> roles;
  final Map<String, String> memberNames;

  const ProjectSupervisorScreen({
    super.key,
    required this.project,
    required this.milestones,
    required this.tasks,
    required this.roles,
    required this.memberNames,
  });

  @override
  State<ProjectSupervisorScreen> createState() =>
      _ProjectSupervisorScreenState();
}

class _ProjectSupervisorScreenState extends State<ProjectSupervisorScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  ProjectSupervisorContext _buildContext() {
    return ProjectSupervisorContext(
      project: widget.project,
      milestones: widget.milestones,
      tasks: widget.tasks,
      roles: widget.roles,
      memberNames: widget.memberNames,
      currentDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) =>
          sl<ProjectSupervisorBloc>()
            ..add(InitializeSupervisor(context: _buildContext())),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiProjectSupervisor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.project.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ProjectSupervisorBloc>().add(
                  const ClearSupervisorChat(),
                );
              },
              tooltip: 'Clear conversation',
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildBackground(theme, isDark),

            SafeArea(
              child:
                  BlocConsumer<ProjectSupervisorBloc, ProjectSupervisorState>(
                    listener: (context, state) {
                      if (state is ProjectSupervisorActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.successMessage),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      if (state is ProjectSupervisorReady &&
                          state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error!),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      if (state is ProjectSupervisorReady &&
                          state.messages.isNotEmpty) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        children: [
                          Expanded(
                            child: _buildMessageArea(
                              context,
                              state,
                              theme,
                              isDark,
                              l10n,
                            ),
                          ),
                          SupervisorInputField(
                            controller: _messageController,
                            onSend: () => _sendMessage(context),
                            isLoading:
                                state is ProjectSupervisorReady &&
                                state.isLoading,
                            theme: theme,
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F0F23),
                ]
              : [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.colorScheme.secondary.withValues(alpha: 0.03),
                  Colors.white,
                ],
        ),
      ),
    );
  }

  Widget _buildMessageArea(
    BuildContext context,
    ProjectSupervisorState state,
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (state is ProjectSupervisorInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProjectSupervisorActionExecuting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Executing: ${state.action.title}...',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    List<dynamic> messages = [];
    if (state is ProjectSupervisorReady) {
      messages = state.messages;
    } else if (state is ProjectSupervisorActionSuccess) {
      messages = state.messages;
    }

    if (messages.isEmpty) {
      return SupervisorWelcomeMessage(
        theme: theme,
        isDark: isDark,
        floatingAnimation: _floatingAnimation,
        onExampleTap: (text) {
          _messageController.text = text;
          _sendMessage(context);
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          messages.length +
          (state is ProjectSupervisorReady && state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildLoadingIndicator(theme, isDark);
        }
        final message = messages[index];
        return SupervisorMessageBubble(
          message: message,
          theme: theme,
          isDark: isDark,
          onActionConfirmed: (action) {
            context.read<ProjectSupervisorBloc>().add(
              ConfirmAction(action: action, messageId: message.id),
            );
          },
          onActionRejected: () {
            context.read<ProjectSupervisorBloc>().add(
              RejectAction(messageId: message.id),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Analyzing your project...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ProjectSupervisorBloc>().add(
      SendSupervisorMessage(message: message),
    );
    _messageController.clear();
  }
}

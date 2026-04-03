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
import 'supervisor_input_field.dart';
import 'supervisor_message_bubble.dart';
import 'supervisor_welcome_message.dart';

class ProjectSupervisorSection extends StatefulWidget {
  final ProjectEntity project;
  final List<MilestoneEntity> milestones;
  final List<TaskEntity> tasks;
  final List<ProjectRoleEntity> roles;
  final Map<String, String> memberNames;

  const ProjectSupervisorSection({
    super.key,
    required this.project,
    required this.milestones,
    required this.tasks,
    required this.roles,
    required this.memberNames,
  });

  @override
  State<ProjectSupervisorSection> createState() =>
      _ProjectSupervisorSectionState();
}

class _ProjectSupervisorSectionState extends State<ProjectSupervisorSection>
    with TickerProviderStateMixin {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;
  bool _isExpanded = false;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
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
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.editWithAI,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.aiSupervisorDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildChatSection(theme, isDark, l10n),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatSection(
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 450,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BlocConsumer<ProjectSupervisorBloc, ProjectSupervisorState>(
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

            if (state is ProjectSupervisorReady && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is ProjectSupervisorReady && state.messages.isNotEmpty) {
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
                  child: _buildMessageArea(context, state, theme, isDark, l10n),
                ),
                SupervisorInputField(
                  controller: _messageController,
                  onSend: () => _sendMessage(context),
                  isLoading: state is ProjectSupervisorReady && state.isLoading,
                  theme: theme,
                  isDark: isDark,
                ),
              ],
            );
          },
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
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Executing: ${state.action.title}...',
              style: theme.textTheme.bodyMedium,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../../domain/entities/prd_editor_context.dart';
import '../bloc/prd_editor_bloc.dart';
import '../widgets/prd_editor_message_bubble.dart';
import '../widgets/prd_editor_welcome_message.dart';
import '../widgets/supervisor_input_field.dart';

class PrdEditorScreen extends StatefulWidget {
  final PrdEntity prd;
  final List<String> userSkills;
  final int teamSize;
  final DateTime startDate;
  final DateTime endDate;

  const PrdEditorScreen({
    super.key,
    required this.prd,
    required this.userSkills,
    required this.teamSize,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<PrdEditorScreen> createState() => _PrdEditorScreenState();
}

class _PrdEditorScreenState extends State<PrdEditorScreen>
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

  PrdEditorContext _buildContext(PrdEntity prd) {
    return PrdEditorContext(
      prd: prd,
      userSkills: widget.userSkills,
      teamSize: widget.teamSize,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) =>
          sl<PrdEditorBloc>()
            ..add(InitializePrdEditor(context: _buildContext(widget.prd))),
      child: BlocBuilder<PrdEditorBloc, PrdEditorState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;

              final currentPrd = state is PrdEditorReady
                  ? state.currentPrd
                  : widget.prd;
              Navigator.of(context).pop(currentPrd);
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    final currentPrd = state is PrdEditorReady
                        ? state.currentPrd
                        : widget.prd;
                    Navigator.of(context).pop(currentPrd);
                  },
                ),
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
                        Icons.edit_document,
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
                            'Edit with Navi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state is PrdEditorReady
                                ? state.currentPrd.title
                                : widget.prd.title,
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
                      context.read<PrdEditorBloc>().add(
                        const ClearPrdEditorChat(),
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
                    child: BlocConsumer<PrdEditorBloc, PrdEditorState>(
                      listener: (context, state) {
                        if (state is PrdEditorReady && state.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error!),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        if (state is PrdEditorReady &&
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
                              ),
                            ),
                            SupervisorInputField(
                              controller: _messageController,
                              onSend: () => _sendMessage(context),
                              isLoading:
                                  state is PrdEditorReady && state.isLoading,
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
        },
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
    PrdEditorState state,
    ThemeData theme,
    bool isDark,
  ) {
    if (state is PrdEditorInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    List<dynamic> messages = [];
    if (state is PrdEditorReady) {
      messages = state.messages;
    }

    if (messages.isEmpty) {
      return PrdEditorWelcomeMessage(
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
          (state is PrdEditorReady && state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildLoadingIndicator(theme, isDark);
        }
        final message = messages[index];
        return PrdEditorMessageBubble(
          message: message,
          theme: theme,
          isDark: isDark,
          onAcceptUpdate: message.updatePending
              ? (updates) {
                  context.read<PrdEditorBloc>().add(
                    AcceptPrdUpdate(messageId: message.id, updates: updates),
                  );
                }
              : null,
          onRejectUpdate: message.updatePending
              ? () {
                  context.read<PrdEditorBloc>().add(
                    RejectPrdUpdate(messageId: message.id),
                  );
                }
              : null,
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
                  'Analyzing your request...',
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

    context.read<PrdEditorBloc>().add(SendPrdEditorMessage(message: message));
    _messageController.clear();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/chat_entities.dart';
import '../bloc/ai_chat_bloc.dart';
import '../widgets/animated_background.dart';
import '../widgets/context_banner.dart';
import '../widgets/context_info_dialog.dart';
import '../widgets/error_banner.dart';
import '../widgets/floating_decorations.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/welcome_message.dart';

class AIChatScreen extends StatefulWidget {
  final ChatContext context;

  const AIChatScreen({super.key, required this.context});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<AIChatBloc>().add(
      SendChatMessage(message: message, context: widget.context),
    );

    _messageController.clear();

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

  void _showContextInfo(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AIChatContextInfoDialog(
        l10n: l10n,
        theme: theme,
        isDark: isDark,
        chatContext: widget.context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.chatWithNavixAI,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _showContextInfo(context, l10n, theme, isDark),
              tooltip: l10n.viewContext,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AIChatAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          AIChatFloatingDecorations(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),
          SafeArea(
            child: Column(
              children: [
                AIChatContextBanner(
                  theme: theme,
                  l10n: l10n,
                  isDark: isDark,
                  chatContext: widget.context,
                ),
                Expanded(
                  child: BlocBuilder<AIChatBloc, AIChatState>(
                    builder: (context, state) {
                      if (state is AIChatInitial) {
                        return AIChatWelcomeMessage(
                          theme: theme,
                          l10n: l10n,
                          isDark: isDark,
                          floatingAnimation: _floatingAnimation,
                        );
                      }

                      if (state is AIChatLoaded || state is AIChatError) {
                        final messages = state is AIChatLoaded
                            ? state.messages
                            : (state as AIChatError).previousMessages;

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              messages.length +
                              (state is AIChatLoaded && state.isLoading
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length) {
                              return AIChatLoadingIndicator(
                                theme: theme,
                                isDark: isDark,
                                floatingAnimation: _floatingAnimation,
                              );
                            }
                            return AIChatMessageBubble(
                              message: messages[index],
                              theme: theme,
                              isDark: isDark,
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                BlocBuilder<AIChatBloc, AIChatState>(
                  builder: (context, state) {
                    if (state is AIChatError) {
                      return AIChatErrorBanner(
                        message: state.message,
                        theme: theme,
                        isDark: isDark,
                      );
                    }
                    return const SizedBox();
                  },
                ),
                AIChatMessageInput(
                  theme: theme,
                  l10n: l10n,
                  isDark: isDark,
                  controller: _messageController,
                  onSend: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

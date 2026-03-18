import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/conversation_bloc.dart';
import '../widgets/conversation/conversation_app_bar.dart';
import '../widgets/conversation/conversation_background.dart';
import '../widgets/conversation/conversation_empty_state.dart';
import '../widgets/conversation/conversation_error_state.dart';
import '../widgets/conversation/conversation_loading_state.dart';
import '../widgets/conversation/date_separator.dart';
import '../widgets/conversation/message_bubble.dart';
import '../widgets/conversation/message_input_area.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserId;
  final String currentUserName;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserId,
    required this.currentUserName,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    return BlocProvider(
      create: (_) =>
          ConversationBloc(
            repository: sl(),
            senderId: currentUserId,
            senderName: widget.currentUserName,
          )..add(
            SubscribeToMessages(
              conversationId: widget.conversationId,
              currentUserId: currentUserId,
            ),
          ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: ConversationAppBar(
          otherUserName: widget.otherUserName,
          otherUserId: widget.otherUserId,
          isDark: isDark,
          onBack: () => Navigator.pop(context),
        ),
        body: Stack(
          children: [
            ConversationBackground(isDark: isDark),

            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: BlocConsumer<ConversationBloc, ConversationState>(
                      listener: (context, state) {
                        if (state is ConversationLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is ConversationLoading) {
                          return const ConversationLoadingState();
                        }

                        if (state is ConversationError) {
                          return ConversationErrorState(message: state.message);
                        }

                        if (state is ConversationLoaded) {
                          return _buildMessagesList(
                            state.messages,
                            currentUserId,
                            isDark,
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),

                  Builder(
                    builder: (context) => MessageInputArea(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      isDark: isDark,
                      sendButtonAnimation: _sendButtonAnimation,
                      onSend: () => _sendMessage(context),
                      onTapDown: () => _sendButtonController.forward(),
                      onTapUp: () => _sendButtonController.reverse(),
                      onTapCancel: () => _sendButtonController.reverse(),
                      onFocusChange: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    List<MessageEntity> messages,
    String currentUserId,
    bool isDark,
  ) {
    if (messages.isEmpty) {
      return ConversationEmptyState(otherUserName: widget.otherUserName);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMine = message.isMine(currentUserId);

        final showDateSeparator =
            index == 0 ||
            !_isSameDay(messages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            if (showDateSeparator) DateSeparator(date: message.timestamp),
            MessageBubble(message: message, isMine: isMine, isDark: isDark),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ConversationBloc>().add(SendMessage(text: text));
    _messageController.clear();
  }
}

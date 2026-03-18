import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/conversation_entity.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_list/chat_list_animated_background.dart';
import '../widgets/chat_list/chat_list_empty_state.dart';
import '../widgets/chat_list/chat_list_error_state.dart';
import '../widgets/chat_list/chat_list_floating_decorations.dart';
import '../widgets/chat_list/chat_list_gradient_fab.dart';
import '../widgets/chat_list/chat_list_loading_state.dart';
import '../widgets/chat_list/connected_people_bottom_sheet.dart';
import '../widgets/chat_list/conversation_tile.dart';
import 'conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadConversations();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<ChatBloc>().add(LoadConversations(userId: userId));
      context.read<ChatBloc>().add(SubscribeToConversations(userId: userId));
    }
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
        title: Text(
          l10n.messages,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: ChatListGradientFab(
        isDark: isDark,
        onTap: () => _showConnectedPeopleSheet(context),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return ChatListAnimatedBackground(
                isDark: isDark,
                size: size,
                animationValue: _floatingAnimation.value,
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return ChatListFloatingDecorations(
                isDark: isDark,
                size: size,
                animationValue: _floatingAnimation.value,
              );
            },
          ),

          SafeArea(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ConversationDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.conversationDeleted),
                        ],
                      ),
                      backgroundColor: AppColors.successDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                } else if (state is ConversationStarted) {
                  final profileState = context.read<ProfileBloc>().state;
                  String currentUserName = 'User';
                  if (profileState is ProfileLoaded) {
                    currentUserName = profileState.profile.name;
                  }

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ConversationScreen(
                            conversationId: state.conversation.id,
                            otherUserName: state.conversation
                                .getOtherParticipantName(
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                                ),
                            otherUserId: state.conversation
                                .getOtherParticipantId(
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                                ),
                            currentUserName: currentUserName,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            );
                          },
                    ),
                  );
                } else if (state is ChatLoaded) {
                  _listAnimationController.forward(from: 0);
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const ChatListLoadingState();
                }

                if (state is ChatError) {
                  return ChatListErrorState(message: state.message);
                }

                if (state is ConnectedUsersLoading &&
                    state.conversations != null) {
                  return _buildConversationsList(
                    state.conversations!,
                    l10n,
                    theme,
                    isDark,
                  );
                }

                if (state is ConnectedUsersLoaded &&
                    state.conversations != null) {
                  return _buildConversationsList(
                    state.conversations!,
                    l10n,
                    theme,
                    isDark,
                  );
                }

                if (state is ConversationStarted &&
                    state.previousConversations != null) {
                  return _buildConversationsList(
                    state.previousConversations!,
                    l10n,
                    theme,
                    isDark,
                  );
                }

                if (state is ChatLoaded || state is ConversationDeleted) {
                  final conversations = state is ChatLoaded
                      ? state.conversations
                      : (state as ConversationDeleted)
                            .previousState
                            .conversations;
                  return _buildConversationsList(
                    conversations,
                    l10n,
                    theme,
                    isDark,
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    List<ConversationEntity> conversations,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    if (conversations.isEmpty) {
      return AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return ChatListEmptyState(animationValue: _floatingAnimation.value);
        },
      );
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final profileState = context.read<ProfileBloc>().state;
    String currentUserName = 'User';
    if (profileState is ProfileLoaded) {
      currentUserName = profileState.profile.name;
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadConversations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _listAnimationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = Curves.easeOutCubic.transform(
                (_listAnimationController.value - delay).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: ConversationTile(
                    conversation: conversations[index],
                    currentUserId: currentUserId,
                    isDark: isDark,
                    onDelete: () => _showDeleteConfirmation(
                      context,
                      conversations[index].id,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ConversationScreen(
                                    conversationId: conversations[index].id,
                                    otherUserName: conversations[index]
                                        .getOtherParticipantName(currentUserId),
                                    otherUserId: conversations[index]
                                        .getOtherParticipantId(currentUserId),
                                    currentUserName: currentUserName,
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: child,
                                );
                              },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String conversationId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Text(l10n.deleteConversation),
          ],
        ),
        content: Text(l10n.confirmDeleteConversation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              this.context.read<ChatBloc>().add(
                DeleteConversation(conversationId: conversationId),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showConnectedPeopleSheet(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final chatBloc = context.read<ChatBloc>();

    final profileState = context.read<ProfileBloc>().state;
    String currentUserName = 'User';
    if (profileState is ProfileLoaded) {
      currentUserName = profileState.profile.name;
    }

    showConnectedPeopleSheet(
      context: context,
      userId: userId,
      chatBloc: chatBloc,
      onUserSelected: (otherUserId, otherUserName) {
        context.read<ChatBloc>().add(
          StartConversationWithUser(
            currentUserId: userId,
            currentUserName: currentUserName,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        );
      },
    );
  }
}

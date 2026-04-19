import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/domain/entities/message_entity.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/post_entity.dart';

class SharePostDialog extends StatefulWidget {
  final PostEntity post;

  const SharePostDialog({super.key, required this.post});

  static Future<void> show(BuildContext context, PostEntity post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SharePostDialog(post: post),
    );
  }

  @override
  State<SharePostDialog> createState() => _SharePostDialogState();
}

class _SharePostDialogState extends State<SharePostDialog>
    with SingleTickerProviderStateMixin {
  bool _isSending = false;
  String? _selectedUserId;

  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    return BlocProvider(
      create: (_) =>
          ChatBloc(repository: sl())
            ..add(LoadConnectedUsers(userId: currentUserId)),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.brandPrimary.withValues(alpha: 0.2),
                                  AppColors.accentRose.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.send_rounded,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.selectContact,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPostPreview(theme, isDark),
                    ),
                    const SizedBox(height: 16),

                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),

                    Expanded(
                      child: BlocConsumer<ChatBloc, ChatState>(
                        listener: (context, state) {
                          if (state is ConversationStarted && _isSending) {
                            _sendPostToConversation(
                              context,
                              state.conversation.id,
                              currentUserId,
                            );
                          }
                          if (state is ConnectedUsersLoaded) {
                            _listAnimationController.forward(from: 0);
                          }
                        },
                        builder: (context, state) {
                          if (state is ChatLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is ChatError) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 48,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.message,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (state is ConnectedUsersLoaded) {
                            if (state.connectedUsers.isEmpty) {
                              return _buildEmptyState(theme, l10n, isDark);
                            }
                            return _buildUsersList(
                              context,
                              scrollController,
                              state.connectedUsers,
                              currentUserId,
                              theme,
                              isDark,
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostPreview(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [AppColors.brandCream, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.brandPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentLavender.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.article_rounded, color: AppColors.brandPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.post.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLavender.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: AppColors.brandPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noConnections,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    ScrollController scrollController,
    List<ProfileEntity> users,
    String currentUserId,
    ThemeData theme,
    bool isDark,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = _selectedUserId == user.userId;
        final isLoading = _isSending && isSelected;

        return AnimatedBuilder(
          animation: _listAnimationController,
          builder: (context, child) {
            final delay = index * 0.1;
            final animationValue = Curves.easeOutCubic.transform(
              (_listAnimationController.value - delay).clamp(0.0, 1.0),
            );
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: _UserTile(
                  user: user,
                  isLoading: isLoading,
                  isDark: isDark,
                  onTap: isLoading
                      ? null
                      : () => _onUserSelected(context, user, currentUserId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onUserSelected(
    BuildContext context,
    ProfileEntity user,
    String currentUserId,
  ) async {
    setState(() {
      _isSending = true;
      _selectedUserId = user.userId;
    });

    final currentUserName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    context.read<ChatBloc>().add(
      StartConversationWithUser(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: user.userId,
        otherUserName: user.name,
      ),
    );
  }

  Future<void> _sendPostToConversation(
    BuildContext context,
    String conversationId,
    String currentUserId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final chatRepository = sl<ChatRepository>();
    final currentUserName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    final sharedPostData = SharedPostData(
      postId: widget.post.id,
      title: widget.post.title,
      content: widget.post.content,
      imageUrl: widget.post.imageUrl,
      authorId: widget.post.authorId,
    );

    final result = await chatRepository.sendSharedPost(
      conversationId: conversationId,
      senderId: currentUserId,
      senderName: currentUserName,
      sharedPost: sharedPostData,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSending = false;
          _selectedUserId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.postShared),
              ],
            ),
            backgroundColor: AppColors.successDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class _UserTile extends StatefulWidget {
  final ProfileEntity user;
  final bool isLoading;
  final bool isDark;
  final VoidCallback? onTap;

  const _UserTile({
    required this.user,
    required this.isLoading,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.brandPrimary.withValues(alpha: 0.05))
              : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.accentLavender, AppColors.brandPrimary],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDark ? AppColors.darkSurface : Colors.white,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: widget.user.profilePicUrl != null
                      ? NetworkImage(widget.user.profilePicUrl!)
                      : null,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: widget.user.profilePicUrl == null
                      ? Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.user.organization != null)
                    Text(
                      widget.user.organization!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.brandPrimary,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brandPrimary, AppColors.accentRose],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

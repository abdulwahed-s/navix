import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../survey/domain/repositories/survey_repository.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';
import '../bloc/comment_bloc.dart';
import '../widgets/author_info_widget.dart';
import '../widgets/comment_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/vote_buttons.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  PostEntity? _post;
  bool _isLoadingPost = true;
  String? _postError;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _commentListController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadPost();
    _commentFocusNode.addListener(() => setState(() {}));
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _commentListController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _floatingController.dispose();
    _commentListController.dispose();
    super.dispose();
  }

  void _loadComments() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<CommentBloc>().add(
      LoadComments(postId: widget.postId, currentUserId: userId),
    );
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoadingPost = true;
      _postError = null;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repository = sl<CommunityRepository>();

    final result = await repository.getPost(
      postId: widget.postId,
      currentUserId: userId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingPost = false;
          _postError = failure.message;
        });
      },
      (post) {
        setState(() {
          _post = post;
          _isLoadingPost = false;
          _postError = null;
        });
      },
    );
  }

  void _handlePostVote(String voteType) {
    if (_post == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String newVoteType = voteType;
    if (_post!.userVote == VoteType.up && voteType == 'up') {
      newVoteType = 'none';
    } else if (_post!.userVote == VoteType.down && voteType == 'down') {
      newVoteType = 'none';
    }

    final originalPost = _post!;

    int newUpvotes = _post!.upvotes;
    int newDownvotes = _post!.downvotes;
    VoteType newUserVote = VoteType.none;

    if (_post!.userVote == VoteType.up) {
      newUpvotes--;
    } else if (_post!.userVote == VoteType.down) {
      newDownvotes--;
    }

    if (newVoteType == 'up') {
      newUpvotes++;
      newUserVote = VoteType.up;
    } else if (newVoteType == 'down') {
      newDownvotes++;
      newUserVote = VoteType.down;
    }

    setState(() {
      _post = PostEntity(
        id: _post!.id,
        authorId: _post!.authorId,
        title: _post!.title,
        content: _post!.content,
        imageUrl: _post!.imageUrl,
        postType: _post!.postType,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
        userVote: newUserVote,
        commentCount: _post!.commentCount,
        createdAt: _post!.createdAt,
        updatedAt: _post!.updatedAt,
        edited: _post!.edited,
      );
    });

    final repository = sl<CommunityRepository>();
    repository
        .votePost(postId: widget.postId, userId: userId, voteType: newVoteType)
        .then((result) {
          result.fold((failure) {
            if (mounted) {
              setState(() => _post = originalPost);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }, (_) {});
        });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (!mounted) return;

    context.read<CommentBloc>().add(
      AddCommentEvent(
        postId: widget.postId,
        authorId: userId,
        content: _commentController.text.trim(),
      ),
    );

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showReplyDialog(CommentEntity comment) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        Icons.reply_rounded,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reply to comment',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.brandLightGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),

                _buildGlassmorphicInput(
                  controller: replyController,
                  hintText: l10n.writeReply,
                  maxLines: 4,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandPrimary,
                            AppColors.accentRose,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (replyController.text.trim().isEmpty) return;

                            final userId =
                                FirebaseAuth.instance.currentUser?.uid ?? '';

                            if (!mounted) return;

                            this.context.read<CommentBloc>().add(
                              ReplyToCommentEvent(
                                postId: widget.postId,
                                parentCommentId: comment.id,
                                authorId: userId,
                                content: replyController.text.trim(),
                                parentDepth: comment.depth,
                              ),
                            );

                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.postReply,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCommentVote(CommentEntity comment, String voteType) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String newVoteType = voteType;
    if (comment.userVote == VoteType.up && voteType == 'up') {
      newVoteType = 'none';
    } else if (comment.userVote == VoteType.down && voteType == 'down') {
      newVoteType = 'none';
    }

    context.read<CommentBloc>().add(
      VoteCommentEvent(
        postId: widget.postId,
        commentId: comment.id,
        userId: userId,
        voteType: newVoteType,
      ),
    );
  }

  void _showEditCommentDialog(CommentEntity comment) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.editComment),
        content: TextField(
          controller: controller,
          maxLength: 2000,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            labelText: l10n.comment,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              Navigator.pop(dialogContext);

              final useCase = sl<UpdateCommentUseCase>();
              final result = await useCase(
                UpdateCommentParams(
                  postId: widget.postId,
                  commentId: comment.id,
                  content: controller.text.trim(),
                ),
              );

              if (!mounted) return;

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.commentUpdated),
                        ],
                      ),
                      backgroundColor: AppColors.successDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  _loadComments();
                },
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(CommentEntity comment) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteComment),
        content: Text(l10n.confirmDeleteComment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final useCase = sl<DeleteCommentUseCase>();
              final result = await useCase(
                DeleteCommentParams(
                  postId: widget.postId,
                  commentId: comment.id,
                ),
              );

              if (!mounted) return;

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.commentDeleted),
                        ],
                      ),
                      backgroundColor: AppColors.successDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  _loadComments();
                },
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showDeletePostDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deletePost),
        content: Text(l10n.confirmDeletePost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final useCase = sl<DeletePostUseCase>();
              final result = await useCase(
                DeletePostParams(postId: widget.postId),
              );

              if (!mounted) return;

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.postDeleted),
                        ],
                      ),
                      backgroundColor: AppColors.successDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  context.pop();
                },
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        return sl<CommentBloc>()
          ..add(LoadComments(postId: widget.postId, currentUserId: userId));
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            l10n.community,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Stack(
          children: [
            _buildAnimatedBackground(isDark),

            _buildFloatingDecorations(isDark, size),

            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildPostSection(theme, l10n, userId, isDark),
                        ),

                        SliverToBoxAdapter(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.brandPrimary.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: _buildCommentsHeader(theme, l10n),
                        ),

                        _buildCommentsList(theme, l10n, userId, isDark),
                      ],
                    ),
                  ),

                  _buildCommentInput(theme, l10n, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.12),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentMint.withValues(alpha: 0.1),
                      AppColors.brandCream,
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingDecorations(bool isDark, Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -40 + _floatingAnimation.value,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.15),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200 - _floatingAnimation.value * 0.5,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentLavender.withValues(alpha: 0.15),
                      AppColors.accentLavender.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostSection(
    ThemeData theme,
    AppLocalizations l10n,
    String userId,
    bool isDark,
  ) {
    if (_isLoadingPost) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_postError != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _postError!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadPost,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_post == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.brandPrimary.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AuthorInfoWidget(
                        authorId: _post!.authorId,
                        createdAt: _post!.createdAt,
                        avatarRadius: 22,
                      ),
                    ),
                    if (_post!.edited)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentGold.withValues(alpha: 0.2),
                              AppColors.accentGold.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 12,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.edited,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),

                    if (_post!.authorId == userId)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.push(
                              '/community/post/${_post!.id}/edit',
                              extra: _post,
                            );
                          } else if (value == 'delete') {
                            _showDeletePostDialog();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.editPost),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.deletePost,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  _post!.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [AppColors.brandPrimary, AppColors.accentRose],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  _post!.content,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),

                if (_post!.imageUrl != null) ...[
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: _post!.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.surfaceContainerHighest,
                                  theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: theme.colorScheme.onErrorContainer,
                              size: 48,
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_post!.isSurveyPost) ...[
                  const SizedBox(height: 20),
                  _buildSurveyCard(theme, l10n, userId, isDark),
                ],

                const SizedBox(height: 20),

                VoteButtons(
                  upvotes: _post!.upvotes,
                  downvotes: _post!.downvotes,
                  userVote: _post!.userVote,
                  onUpvote: () => _handlePostVote('up'),
                  onDownvote: () => _handlePostVote('down'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyCard(
    ThemeData theme,
    AppLocalizations l10n,
    String userId,
    bool isDark,
  ) {
    final surveyId = _post!.surveyId;
    final projectId = _post!.surveyProjectId;

    if (surveyId == null || projectId == null) {
      return const SizedBox.shrink();
    }

    final surveyRepo = sl<SurveyRepository>();

    return FutureBuilder<bool>(
      future: surveyRepo.hasUserResponded(projectId, surveyId, userId),
      builder: (context, snapshot) {
        final hasResponded = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hasResponded
                  ? [
                      AppColors.successDark.withValues(alpha: 0.15),
                      AppColors.accentMint.withValues(alpha: 0.1),
                    ]
                  : isDark
                  ? [
                      AppColors.darkPrimary.withValues(alpha: 0.15),
                      AppColors.accentRose.withValues(alpha: 0.1),
                    ]
                  : [
                      AppColors.brandPrimary.withValues(alpha: 0.1),
                      AppColors.accentRose.withValues(alpha: 0.05),
                    ],
            ),
            border: Border.all(
              color: hasResponded
                  ? AppColors.successDark.withValues(alpha: 0.3)
                  : AppColors.brandPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasResponded
                      ? AppColors.successDark.withValues(alpha: 0.2)
                      : AppColors.brandPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasResponded
                      ? Icons.check_circle_outline
                      : Icons.poll_outlined,
                  size: 24,
                  color: hasResponded
                      ? AppColors.successDark
                      : AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.survey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasResponded
                            ? AppColors.successDark
                            : AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasResponded
                          ? l10n.thankYouAlreadyCompleted
                          : l10n.tapToTakeSurvey,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (hasResponded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successDark.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.successDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.completed,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.successDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () =>
                      context.push('/project/$projectId/survey/$surveyId/take'),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(l10n.takeSurvey),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentMint.withValues(alpha: 0.3),
                  AppColors.accentMint.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.successDark,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.comments,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(
    ThemeData theme,
    AppLocalizations l10n,
    String userId,
    bool isDark,
  ) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentsLoaded) {
          _commentListController.forward(from: 0);
        }
      },
      builder: (context, state) {
        if (state is CommentsLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (state is CommentError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadComments,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is CommentsEmpty) {
          return SliverToBoxAdapter(
            child: CommunityEmptyState.noComments(
              title: l10n.noCommentsYet,
              message: l10n.beTheFirst,
            ),
          );
        }

        if (state is CommentsLoaded || state is CommentAdding) {
          final comments = state is CommentsLoaded
              ? state.comments
              : (state as CommentAdding).currentComments;

          if (comments.isEmpty) {
            return SliverToBoxAdapter(
              child: CommunityEmptyState.noComments(
                title: l10n.noCommentsYet,
                message: l10n.beTheFirst,
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final comment = comments[index];
                final isAuthor = comment.authorId == userId;

                return AnimatedBuilder(
                  animation: _commentListController,
                  builder: (context, child) {
                    final delay = index * 0.08;
                    final animationValue = Curves.easeOutCubic.transform(
                      (_commentListController.value - delay).clamp(0.0, 1.0),
                    );
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - animationValue)),
                      child: Opacity(
                        opacity: animationValue.clamp(0.0, 1.0),
                        child: CommentWidget(
                          comment: comment,
                          isAuthor: isAuthor,
                          onReply: () => _showReplyDialog(comment),
                          onUpvote: () => _handleCommentVote(comment, 'up'),
                          onDownvote: () => _handleCommentVote(comment, 'down'),
                          onDelete: isAuthor
                              ? () => _showDeleteCommentDialog(comment)
                              : null,
                          onEdit: isAuthor
                              ? () => _showEditCommentDialog(comment)
                              : null,
                        ),
                      ),
                    );
                  },
                );
              }, childCount: comments.length),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildCommentInput(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final isFocused = _commentFocusNode.hasFocus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: l10n.addComment,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: AppColors.brandPrimary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandPrimary, AppColors.accentRose],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _addComment,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              tooltip: l10n.postComment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicInput({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    required bool isDark,
    required ThemeData theme,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLength: 2000,
            maxLines: maxLines,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}

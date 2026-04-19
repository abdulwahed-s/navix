import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../survey/domain/repositories/survey_repository.dart';
import '../../domain/entities/post_entity.dart';
import 'author_info_widget.dart';
import 'vote_buttons.dart';
import 'package:share_plus/share_plus.dart';
import 'share_post_dialog.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final bool isAuthor;
  final VoidCallback onTap;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onDelete;
  final int animationIndex;

  const PostCard({
    super.key,
    required this.post,
    required this.isAuthor,
    required this.onTap,
    required this.onUpvote,
    required this.onDownvote,
    this.onAuthorTap,
    this.onDelete,
    this.animationIndex = 0,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppColors.brandPrimary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuthorRow(context, theme, colorScheme, l10n),
                      const SizedBox(height: 14),

                      _buildTitle(theme),
                      const SizedBox(height: 8),

                      Text(
                        widget.post.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (widget.post.imageUrl != null) ...[
                        const SizedBox(height: 14),
                        _buildPostImage(theme, colorScheme),
                      ],

                      if (widget.post.isSurveyPost) ...[
                        const SizedBox(height: 14),
                        _buildSurveyCard(context, theme, colorScheme, isDark),
                      ],

                      const SizedBox(height: 14),

                      _buildActionRow(context, theme, colorScheme, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: widget.onAuthorTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: AuthorInfoWidget(
                authorId: widget.post.authorId,
                createdAt: widget.post.createdAt,
                avatarRadius: 20,
              ),
            ),

            if (widget.post.edited)
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
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.brandPrimary, AppColors.accentRose],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final surveyId = widget.post.surveyId;
    final projectId = widget.post.surveyProjectId;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (surveyId == null || projectId == null || currentUserId == null) {
      return const SizedBox.shrink();
    }

    final surveyRepo = sl<SurveyRepository>();

    return FutureBuilder<bool>(
      future: surveyRepo.hasUserResponded(projectId, surveyId, currentUserId),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                  onPressed: () => _navigateToSurvey(context),
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

  void _navigateToSurvey(BuildContext context) {
    final surveyId = widget.post.surveyId;
    final projectId = widget.post.surveyProjectId;
    if (surveyId != null && projectId != null) {
      context.push('/project/$projectId/survey/$surveyId/take');
    }
  }

  Widget _buildPostImage(ThemeData theme, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.errorContainer,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 48,
                ),
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
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        VoteButtons(
          upvotes: widget.post.upvotes,
          downvotes: widget.post.downvotes,
          userVote: widget.post.userVote,
          onUpvote: widget.onUpvote,
          onDownvote: widget.onDownvote,
        ),
        const SizedBox(width: 12),

        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: widget.post.commentCount.toString(),
          onTap: widget.onTap,
          isDark: isDark,
          colorScheme: colorScheme,
        ),

        const Spacer(),

        _buildIconButton(
          icon: Icons.share_outlined,
          onTap: () => _showShareOptions(context, widget.post),
          tooltip: l10n.sharePost,
          isDark: isDark,
          colorScheme: colorScheme,
        ),

        if (widget.isAuthor)
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(context, value, widget.post, widget.onDelete),
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(l10n.editPost),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text(
                      l10n.deletePost,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  static void _showShareOptions(BuildContext context, PostEntity post) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      l10n.shareToChat,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      SharePostDialog.show(context, post);
                    },
                  ),

                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentMint.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        color: AppColors.successDark,
                      ),
                    ),
                    title: Text(
                      l10n.shareToApp,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareToExternalApp(post);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _shareToExternalApp(PostEntity post) {
    final text =
        '${post.title}\n\n${post.content}\n\nShared from Navix Community';
    SharePlus.instance.share(ShareParams(text: text, subject: post.title));
  }

  static void _handleMenuAction(
    BuildContext context,
    String action,
    PostEntity post,
    VoidCallback? onDelete,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (action == 'edit') {
      context.push('/community/post/${post.id}/edit', extra: post);
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              onPressed: () {
                Navigator.pop(dialogContext);

                onDelete?.call();
              },
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
    }
  }
}

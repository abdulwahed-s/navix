import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/comment_entity.dart';
import 'author_info_widget.dart';
import 'vote_buttons.dart';

class CommentWidget extends StatefulWidget {
  final CommentEntity comment;
  final VoidCallback onReply;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAuthor;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onUpvote,
    required this.onDownvote,
    this.onEdit,
    this.onDelete,
    this.isAuthor = false,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  Color _getDepthColor(int depth) {
    final colors = [
      AppColors.brandPrimary,
      AppColors.accentGold,
      AppColors.accentMint,
      AppColors.accentLavender,
      AppColors.accentRose,
    ];
    return colors[depth % colors.length];
  }

  List<Color> _getDepthGradient(int depth) {
    final baseColor = _getDepthColor(depth);
    return [baseColor, baseColor.withValues(alpha: 0.5)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final indentation = widget.comment.depth * 20.0;
    final depthGradient = _getDepthGradient(widget.comment.depth);

    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.comment.depth > 0)
              Container(
                width: 3,
                height: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: depthGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: depthGradient[0].withValues(alpha: 0.3),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),

            Expanded(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : AppColors.brandPrimary.withValues(
                                      alpha: 0.08,
                                    ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AuthorInfoWidget(
                                      authorId: widget.comment.authorId,
                                      createdAt: widget.comment.createdAt,
                                      avatarRadius: 14,
                                    ),
                                  ),

                                  if (widget.isAuthor)
                                    _buildAuthorMenu(theme, colorScheme, l10n),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Text(
                                widget.comment.content,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              _buildActionsRow(
                                context,
                                theme,
                                colorScheme,
                                l10n,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorMenu(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (widget.onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(l10n.editComment),
              ],
            ),
          ),
        if (widget.onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                const SizedBox(width: 10),
                Text(
                  l10n.deleteComment,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        if (value == 'edit' && widget.onEdit != null) {
          widget.onEdit!();
        } else if (value == 'delete' && widget.onDelete != null) {
          widget.onDelete!();
        }
      },
    );
  }

  Widget _buildActionsRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        VoteButtons(
          upvotes: widget.comment.upvotes,
          downvotes: widget.comment.downvotes,
          userVote: widget.comment.userVote,
          onUpvote: widget.onUpvote,
          onDownvote: widget.onDownvote,
          isCompact: true,
        ),
        const SizedBox(width: 12),

        if (widget.comment.depth < 5)
          _ReplyButton(
            onTap: widget.onReply,
            label: l10n.reply,
            isDark: isDark,
          ),

        if (widget.comment.replyCount > 0) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentLavender.withValues(alpha: 0.3),
                  AppColors.accentLavender.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentLavender.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.accentLavender
                      : AppColors.brandPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.accentLavender
                        : AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReplyButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final bool isDark;

  const _ReplyButton({
    required this.onTap,
    required this.label,
    required this.isDark,
  });

  @override
  State<_ReplyButton> createState() => _ReplyButtonState();
}

class _ReplyButtonState extends State<_ReplyButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: _isHovered || _isPressed
                ? LinearGradient(
                    colors: [
                      AppColors.brandPrimary.withValues(alpha: 0.15),
                      AppColors.accentRose.withValues(alpha: 0.1),
                    ],
                  )
                : null,
            color: _isHovered || _isPressed
                ? null
                : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(20),
            border: _isHovered || _isPressed
                ? Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.reply_rounded,
                size: 16,
                color: _isHovered || _isPressed
                    ? AppColors.brandPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isHovered || _isPressed
                      ? AppColors.brandPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

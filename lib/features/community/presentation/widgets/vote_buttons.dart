import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/post_entity.dart';

class VoteButtons extends StatefulWidget {
  final int upvotes;
  final int downvotes;
  final VoteType userVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final bool isCompact;

  const VoteButtons({
    super.key,
    required this.upvotes,
    required this.downvotes,
    required this.userVote,
    required this.onUpvote,
    required this.onDownvote,
    this.isCompact = false,
  });

  @override
  State<VoteButtons> createState() => _VoteButtonsState();
}

class _VoteButtonsState extends State<VoteButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isUpvotePressed = false;
  bool _isDownvotePressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  int get voteScore => widget.upvotes - widget.downvotes;

  void _handleUpvote() {
    HapticFeedback.lightImpact();
    setState(() => _isUpvotePressed = true);
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      setState(() => _isUpvotePressed = false);
    });
    widget.onUpvote();
  }

  void _handleDownvote() {
    HapticFeedback.lightImpact();
    setState(() => _isDownvotePressed = true);
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      setState(() => _isDownvotePressed = false);
    });
    widget.onDownvote();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color scoreColor;
    Color scoreBgColor;
    if (voteScore > 0) {
      scoreColor = AppColors.upvoteActive;
      scoreBgColor = AppColors.votePositive.withValues(alpha: 0.15);
    } else if (voteScore < 0) {
      scoreColor = AppColors.downvoteActive;
      scoreBgColor = AppColors.voteNegative.withValues(alpha: 0.15);
    } else {
      scoreColor = colorScheme.onSurfaceVariant;
      scoreBgColor = Colors.transparent;
    }

    final iconSize = widget.isCompact ? 18.0 : 22.0;
    final buttonSize = widget.isCompact ? 32.0 : 40.0;
    final spacing = widget.isCompact ? 2.0 : 4.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 4 : 6,
        vertical: widget.isCompact ? 2 : 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVoteButton(
            isUpvote: true,
            isActive: widget.userVote == VoteType.up,
            isPressed: _isUpvotePressed,
            iconSize: iconSize,
            buttonSize: buttonSize,
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          SizedBox(width: spacing),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 8 : 12,
              vertical: widget.isCompact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: scoreBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                voteScore.toString(),
                key: ValueKey<int>(voteScore),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isCompact ? 13 : 15,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing),

          _buildVoteButton(
            isUpvote: false,
            isActive: widget.userVote == VoteType.down,
            isPressed: _isDownvotePressed,
            iconSize: iconSize,
            buttonSize: buttonSize,
            colorScheme: colorScheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required bool isUpvote,
    required bool isActive,
    required bool isPressed,
    required double iconSize,
    required double buttonSize,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final activeColor = isUpvote
        ? AppColors.upvoteActive
        : AppColors.downvoteActive;
    final icon = isUpvote
        ? (isActive ? Icons.arrow_upward : Icons.arrow_upward_outlined)
        : (isActive ? Icons.arrow_downward : Icons.arrow_downward_outlined);

    return GestureDetector(
      onTap: isUpvote ? _handleUpvote : _handleDownvote,
      child: AnimatedScale(
        scale: isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isActive ? activeColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

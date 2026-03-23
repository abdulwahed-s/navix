import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../community/domain/entities/post_entity.dart';
import '../../../../community/presentation/widgets/empty_state.dart';
import '../../../../community/presentation/widgets/post_card.dart';

class ProfileViewPostsTab extends StatelessWidget {
  final bool isLoading;

  final String? error;

  final List<PostEntity>? posts;

  final String currentUserId;

  final AnimationController postsListController;

  final String noPostsTitle;

  final String noPostsMessage;

  final String retryLabel;

  final VoidCallback onRetry;

  final void Function(PostEntity post) onPostTap;

  final void Function(PostEntity post) onUpvote;

  final void Function(PostEntity post) onDownvote;

  final void Function(PostEntity post)? onDelete;

  const ProfileViewPostsTab({
    super.key,
    required this.isLoading,
    required this.error,
    required this.posts,
    required this.currentUserId,
    required this.postsListController,
    required this.noPostsTitle,
    required this.noPostsMessage,
    required this.retryLabel,
    required this.onRetry,
    required this.onPostTap,
    required this.onUpvote,
    required this.onDownvote,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorState(context);
    }

    if (posts == null || posts!.isEmpty) {
      return CommunityEmptyState.noPosts(
        title: noPostsTitle,
        message: noPostsMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: posts!.length,
      itemBuilder: (context, index) {
        final post = posts![index];

        return AnimatedBuilder(
          animation: postsListController,
          builder: (context, child) {
            final delay = index * 0.08;
            final animationValue = Curves.easeOutCubic.transform(
              (postsListController.value - delay).clamp(0.0, 1.0),
            );
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue.clamp(0.0, 1.0),
                child: PostCard(
                  post: post,
                  isAuthor: post.authorId == currentUserId,
                  onTap: () => onPostTap(post),
                  onUpvote: () => onUpvote(post),
                  onDownvote: () => onDownvote(post),
                  onAuthorTap: null,
                  onDelete: post.authorId == currentUserId && onDelete != null
                      ? () => onDelete!(post)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            error!,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandPrimary, AppColors.accentRose],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        retryLabel,
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
    );
  }
}

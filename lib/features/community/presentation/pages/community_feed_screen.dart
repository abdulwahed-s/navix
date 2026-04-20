import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../bloc/community_feed_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/post_card.dart';
import '../widgets/post_skeleton.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  PostSortType _currentSort = PostSortType.hot;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeed();
    });
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatingController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _loadFeed() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<CommunityFeedBloc>().add(
      LoadFeed(currentUserId: userId, sortType: _currentSort),
    );
  }

  void _onScroll() {
    if (_isBottom) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<CommunityFeedBloc>().add(
        LoadMorePosts(currentUserId: userId, sortType: _currentSort),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleVote(PostEntity post, String voteType) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String newVoteType = voteType;
    if (post.userVote == VoteType.up && voteType == 'up') {
      newVoteType = 'none';
    } else if (post.userVote == VoteType.down && voteType == 'down') {
      newVoteType = 'none';
    }

    context.read<CommunityFeedBloc>().add(
      VotePostInFeed(postId: post.id, userId: userId, voteType: newVoteType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme, l10n, isDark),
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark, size),

          _buildFloatingDecorations(isDark, size),

          SafeArea(
            child: BlocConsumer<CommunityFeedBloc, CommunityFeedState>(
              listener: (context, state) {
                if (state is FeedLoaded) {
                  _listAnimationController.forward(from: 0);
                }
              },
              builder: (context, state) {
                if (state is FeedLoading) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const PostSkeleton(),
                  );
                }

                if (state is FeedLoadingMore) {
                  return _buildPostList(
                    context,
                    state.currentPosts,
                    hasMore: true,
                    isLoadingMore: true,
                    isDark: isDark,
                  );
                }

                if (state is FeedError) {
                  return _buildErrorState(theme, l10n, state.message);
                }

                if (state is FeedLoaded) {
                  if (state.posts.isEmpty) {
                    return CommunityEmptyState.noPosts(
                      title: l10n.noPostsYet,
                      message: l10n.beTheFirstToPost,
                      actionLabel: l10n.createPost,
                      onAction: () {
                        context.push('/community/create');
                      },
                    );
                  }

                  return _buildPostList(
                    context,
                    state.posts,
                    hasMore: state.hasMore,
                    isLoadingMore: false,
                    isDark: isDark,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(l10n),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return AppBar(
      title: Text(
        l10n.communityFeed,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<PostSortType>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sort_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ),
            tooltip: l10n.sortBy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (sortType) {
              setState(() {
                _currentSort = sortType;
              });
              final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<CommunityFeedBloc>().add(
                ChangeSortType(sortType: sortType, currentUserId: userId),
              );
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(
                value: PostSortType.hot,
                icon: Icons.local_fire_department_rounded,
                label: l10n.sortHot,
                isSelected: _currentSort == PostSortType.hot,
                color: AppColors.accentGold,
                theme: theme,
              ),
              _buildSortMenuItem(
                value: PostSortType.latest,
                icon: Icons.schedule_rounded,
                label: l10n.sortLatest,
                isSelected: _currentSort == PostSortType.latest,
                color: AppColors.accentMint,
                theme: theme,
              ),
              _buildSortMenuItem(
                value: PostSortType.top,
                icon: Icons.trending_up_rounded,
                label: l10n.sortTop,
                isSelected: _currentSort == PostSortType.top,
                color: AppColors.brandPrimary,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<PostSortType> _buildSortMenuItem({
    required PostSortType value,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required ThemeData theme,
  }) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : null,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check_rounded, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark, Size size) {
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
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.15),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentLavender.withValues(alpha: 0.15),
                      AppColors.brandCream,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: _BackgroundPatternPainter(
              isDark: isDark,
              animationValue: _floatingAnimation.value,
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
              top: -60 + _floatingAnimation.value,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandPrimary.withValues(alpha: 0.15),
                      AppColors.brandPrimary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 150 - _floatingAnimation.value * 0.8,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(alpha: 0.2),
                      AppColors.accentMint.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.35 + _floatingAnimation.value * 0.5,
              right: -100,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.12),
                      AppColors.accentGold.withValues(alpha: 0.0),
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

  Widget _buildErrorState(
    ThemeData theme,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loadFeed,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    List<PostEntity> posts, {
    required bool hasMore,
    required bool isLoadingMore,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        context.read<CommunityFeedBloc>().add(
          RefreshFeed(currentUserId: userId, sortType: _currentSort),
        );
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.brandPrimary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: posts.length + (hasMore || isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.brandPrimary),
                  ),
                ),
              ),
            );
          }

          final post = posts[index];
          return AnimatedBuilder(
            animation: _listAnimationController,
            builder: (context, child) {
              final delay = index * 0.06;
              final animationValue = Curves.easeOutCubic.transform(
                (_listAnimationController.value - delay).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue.clamp(0.0, 1.0),
                  child: PostCard(
                    post: post,
                    animationIndex: index,
                    onTap: () {
                      context.push('/community/post/${post.id}');
                    },
                    onUpvote: () => _handleVote(post, 'up'),
                    onDownvote: () => _handleVote(post, 'down'),
                    onAuthorTap: () async {
                      final repository = sl<ProfileRepository>();
                      final result = await repository.getProfile(post.authorId);

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
                        (profile) {
                          if (profile != null) {
                            context.push('/profile', extra: profile);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Profile not found'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        },
                      );
                    },
                    isAuthor:
                        post.authorId == FirebaseAuth.instance.currentUser?.uid,
                    onDelete: () async {
                      context.read<CommunityFeedBloc>().add(
                        OptimisticDeletePost(postId: post.id),
                      );

                      final useCase = sl<DeletePostUseCase>();
                      final result = await useCase(
                        DeletePostParams(postId: post.id),
                      );

                      if (!mounted) return;

                      result.fold(
                        (failure) {
                          final userId =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          context.read<CommunityFeedBloc>().add(
                            RefreshFeed(
                              currentUserId: userId,
                              sortType: _currentSort,
                            ),
                          );
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
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
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
                        },
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

  Widget _buildFab(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          context.push('/community/create');
        },
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.createPost,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final bool isDark;
  final double animationValue;

  _BackgroundPatternPainter({
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? Colors.white : AppColors.brandPrimary).withValues(
        alpha: 0.02,
      );

    final random = math.Random(42);
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          random.nextDouble() * size.height +
          animationValue * (random.nextDouble() - 0.5) * 5;
      final radius = 20 + random.nextDouble() * 60;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../community/domain/entities/post_entity.dart';
import '../../../community/domain/repositories/community_repository.dart';
import '../../../community/domain/usecases/delete_post_usecase.dart';
import '../../../community/domain/usecases/get_user_posts_usecase.dart';
import '../../data/models/skill_test_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/skill_level.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_view/profile_view_animated_background.dart';
import '../widgets/profile_view/profile_view_avatar.dart';
import '../widgets/profile_view/profile_view_edit_button.dart';
import '../widgets/profile_view/profile_view_error_state.dart';
import '../widgets/profile_view/profile_view_floating_decorations.dart';
import '../widgets/profile_view/profile_view_links_card.dart';
import '../widgets/profile_view/profile_view_name_section.dart';
import '../widgets/profile_view/profile_view_posts_tab.dart';
import '../widgets/profile_view/profile_view_section_header.dart';
import '../widgets/profile_view/profile_view_skills_card.dart';
import '../widgets/profile_view/profile_view_tab_bar.dart';

class ProfileViewScreen extends StatefulWidget {
  final ProfileEntity? profile;

  const ProfileViewScreen({super.key, this.profile});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<PostEntity>? _userPosts;
  bool _isLoadingPosts = true;
  String? _postsError;
  ProfileEntity? _loadedProfile;
  bool _isLoadingProfile = false;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _postsListController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAnimations();

    if (widget.profile == null) {
      _loadCurrentUserProfile();
    } else {
      _loadedProfile = widget.profile;
      _loadUserPosts();
    }
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _postsListController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _postsListController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ProfileBloc>().add(LoadProfile(userId: userId));
  }

  Future<void> _loadUserPosts() async {
    if (_loadedProfile == null) return;
    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
    });

    final useCase = sl<GetUserPostsUseCase>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final result = await useCase(
      GetUserPostsParams(
        userId: _loadedProfile!.userId,
        currentUserId: currentUserId,
        limit: 50,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingPosts = false;
          _postsError = failure.message;
        });
      },
      (posts) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
          _postsError = null;
        });
        _postsListController.forward(from: 0);
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _updateProfileAfterTest(ProfileEntity profile, SkillTestResult result) {
    final updatedSkills = profile.skills.map((skill) {
      final skillName = skill.skillName;
      final passed = result.passedSkills[skillName] ?? false;
      final levelString = result.skillLevels[skillName];

      if (passed && levelString != null) {
        return skill.copyWith(
          isVerified: true,
          skillLevel: SkillLevel.fromString(levelString),
        );
      }
      return skill;
    }).toList();

    final updatedProfile = ProfileEntity(
      userId: profile.userId,
      name: profile.name,
      organization: profile.organization,
      profilePicUrl: profile.profilePicUrl,
      skills: updatedSkills,
      portfolioLink: profile.portfolioLink,
      githubLink: profile.githubLink,
      otherLinks: profile.otherLinks,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<ProfileBloc>().add(
      SaveProfile(profile: updatedProfile, isNew: false),
    );

    setState(() {
      _loadedProfile = updatedProfile;
    });

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.skillsVerifiedSuccess),
          ],
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    if (widget.profile == null) {
      return BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            setState(() {
              _loadedProfile = state.profile;
              _isLoadingProfile = false;
            });
            _loadUserPosts();
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || _isLoadingProfile) {
            return _buildLoadingScaffold(l10n, isDark, size);
          }

          if (state is ProfileError) {
            return _buildErrorScaffold(l10n, isDark, size, state.message);
          }

          if (_loadedProfile == null) {
            return _buildLoadingScaffold(l10n, isDark, size);
          }

          return _buildProfileScaffold(context, l10n, theme, isDark, size);
        },
      );
    }

    _loadedProfile = widget.profile;
    return _buildProfileScaffold(context, l10n, theme, isDark, size);
  }

  Widget _buildLoadingScaffold(AppLocalizations l10n, bool isDark, Size size) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ProfileViewAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),
          ProfileViewFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorScaffold(
    AppLocalizations l10n,
    bool isDark,
    Size size,
    String message,
  ) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ProfileViewAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),
          ProfileViewFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),
          ProfileViewErrorState(
            message: message,
            retryLabel: l10n.retry,
            onRetry: _loadCurrentUserProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScaffold(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Size size,
  ) {
    final profile = _loadedProfile!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.profile,
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
          ProfileViewAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),

          ProfileViewFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          SafeArea(
            child: Column(
              children: [
                ProfileViewTabBar(
                  tabController: _tabController,
                  isDark: isDark,
                  isLoadingPosts: _isLoadingPosts,
                  postsCount: _userPosts?.length ?? 0,
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(context, l10n, profile, isDark),

                      ProfileViewPostsTab(
                        isLoading: _isLoadingPosts,
                        error: _postsError,
                        posts: _userPosts,
                        currentUserId:
                            FirebaseAuth.instance.currentUser?.uid ?? '',
                        postsListController: _postsListController,
                        noPostsTitle: l10n.noPostsYet,
                        noPostsMessage:
                            'This user hasn\'t created any posts yet.',
                        retryLabel: l10n.retry,
                        onRetry: _loadUserPosts,
                        onPostTap: (post) {
                          context.push('/community/post/${post.id}');
                        },
                        onUpvote: (post) => _handleVote(post, 'up'),
                        onDownvote: (post) => _handleVote(post, 'down'),
                        onDelete: (post) =>
                            _deletePost(post, Theme.of(context), l10n),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    AppLocalizations l10n,
    ProfileEntity profile,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileViewAvatar(
            profilePicUrl: profile.profilePicUrl,
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          ProfileViewNameSection(
            name: profile.name,
            organization: profile.organization,
            isDark: isDark,
          ),
          const SizedBox(height: 32),

          if (profile.skills.isNotEmpty) ...[
            ProfileViewSectionHeader(
              title: l10n.skills,
              icon: Icons.auto_awesome_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            ProfileViewSkillsCard(
              skills: profile.skills,
              isDark: isDark,
              isOwnProfile:
                  profile.userId == FirebaseAuth.instance.currentUser?.uid,
              onVerifyTap: () async {
                final unverifiedSkills = profile.skills
                    .where((s) => s.isApproved && !s.isVerified)
                    .toList();

                final result = await context.push<SkillTestResult>(
                  AppRoutes.skillTest,
                  extra: unverifiedSkills.map((s) => s.skillName).toList(),
                );

                if (result != null && mounted) {
                  _updateProfileAfterTest(profile, result);
                }
              },
              onRetakeTap: () async {
                final verifiedSkills = profile.skills
                    .where((s) => s.isVerified)
                    .toList();

                final result = await context.push<SkillTestResult>(
                  AppRoutes.skillTest,
                  extra: verifiedSkills.map((s) => s.skillName).toList(),
                );

                if (result != null && mounted) {
                  _updateProfileAfterTest(profile, result);
                }
              },
            ),
            const SizedBox(height: 28),
          ],

          if (_hasLinks) ...[
            ProfileViewSectionHeader(
              title: 'Links',
              icon: Icons.link_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            ProfileViewLinksCard(
              portfolioLink: profile.portfolioLink,
              githubLink: profile.githubLink,
              otherLinks: profile.otherLinks,
              isDark: isDark,
              onLinkTap: _launchUrl,
            ),
            const SizedBox(height: 32),
          ],

          if (profile.userId == FirebaseAuth.instance.currentUser?.uid)
            ProfileViewEditButton(
              label: l10n.editProfile,
              onTap: () => context.push(AppRoutes.profileEdit, extra: profile),
            ),
        ],
      ),
    );
  }

  Future<void> _deletePost(
    PostEntity post,
    ThemeData theme,
    AppLocalizations l10n,
  ) async {
    final useCase = sl<DeletePostUseCase>();
    final result = await useCase(DeletePostParams(postId: post.id));

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

        _loadUserPosts();
      },
    );
  }

  void _handleVote(PostEntity post, String voteType) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String newVoteType = voteType;
    if (post.userVote == VoteType.up && voteType == 'up') {
      newVoteType = 'none';
    } else if (post.userVote == VoteType.down && voteType == 'down') {
      newVoteType = 'none';
    }

    final originalPosts = List<PostEntity>.from(_userPosts ?? []);

    int newUpvotes = post.upvotes;
    int newDownvotes = post.downvotes;
    VoteType newUserVote = VoteType.none;

    if (post.userVote == VoteType.up) {
      newUpvotes--;
    } else if (post.userVote == VoteType.down) {
      newDownvotes--;
    }

    if (newVoteType == 'up') {
      newUpvotes++;
      newUserVote = VoteType.up;
    } else if (newVoteType == 'down') {
      newDownvotes++;
      newUserVote = VoteType.down;
    }

    final updatedPost = PostEntity(
      id: post.id,
      authorId: post.authorId,
      title: post.title,
      content: post.content,
      imageUrl: post.imageUrl,
      postType: post.postType,
      upvotes: newUpvotes,
      downvotes: newDownvotes,
      userVote: newUserVote,
      commentCount: post.commentCount,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      edited: post.edited,
    );

    setState(() {
      _userPosts = _userPosts?.map((p) {
        return p.id == post.id ? updatedPost : p;
      }).toList();
    });

    final repository = sl<CommunityRepository>();
    repository
        .votePost(postId: post.id, userId: userId, voteType: newVoteType)
        .then((result) {
          result.fold((failure) {
            if (mounted) {
              setState(() => _userPosts = originalPosts);
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

  bool get _hasLinks =>
      _loadedProfile?.portfolioLink != null ||
      _loadedProfile?.githubLink != null ||
      (_loadedProfile?.otherLinks.isNotEmpty ?? false);
}

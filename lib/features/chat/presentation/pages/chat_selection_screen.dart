import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatSelectionScreen extends StatefulWidget {
  final String surveyId;
  final String surveyProjectId;
  final String surveyTitle;
  final String surveyDescription;
  final int questionCount;

  const ChatSelectionScreen({
    super.key,
    required this.surveyId,
    required this.surveyProjectId,
    required this.surveyTitle,
    required this.surveyDescription,
    this.questionCount = 0,
  });

  @override
  State<ChatSelectionScreen> createState() => _ChatSelectionScreenState();
}

class _ChatSelectionScreenState extends State<ChatSelectionScreen>
    with TickerProviderStateMixin {
  final _chatRepository = sl<ChatRepository>();

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  List<ProfileEntity> _connectedUsers = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadConnectedUsers();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadConnectedUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    final result = await _chatRepository.getConnectedUsers(currentUser.uid);
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (users) => setState(() {
        _connectedUsers = users;
        _isLoading = false;
      }),
    );
  }

  Future<void> _shareToUser(ProfileEntity user) async {
    setState(() => _isSending = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final convResult = await _chatRepository.getOrCreateConversation(
      currentUserId: currentUser.uid,
      currentUserName: currentUser.displayName ?? 'User',
      otherUserId: user.userId,
      otherUserName: user.name,
    );

    await convResult.fold(
      (failure) async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      (conversation) async {
        final sharedSurvey = SharedSurveyData(
          surveyId: widget.surveyId,
          projectId: widget.surveyProjectId,
          title: widget.surveyTitle,
          description: widget.surveyDescription,
          questionCount: widget.questionCount,
        );

        final sendResult = await _chatRepository.sendSharedSurvey(
          conversationId: conversation.id,
          senderId: currentUser.uid,
          senderName: currentUser.displayName ?? 'User',
          sharedSurvey: sharedSurvey,
        );

        if (mounted) {
          sendResult.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            (_) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.surveySharedSuccessfully),
                  backgroundColor: AppColors.successDark,
                ),
              );
              context.pop();
            },
          );
        }
      },
    );

    if (mounted) setState(() => _isSending = false);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.selectChat,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark, size),
          _buildContent(context, l10n, isDark),
          if (_isSending)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.15),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentRose.withValues(alpha: 0.1),
                      AppColors.brandCream,
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadConnectedUsers();
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_connectedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noConnectionsYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.connectWithPeopleFirst,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSurveyPreview(context, isDark),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.selectRecipient,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _connectedUsers.length,
              itemBuilder: (context, index) {
                final user = _connectedUsers[index];
                return _buildUserCard(context, user, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyPreview(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.brandPrimary.withValues(alpha: 0.15),
                AppColors.accentRose.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: AppColors.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.poll_outlined, color: AppColors.brandPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.surveyTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.questionCount} ${l10n.questions}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, ProfileEntity user, bool isDark) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
      child: InkWell(
        onTap: () => _shareToUser(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.2),
                backgroundImage: user.profilePicUrl != null
                    ? NetworkImage(user.profilePicUrl!)
                    : null,
                child: user.profilePicUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user.organization != null &&
                        user.organization!.isNotEmpty)
                      Text(
                        user.organization!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.send_rounded, color: AppColors.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

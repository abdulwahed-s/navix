import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/community_feed_bloc.dart';

class EditPostScreen extends StatefulWidget {
  final PostEntity post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  bool _isSaving = false;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _initAnimations();
    _titleFocusNode.addListener(() => setState(() {}));
    _contentFocusNode.addListener(() => setState(() {}));
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _titleController.text != widget.post.title ||
      _contentController.text != widget.post.content;

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.discardChanges),
        content: Text(l10n.confirmDiscardChanges),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      context.pop();
      return;
    }

    setState(() => _isSaving = true);

    final l10n = AppLocalizations.of(context)!;

    context.read<CommunityFeedBloc>().add(
      OptimisticUpdatePost(
        postId: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.postUpdated),
          ],
        ),
        backgroundColor: AppColors.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(theme, l10n, isDark),
        body: Stack(
          children: [
            _buildAnimatedBackground(isDark),

            _buildFloatingDecorations(isDark, size),

            SafeArea(child: _buildContent(theme, l10n, isDark)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return AppBar(
      title: Text(
        l10n.editPost,
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
          child: _isSaving
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.brandPrimary,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _hasChanges
                        ? const LinearGradient(
                            colors: [
                              AppColors.brandPrimary,
                              AppColors.accentRose,
                            ],
                          )
                        : null,
                    color: _hasChanges
                        ? null
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _hasChanges ? _saveChanges : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: _hasChanges
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.save,
                              style: TextStyle(
                                color: _hasChanges
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
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
                      AppColors.accentGold.withValues(alpha: 0.08),
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
              top: -50 + _floatingAnimation.value,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.2),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150 - _floatingAnimation.value * 0.8,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentMint.withValues(alpha: 0.15),
                      AppColors.accentMint.withValues(alpha: 0.0),
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

  Widget _buildContent(ThemeData theme, AppLocalizations l10n, bool isDark) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoBox(l10n, isDark),
          const SizedBox(height: 20),

          _buildGlassmorphicField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            labelText: l10n.postTitle,
            hintText: l10n.postTitleHint,
            maxLength: 300,
            maxLines: 2,
            isDark: isDark,
            theme: theme,
            enabled: !_isSaving,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.titleRequired;
              }
              if (value.trim().length < 10) {
                return l10n.titleTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildGlassmorphicField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            labelText: l10n.postContent,
            hintText: l10n.postContentHint,
            maxLength: 10000,
            maxLines: 12,
            isDark: isDark,
            theme: theme,
            enabled: !_isSaving,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.contentRequired;
              }
              return null;
            },
          ),

          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentLavender.withValues(alpha: 0.2),
                    AppColors.accentLavender.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentLavender.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_rounded,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.imageCannotBeChanged,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBox(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  AppColors.accentMint.withValues(alpha: 0.15),
                  AppColors.accentMint.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.successDark.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentMint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.successDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.editPostInfo,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required int maxLength,
    required int maxLines,
    required bool isDark,
    required ThemeData theme,
    required bool enabled,
    required String? Function(String?) validator,
  }) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              border: Border.all(
                color: isFocused
                    ? AppColors.brandPrimary
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05)),
                width: isFocused ? 2 : 1,
              ),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              maxLength: maxLength,
              maxLines: maxLines,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                counterStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              validator: validator,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }
}

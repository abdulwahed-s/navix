import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/create_post_bloc.dart';

class CreatePostScreen extends StatefulWidget {
  final String? surveyId;
  final String? surveyProjectId;
  final String? surveyTitle;
  final String? surveyDescription;
  final int? questionCount;

  const CreatePostScreen({
    super.key,
    this.surveyId,
    this.surveyProjectId,
    this.surveyTitle,
    this.surveyDescription,
    this.questionCount,
  });

  bool get isSurveyPost => surveyId != null && surveyProjectId != null;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  late final CreatePostBloc _createPostBloc;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _createPostBloc = sl<CreatePostBloc>();
    _initAnimations();
    _titleFocusNode.addListener(() => setState(() {}));
    _contentFocusNode.addListener(() => setState(() {}));

    if (widget.isSurveyPost) {
      _titleController.text = '📋 ${widget.surveyTitle ?? 'Take my survey'}!';
      _contentController.text =
          widget.surveyDescription ??
          'I created a survey with ${widget.questionCount ?? 0} questions. Please take a moment to fill it out!';
    }
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
    _createPostBloc.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return true;
    }

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.discardPost),
        content: Text(l10n.confirmDiscardPost),
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (!mounted) return;

    _createPostBloc.add(
      CreatePostSubmitted(
        authorId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: _selectedImage?.path,
        surveyId: widget.surveyId,
        surveyProjectId: widget.surveyProjectId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _createPostBloc,
      child: BlocConsumer<CreatePostBloc, CreatePostState>(
        listener: (context, state) {
          if (state is CreatePostSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(l10n.postCreated),
                  ],
                ),
                backgroundColor: AppColors.successDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                context.pop();
              }
            });
          } else if (state is CreatePostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
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
              appBar: _buildAppBar(theme, l10n, isDark, state),
              body: Stack(
                children: [
                  _buildAnimatedBackground(isDark, size),

                  _buildFloatingDecorations(isDark, size),

                  SafeArea(child: _buildContent(theme, l10n, isDark, state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
    CreatePostState state,
  ) {
    final isLoading = state is CreatePostUploading;

    return AppBar(
      title: Text(
        l10n.createPost,
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
          child: isLoading
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
                    gradient: const LinearGradient(
                      colors: [AppColors.brandPrimary, AppColors.accentRose],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _submitPost,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.submit,
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
        ),
      ],
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

  Widget _buildFloatingDecorations(bool isDark, Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -40 + _floatingAnimation.value,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentLavender.withValues(alpha: 0.2),
                      AppColors.accentLavender.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - _floatingAnimation.value * 0.8,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
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
          ],
        );
      },
    );
  }

  Widget _buildContent(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
    CreatePostState state,
  ) {
    final isLoading = state is CreatePostUploading;

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGlassmorphicField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                labelText: l10n.postTitle,
                hintText: l10n.postTitleHint,
                maxLength: 300,
                maxLines: 2,
                isDark: isDark,
                theme: theme,
                enabled: !isLoading,
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
                maxLines: 10,
                isDark: isDark,
                theme: theme,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (_selectedImage != null) ...[
                _buildImagePreview(isDark, isLoading),
                const SizedBox(height: 20),
              ],

              if (_selectedImage == null)
                _buildAddImageButton(l10n, isDark, isLoading),
            ],
          ),
        ),

        if (isLoading) _buildLoadingOverlay(theme, l10n, isDark, state),
      ],
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

  Widget _buildImagePreview(bool isDark, bool isLoading) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandPrimary, AppColors.accentRose],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: isLoading ? null : _removeImage,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(
    AppLocalizations l10n,
    bool isDark,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading ? null : _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.brandPrimary.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.accentLavender.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.2),
                    AppColors.accentRose.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addImage,
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select an image',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
    CreatePostState state,
  ) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(AppColors.brandPrimary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state is CreatePostUploadingImage
                      ? l10n.uploadingImage
                      : l10n.creatingPost,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state is CreatePostUploadingImage) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: state.progress / 100,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.progress.toInt()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';
import '../widgets/quick_action_card.dart';

class CreateSurveyScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String projectDescription;

  const CreateSurveyScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
  });

  @override
  State<CreateSurveyScreen> createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen>
    with TickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  String? _selectedTemplate;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _descriptionFocusNode.addListener(() => setState(() {}));
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateSurvey() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.pleaseEnterDescription),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final prompt = description.isNotEmpty
        ? description
        : _getDefaultPromptForTemplate(_selectedTemplate!);

    context.read<SurveyBloc>().add(
      GenerateSurveyWithAI(
        projectId: widget.projectId,
        projectName: widget.projectName,
        projectDescription: widget.projectDescription,
        userPrompt: prompt,
        creatorId: userId,
        templateType: _selectedTemplate,
      ),
    );
  }

  String _getDefaultPromptForTemplate(String template) {
    switch (template) {
      case 'fyp':
        return 'Generate a final year project validation survey to understand if users have experienced the problem this project solves and gather feedback on proposed features.';
      case 'feature':
        return 'Generate a feature feedback survey to understand how users interact with current features and what improvements they would like to see.';
      case 'user_testing':
        return 'Generate a user testing survey to gather feedback on usability, user experience, and overall satisfaction with the product.';
      default:
        return 'Generate a general survey for this project.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SurveyBloc, SurveyState>(
      listener: (context, state) {
        if (state is SurveyCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.surveyCreated),
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
        } else if (state is SurveyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SurveyGenerating || state is SurveyCreating;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              l10n.createSurvey,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark, size),
              _buildFloatingDecorations(isDark, size),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(theme, l10n, isDark),
                      const SizedBox(height: 24),

                      _buildProgressIndicator(theme, l10n),
                      const SizedBox(height: 24),

                      _buildSectionHeader(
                        theme,
                        icon: Icons.flash_on_rounded,
                        title: l10n.quickActions,
                        subtitle: l10n.chooseTemplateOrCustom,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActions(l10n),
                      const SizedBox(height: 24),

                      _buildSectionHeader(
                        theme,
                        icon: Icons.edit_note_rounded,
                        title: l10n.surveyDescription,
                        subtitle: l10n.describeWhatYouWant,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(height: 12),
                      _buildDescriptionInput(isDark, theme, l10n),
                      const SizedBox(height: 8),
                      _buildCharacterCount(theme),
                      const SizedBox(height: 24),

                      _buildTipsCard(theme, l10n, isDark),
                      const SizedBox(height: 24),

                      _buildGenerateButton(l10n, isLoading),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (isLoading) _buildLoadingOverlay(theme, l10n, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandPrimary.withValues(alpha: isDark ? 0.3 : 0.15),
            AppColors.accentRose.withValues(alpha: isDark ? 0.2 : 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandPrimary, AppColors.accentRose],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiPoweredSurvey,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aiSurveyDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, AppLocalizations l10n) {
    final step1Complete = _selectedTemplate != null;
    final step2Complete = _descriptionController.text.trim().isNotEmpty;
    final bothReady = step1Complete || step2Complete;

    return Row(
      children: [
        _buildProgressStep(
          theme,
          number: '1',
          label: l10n.selectTemplate,
          isComplete: step1Complete,
          isActive: true,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: step1Complete
                  ? const LinearGradient(
                      colors: [AppColors.brandPrimary, AppColors.accentRose],
                    )
                  : null,
              color: step1Complete ? null : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _buildProgressStep(
          theme,
          number: '2',
          label: l10n.addDetails,
          isComplete: step2Complete,
          isActive: step1Complete,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: bothReady
                  ? const LinearGradient(
                      colors: [AppColors.brandPrimary, AppColors.accentRose],
                    )
                  : null,
              color: bothReady ? null : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _buildProgressStep(
          theme,
          number: '3',
          label: l10n.generate,
          isComplete: false,
          isActive: bothReady,
        ),
      ],
    );
  }

  Widget _buildProgressStep(
    ThemeData theme, {
    required String number,
    required String label,
    required bool isComplete,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isComplete
                ? const LinearGradient(
                    colors: [AppColors.brandPrimary, AppColors.accentRose],
                  )
                : null,
            color: isComplete
                ? null
                : (isActive
                      ? AppColors.brandPrimary.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2)),
            border: isActive && !isComplete
                ? Border.all(color: AppColors.brandPrimary, width: 2)
                : null,
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    number,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isActive ? AppColors.brandPrimary : Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive ? theme.colorScheme.onSurface : Colors.grey,
            fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
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

  Widget _buildQuickActions(AppLocalizations l10n) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.24,
      children: [
        QuickActionCard(
          title: l10n.fypSurvey,
          description: l10n.fypSurveyDescription,
          icon: Icons.school_outlined,
          color: AppColors.brandPrimary,
          isSelected: _selectedTemplate == 'fyp',
          onTap: () => setState(() => _selectedTemplate = 'fyp'),
        ),
        QuickActionCard(
          title: l10n.featureSurvey,
          description: l10n.featureSurveyDescription,
          icon: Icons.star_outline,
          color: AppColors.accentGold,
          isSelected: _selectedTemplate == 'feature',
          onTap: () => setState(() => _selectedTemplate = 'feature'),
        ),
        QuickActionCard(
          title: l10n.userTestingSurvey,
          description: l10n.userTestingSurveyDescription,
          icon: Icons.group_outlined,
          color: AppColors.accentRose,
          isSelected: _selectedTemplate == 'user_testing',
          onTap: () => setState(() => _selectedTemplate = 'user_testing'),
        ),
        QuickActionCard(
          title: l10n.customSurvey,
          description: l10n.customSurveyDescription,
          icon: Icons.edit_outlined,
          color: AppColors.accentLavender,
          isSelected:
              _selectedTemplate == null &&
              _descriptionController.text.isNotEmpty,
          onTap: () {
            setState(() => _selectedTemplate = null);
            _descriptionFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(
    bool isDark,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isFocused = _descriptionFocusNode.hasFocus;

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
                  : Colors.white.withValues(alpha: 0.9),
              border: Border.all(
                color: isFocused
                    ? AppColors.brandPrimary
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05)),
                width: isFocused ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.surveyDescriptionHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCount(ThemeData theme) {
    final count = _descriptionController.text.length;
    final isNearLimit = count > 400;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$count / 500',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isNearLimit
              ? AppColors.accentGold
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? AppColors.accentMint.withValues(alpha: 0.1)
            : AppColors.accentMint.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.successDark.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.successDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proTip,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.successDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.surveyTipContent,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(AppLocalizations l10n, bool isLoading) {
    final hasInput =
        _descriptionController.text.trim().isNotEmpty ||
        _selectedTemplate != null;

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasInput
                ? [AppColors.brandPrimary, AppColors.accentRose]
                : [Colors.grey, Colors.grey],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasInput
              ? [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (hasInput && !isLoading) ? _generateSurvey : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.generateSurvey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(
    ThemeData theme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _floatingController.value * 3.14159 * 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.brandPrimary,
                              AppColors.accentRose,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandPrimary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.generatingSurvey,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.aiThinking,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final offset = index * 0.33;
                        final animValue =
                            ((_pulseController.value + offset) % 1.0);
                        final scale =
                            0.5 +
                            (animValue < 0.5 ? animValue : 1.0 - animValue);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10 * scale,
                          height: 10 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.brandPrimary.withValues(
                              alpha: 0.4 + (scale * 0.6),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

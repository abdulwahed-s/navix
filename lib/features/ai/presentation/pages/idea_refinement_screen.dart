import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/refined_idea_entity.dart';
import '../bloc/project_idea_bloc.dart';
import '../widgets/idea_refinement/animated_background.dart';
import '../widgets/idea_refinement/floating_decorations.dart';
import '../widgets/idea_refinement/input_view.dart';
import '../widgets/idea_refinement/loading_view.dart';
import '../widgets/idea_refinement/refined_view.dart';

class IdeaRefinementScreen extends StatefulWidget {
  final List<String> userSkills;
  final int teamSize;

  const IdeaRefinementScreen({
    super.key,
    required this.userSkills,
    this.teamSize = 1,
  });

  @override
  State<IdeaRefinementScreen> createState() => _IdeaRefinementScreenState();
}

class _IdeaRefinementScreenState extends State<IdeaRefinementScreen>
    with TickerProviderStateMixin {
  final _ideaController = TextEditingController();
  final _additionalContextController = TextEditingController();
  bool _showAdditionalContext = false;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _ideaController.dispose();
    _additionalContextController.dispose();
    super.dispose();
  }

  void _submitForRefinement() {
    if (_ideaController.text.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.minCharacters),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<ProjectIdeaBloc>().add(
      RefineIdeaRequested(
        ideaDescription: _ideaController.text.trim(),
        userSkills: widget.userSkills,
        additionalContext: _additionalContextController.text.trim().isEmpty
            ? null
            : _additionalContextController.text.trim(),
      ),
    );
  }

  void _refineAgain() {
    setState(() {
      _showAdditionalContext = true;
    });
    context.read<ProjectIdeaBloc>().add(const ResetIdeas());
  }

  void _acceptRefinement(RefinedIdeaEntity refinedIdea) {
    context.read<ProjectIdeaBloc>().add(AcceptRefinedIdea(refinedIdea));

    context.push(
      AppRoutes.projectCreate,
      extra: {
        'refinedIdea': refinedIdea,
        'skills': widget.userSkills,
        'teamSize': widget.teamSize,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.refineIdea,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),
          FloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            screenSize: size,
          ),
          SafeArea(
            child: BlocConsumer<ProjectIdeaBloc, ProjectIdeaState>(
              listener: (context, state) {
                if (state is IdeaError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is IdeaRefining) {
                  return LoadingView(
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                    refiningText: l10n.refiningIdea,
                    thinkingText: l10n.aiThinking,
                  );
                }

                if (state is IdeaRefined) {
                  return RefinedView(
                    refinedIdea: state.refinedIdea,
                    isDark: isDark,
                    refinedIdeaLabel: l10n.refinedIdea,
                    improvedDescriptionLabel: l10n.improvedDescription,
                    scopeClarificationLabel: l10n.scopeClarification,
                    suggestedFeaturesLabel: l10n.suggestedFeatures,
                    feasibilityAssessmentLabel: l10n.feasibilityAssessment,
                    feasibilityScoreLabel: l10n.feasibilityScore(
                      state.refinedIdea.feasibilityScore,
                    ),
                    requiredSkillsLabel: l10n.requiredSkills,
                    yourSkillsLabel: l10n.yourSkills,
                    missingSkillsLabel: l10n.missingSkills,
                    refineAgainLabel: l10n.refineAgain,
                    acceptRefinementLabel: l10n.acceptRefinement,
                    onRefineAgain: _refineAgain,
                    onAcceptRefinement: () =>
                        _acceptRefinement(state.refinedIdea),
                  );
                }

                return InputView(
                  ideaController: _ideaController,
                  additionalContextController: _additionalContextController,
                  showAdditionalContext: _showAdditionalContext,
                  isDark: isDark,
                  characterCount: _ideaController.text.length,
                  describeYourIdeaLabel: l10n.describeYourIdea,
                  minCharactersLabel: l10n.minCharacters,
                  characterCountLabel: l10n.characterCount(
                    _ideaController.text.length,
                  ),
                  provideMoreDetailsLabel: l10n.provideMoreDetails,
                  refineIdeaLabel: l10n.refineIdea,
                  onSubmit: _submitForRefinement,
                  onTextChanged: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

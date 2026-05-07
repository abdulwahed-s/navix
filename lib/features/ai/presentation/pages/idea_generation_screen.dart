import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project_idea_entity.dart';
import '../bloc/project_idea_bloc.dart';
import '../widgets/idea_generation/animated_background.dart';
import '../widgets/idea_generation/domains_page.dart';
import '../widgets/idea_generation/floating_decorations.dart';
import '../widgets/idea_generation/glass_text_field.dart';
import '../widgets/idea_generation/idea_card.dart';
import '../widgets/idea_generation/ideas_header.dart';
import '../widgets/idea_generation/loading_view.dart';
import '../widgets/idea_generation/navigation_buttons.dart';
import '../widgets/idea_generation/progress_section.dart';
import '../widgets/idea_generation/question_page.dart';

class IdeaGenerationScreen extends StatefulWidget {
  final List<String> userSkills;
  final int teamSize;

  const IdeaGenerationScreen({
    super.key,
    required this.userSkills,
    this.teamSize = 1,
  });

  @override
  State<IdeaGenerationScreen> createState() => _IdeaGenerationScreenState();
}

class _IdeaGenerationScreenState extends State<IdeaGenerationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  final _teamSkillsController = TextEditingController();
  final _interestsController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _timeCommitmentController = TextEditingController();
  final _learningGoalsController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  final List<String> _selectedDomains = [];

  final List<String> _domainOptions = [
    'Web Development',
    'Mobile Development',
    'Machine Learning/AI',
    'Data Science',
    'Game Development',
    'IoT',
    'Blockchain',
    'Cybersecurity',
    'Cloud Computing',
    'AR/VR',
  ];

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
    _pageController.dispose();
    _teamSkillsController.dispose();
    _interestsController.dispose();
    _technologiesController.dispose();
    _timeCommitmentController.dispose();
    _learningGoalsController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _generateIdeas();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipStep() {
    _nextPage();
  }

  void _generateIdeas() {
    final goals = _buildGoalsFromAnswers();
    final preferences = _buildPreferencesFromAnswers();

    context.read<ProjectIdeaBloc>().add(
      GenerateIdeasRequested(
        userSkills: widget.userSkills,
        goals: goals,
        preferences: preferences.isEmpty ? null : preferences,
        isTeamProject: widget.teamSize > 1,
      ),
    );
  }

  String _buildGoalsFromAnswers() {
    final parts = <String>[];

    if (_interestsController.text.trim().isNotEmpty) {
      parts.add('Interests: ${_interestsController.text.trim()}');
    }

    if (_learningGoalsController.text.trim().isNotEmpty) {
      parts.add('Learning goals: ${_learningGoalsController.text.trim()}');
    }

    if (_selectedDomains.isNotEmpty) {
      parts.add('Preferred domains: ${_selectedDomains.join(', ')}');
    }

    return parts.isEmpty
        ? 'Generate innovative project ideas for my team'
        : parts.join('. ');
  }

  String _buildPreferencesFromAnswers() {
    final parts = <String>[];

    if (_teamSkillsController.text.trim().isNotEmpty) {
      parts.add('Team skills: ${_teamSkillsController.text.trim()}');
    }

    if (_technologiesController.text.trim().isNotEmpty) {
      parts.add(
        'Preferred technologies: ${_technologiesController.text.trim()}',
      );
    }

    if (_timeCommitmentController.text.trim().isNotEmpty) {
      parts.add('Time commitment: ${_timeCommitmentController.text.trim()}');
    }

    if (_additionalInfoController.text.trim().isNotEmpty) {
      parts.add(_additionalInfoController.text.trim());
    }

    return parts.join('. ');
  }

  void _selectIdea(ProjectIdeaEntity idea) {
    context.read<ProjectIdeaBloc>().add(
      GeneratePrdRequested(
        selectedIdea: idea,
        userSkills: widget.userSkills,
        isTeamProject: widget.teamSize > 1,
      ),
    );
  }

  void _toggleDomain(String domain) {
    setState(() {
      if (_selectedDomains.contains(domain)) {
        _selectedDomains.remove(domain);
      } else {
        _selectedDomains.add(domain);
      }
    });
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
          l10n.brainstormingQuestions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          IdeaAnimatedBackground(
            isDark: isDark,
            floatingAnimation: _floatingAnimation,
          ),
          IdeaFloatingDecorations(
            isDark: isDark,
            size: size,
            floatingAnimation: _floatingAnimation,
          ),
          SafeArea(
            child: BlocConsumer<ProjectIdeaBloc, ProjectIdeaState>(
              listener: (context, state) {
                if (state is PrdGenerated) {
                  context.push(
                    AppRoutes.projectCreate,
                    extra: {
                      'idea': state.selectedIdea,
                      'prd': state.prd,
                      'skills': widget.userSkills,
                      'teamSize': widget.teamSize,
                    },
                  );
                } else if (state is IdeaError) {
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
                if (state is IdeaLoading) {
                  return IdeaLoadingView(
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                  );
                }

                if (state is GeneratingPrd) {
                  return IdeaLoadingView(
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                    message: 'Generating PRD...',
                  );
                }

                if (state is IdeasGenerated) {
                  return _buildIdeasView(state.ideas, isDark);
                }

                return _buildQuestionFlow(l10n, theme, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFlow(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        IdeaProgressSection(
          currentPage: _currentPage,
          totalPages: 6,
          isDark: isDark,
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              IdeaQuestionPage(
                title: l10n.tellUsAboutYourTeam,
                subtitle: l10n.teamMemberSkillsDesc,
                icon: Icons.group_rounded,
                iconColor: AppColors.accentGold,
                isDark: isDark,
                child: IdeaGlassTextField(
                  controller: _teamSkillsController,
                  label: 'Team Skills',
                  hint: l10n.teamMemberSkillsHint,
                  isDark: isDark,
                  maxLines: 5,
                ),
              ),
              IdeaQuestionPage(
                title: l10n.yourInterests,
                subtitle: l10n.yourInterestsDesc,
                icon: Icons.favorite_rounded,
                iconColor: AppColors.accentRose,
                isDark: isDark,
                child: IdeaGlassTextField(
                  controller: _interestsController,
                  label: l10n.yourInterests,
                  hint: l10n.yourInterestsHint,
                  isDark: isDark,
                  maxLines: 5,
                ),
              ),
              IdeaQuestionPage(
                title: l10n.preferredTechnologies,
                subtitle: l10n.preferredTechnologiesDesc,
                icon: Icons.code_rounded,
                iconColor: AppColors.accentMint,
                isDark: isDark,
                child: IdeaGlassTextField(
                  controller: _technologiesController,
                  label: l10n.preferredTechnologies,
                  hint: l10n.preferredTechnologiesHint,
                  isDark: isDark,
                  maxLines: 4,
                ),
              ),
              IdeaDomainsPage(
                domainOptions: _domainOptions,
                selectedDomains: _selectedDomains,
                onDomainToggle: _toggleDomain,
                isDark: isDark,
              ),
              IdeaQuestionPage(
                title: l10n.timeCommitment,
                subtitle: l10n.timeCommitmentDesc,
                icon: Icons.schedule_rounded,
                iconColor: AppColors.accentLavender,
                isDark: isDark,
                child: IdeaGlassTextField(
                  controller: _timeCommitmentController,
                  label: l10n.timeCommitment,
                  hint: l10n.timeCommitmentHint,
                  isDark: isDark,
                  maxLines: 3,
                ),
              ),
              _buildLearningGoalsPage(l10n, isDark),
            ],
          ),
        ),
        IdeaNavigationButtons(
          currentPage: _currentPage,
          onPrevious: _previousPage,
          onSkip: _skipStep,
          onNext: _nextPage,
          isLastPage: _currentPage == 5,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLearningGoalsPage(AppLocalizations l10n, bool isDark) {
    return IdeaQuestionPage(
      title: l10n.learningGoals,
      subtitle: l10n.learningGoalsDesc,
      icon: Icons.school_rounded,
      iconColor: AppColors.accentMint,
      isDark: isDark,
      child: Column(
        children: [
          IdeaGlassTextField(
            controller: _learningGoalsController,
            label: l10n.learningGoals,
            hint: l10n.learningGoalsHint,
            isDark: isDark,
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          IdeaGlassTextField(
            controller: _additionalInfoController,
            label: l10n.additionalInfo,
            hint: l10n.additionalInfoHint,
            isDark: isDark,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasView(List<ProjectIdeaEntity> ideas, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ideas.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const IdeasHeader();
        }

        final idea = ideas[index - 1];
        return IdeaCard(
          idea: idea,
          onTap: () => _selectIdea(idea),
          isDark: isDark,
        );
      },
    );
  }
}

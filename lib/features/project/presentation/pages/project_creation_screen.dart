import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../../../ai/domain/entities/project_idea_entity.dart';
import '../../../ai/domain/entities/refined_idea_entity.dart';
import '../../../project_supervisor/presentation/pages/prd_editor_screen.dart';
import '../bloc/project_creation_bloc.dart';
import '../widgets/project_creation/animated_background.dart';
import '../widgets/project_creation/floating_decorations.dart';
import '../widgets/project_creation/gradient_button.dart';
import '../widgets/project_creation/loading_view.dart';
import '../widgets/project_creation/prd_display_card.dart';
import '../widgets/project_creation/roadmap_review_section.dart';

class ProjectCreationScreen extends StatefulWidget {
  final ProjectIdeaEntity? selectedIdea;
  final RefinedIdeaEntity? refinedIdea;
  final PrdEntity? prd;
  final List<String> userSkills;
  final int teamSize;

  const ProjectCreationScreen({
    super.key,
    this.selectedIdea,
    this.refinedIdea,
    this.prd,
    required this.userSkills,
    this.teamSize = 1,
  });

  @override
  State<ProjectCreationScreen> createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen>
    with TickerProviderStateMixin {
  DateTimeRange? _dateRange;
  PrdEntity? _currentPrd;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _currentPrd = widget.prd;

    if (widget.prd != null) {
      final now = DateTime.now();
      _dateRange = DateTimeRange(
        start: now,
        end: now.add(Duration(days: widget.prd!.estimatedDurationWeeks * 7)),
      );
    } else if (widget.refinedIdea != null) {
      final now = DateTime.now();
      _dateRange = DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 90)),
      );
    } else if (widget.selectedIdea != null) {
      final now = DateTime.now();
      _dateRange = DateTimeRange(
        start: now,
        end: now.add(
          Duration(days: widget.selectedIdea!.estimatedDurationWeeks * 7),
        ),
      );
    }
  }

  void _initAnimations() {
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
    super.dispose();
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  void _editWithNavi() async {
    final prd = _currentPrd ?? widget.prd;
    if (prd == null || _dateRange == null) return;

    final result = await Navigator.of(context).push<PrdEntity>(
      MaterialPageRoute(
        builder: (context) => PrdEditorScreen(
          prd: prd,
          userSkills: widget.userSkills,
          teamSize: widget.teamSize,
          startDate: _dateRange!.start,
          endDate: _dateRange!.end,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentPrd = result;
      });
    }
  }

  void _generateRoadmap() {
    if (_dateRange == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectDates)));
      return;
    }

    final prd = _currentPrd ?? widget.prd;
    if (prd == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PRD is required')));
      return;
    }

    final teamSize = widget.teamSize;

    context.read<ProjectCreationBloc>().add(
      GenerateRoadmapRequested(
        projectName: prd.title,
        projectDescription: prd.description,
        skills: widget.userSkills,
        teamSize: teamSize,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        isTeamProject: teamSize > 1,
      ),
    );
  }

  void _createProject() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ProjectCreationBloc>().add(
      ConfirmAndCreateProject(leaderId: userId, prd: _currentPrd ?? widget.prd),
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
          l10n.createProject,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          ProjectCreationAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
          ),
          ProjectCreationFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),
          SafeArea(
            child: BlocConsumer<ProjectCreationBloc, ProjectCreationState>(
              listener: (context, state) {
                if (state is ProjectCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.projectCreated),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go(AppRoutes.home);
                } else if (state is ProjectCreationError) {
                  print(state.message);
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
                if (state is GeneratingRoadmap) {
                  return ProjectCreationLoadingView(
                    message: l10n.generatingRoadmap,
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                  );
                }

                if (state is SavingProject) {
                  return ProjectCreationLoadingView(
                    message: l10n.creatingProject,
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                  );
                }

                if (state is RoadmapGenerated) {
                  return ProjectCreationRoadmapReview(
                    state: state,
                    onCreateProject: _createProject,
                    isDark: isDark,
                  );
                }

                return _buildPrdView(l10n, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrdView(AppLocalizations l10n, bool isDark) {
    final prd = _currentPrd ?? widget.prd;

    if (prd == null) {
      return Center(
        child: Text(
          'No PRD available. Please go back and select an idea.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrdDisplayCard(
            prd: prd,
            isDark: isDark,
            dateRange: _dateRange,
            onSelectDateRange: _selectDateRange,
            teamSize: widget.teamSize,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _editWithNavi,
                  icon: const Icon(Icons.edit_document),
                  label: const Text('Edit with Navi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProjectCreationGradientButton(
                  label: l10n.generateRoadmap,
                  icon: Icons.auto_awesome,
                  onPressed: _generateRoadmap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

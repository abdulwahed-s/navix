import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/survey_entity.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';
import '../widgets/response_chart.dart';

class SurveyDetailScreen extends StatefulWidget {
  final String projectId;
  final String surveyId;
  final bool isLeader;

  const SurveyDetailScreen({
    super.key,
    required this.projectId,
    required this.surveyId,
    this.isLeader = false,
  });

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSurvey();
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

  void _loadSurvey() {
    context.read<SurveyBloc>().add(
      LoadSurveyDetail(projectId: widget.projectId, surveyId: widget.surveyId),
    );
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

    return BlocBuilder<SurveyBloc, SurveyState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, state, l10n),
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark, size),
              _buildFloatingDecorations(isDark, size),
              _buildContent(context, state, l10n, isDark),
            ],
          ),
          floatingActionButton: state is SurveyDetailLoaded
              ? _buildShareButton(context, state.survey, l10n)
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SurveyState state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final title = state is SurveyDetailLoaded
        ? state.survey.title
        : l10n.survey;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (state is SurveyDetailLoaded && widget.isLeader)
          IconButton(
            onPressed: () => _editSurvey(context, state.survey),
            icon: const Icon(Icons.edit_outlined),
          ),
        if (state is SurveyDetailLoaded)
          IconButton(
            onPressed: () => _takeSurvey(context, state.survey),
            icon: const Icon(Icons.assignment_outlined),
            tooltip: l10n.takeSurvey,
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
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    SurveyState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (state is SurveyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SurveyError) {
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
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSurvey,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is SurveyDetailLoaded) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSurveyHeader(context, state.survey, l10n, isDark),
              const SizedBox(height: 24),
              _buildResponsesSection(context, state, l10n),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSurveyHeader(
    BuildContext context,
    SurveyEntity survey,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      survey.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    Icons.quiz_outlined,
                    '${survey.questions.length} ${l10n.questions}',
                    AppColors.brandPrimary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.people_outlined,
                    '${survey.responseCount} ${l10n.responses}',
                    AppColors.accentGold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesSection(
    BuildContext context,
    SurveyDetailLoaded state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.responseVisualization,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (state.responses.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.bar_chart_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noResponsesYet,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else
          ...state.survey.questions.map(
            (question) =>
                ResponseChart(question: question, responses: state.responses),
          ),
      ],
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    SurveyEntity survey,
    AppLocalizations l10n,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showShareOptions(context, survey, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.share_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.share,
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
    );
  }

  void _showShareOptions(
    BuildContext context,
    SurveyEntity survey,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.shareSurvey,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.forum_outlined,
                  color: AppColors.brandPrimary,
                ),
              ),
              title: Text(l10n.shareInCommunity),
              subtitle: Text(l10n.shareInCommunityDesc),
              onTap: () {
                Navigator.pop(context);
                _shareInCommunity(context, survey);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.chat_outlined, color: AppColors.accentGold),
              ),
              title: Text(l10n.shareInChat),
              subtitle: Text(l10n.shareInChatDesc),
              onTap: () {
                Navigator.pop(context);
                _shareInChat(context, survey);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _shareInCommunity(BuildContext context, SurveyEntity survey) {
    context.push(
      '/community/create',
      extra: {
        'surveyId': survey.id,
        'surveyTitle': survey.title,
        'surveyProjectId': survey.projectId,
        'surveyDescription': survey.description,
        'questionCount': survey.questions.length,
      },
    );
  }

  void _shareInChat(BuildContext context, SurveyEntity survey) {
    context.push(
      '/chat/select',
      extra: {
        'surveyId': survey.id,
        'surveyTitle': survey.title,
        'surveyProjectId': survey.projectId,
        'surveyDescription': survey.description,
        'questionCount': survey.questions.length,
      },
    );
  }

  void _editSurvey(BuildContext context, SurveyEntity survey) {
    context.push('/project/${widget.projectId}/survey/${survey.id}/edit');
  }

  void _takeSurvey(BuildContext context, SurveyEntity survey) {
    context.push('/project/${widget.projectId}/survey/${survey.id}/take');
  }
}

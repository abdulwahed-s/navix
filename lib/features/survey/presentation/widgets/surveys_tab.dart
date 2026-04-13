import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/survey_entity.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';
import '../widgets/survey_card.dart';

class SurveysTab extends StatelessWidget {
  final String projectId;
  final bool isLeader;
  final VoidCallback? onCreateSurvey;
  final Function(SurveyEntity)? onViewSurvey;
  final Function(SurveyEntity)? onEditSurvey;

  const SurveysTab({
    super.key,
    required this.projectId,
    this.isLeader = false,
    this.onCreateSurvey,
    this.onViewSurvey,
    this.onEditSurvey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SurveyBloc, SurveyState>(
      builder: (context, state) {
        if (state is SurveyLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SurveyError) {
          return _buildErrorState(context, state.message, l10n);
        }

        if (state is SurveysLoaded) {
          if (state.surveys.isEmpty) {
            return _buildEmptyState(context, l10n, isDark);
          }

          return _buildSurveysList(context, state.surveys, l10n);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.brandPrimary.withValues(alpha: 0.2),
                  AppColors.accentLavender.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.poll_outlined,
              size: 64,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noSurveys,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstSurvey,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (isLeader) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandPrimary, AppColors.accentRose],
                ),
                borderRadius: BorderRadius.circular(12),
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
                  onTap: onCreateSurvey,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          l10n.createSurvey,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurveysList(
    BuildContext context,
    List<SurveyEntity> surveys,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surveys.length,
          itemBuilder: (context, index) {
            final survey = surveys[index];
            return SurveyCard(
              survey: survey,
              isLeader: isLeader,
              onTap: () => onViewSurvey?.call(survey),
              onEdit: () => onEditSurvey?.call(survey),
              onDelete: () => _confirmDelete(context, survey, l10n),
            );
          },
        ),
        if (isLeader)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
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
                  onTap: onCreateSurvey,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SurveyBloc>().add(LoadSurveys(projectId: projectId));
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SurveyEntity survey,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteSurvey),
        content: Text(l10n.confirmDeleteSurvey),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SurveyBloc>().add(
                DeleteSurvey(projectId: projectId, surveyId: survey.id),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

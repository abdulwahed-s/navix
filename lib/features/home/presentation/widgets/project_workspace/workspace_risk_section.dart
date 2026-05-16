import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../prediction/presentation/bloc/prediction_bloc.dart';
import '../../../../prediction/presentation/widgets/risk_dashboard.dart';
import '../../../../project/domain/entities/project_roadmap_entity.dart';

class WorkspaceRiskSection extends StatelessWidget {
  final String projectId;
  final String projectName;
  final ProjectRoadmapEntity roadmap;
  final DateTime startDate;
  final DateTime endDate;

  const WorkspaceRiskSection({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.roadmap,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.riskPrediction,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        BlocProvider(
          create: (_) => sl<PredictionBloc>()
            ..add(
              LoadCachedPrediction(
                projectId: projectId,
                projectName: projectName,
                roadmap: roadmap,
                startDate: startDate,
                endDate: endDate,
              ),
            ),
          child: const RiskDashboard(),
        ),
      ],
    );
  }
}

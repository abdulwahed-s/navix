import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/risk_prediction_entity.dart';
import '../bloc/prediction_bloc.dart';

class RiskDashboard extends StatelessWidget {
  final bool isDark;

  const RiskDashboard({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dark = isDark || theme.brightness == Brightness.dark;

    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        if (state is PredictionLoading) {
          return _buildLoadingState(l10n, theme, dark);
        }

        if (state is PredictionEmpty) {
          return _buildEmptyState(l10n, theme, context, dark);
        }

        if (state is PredictionError) {
          return _buildErrorState(state.message, l10n, theme, dark);
        }

        if (state is PredictionLoaded) {
          return _buildDashboard(state.prediction, l10n, theme, context, dark);
        }

        return _buildEmptyState(l10n, theme, context, dark);
      },
    );
  }

  Widget _buildLoadingState(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.analyzingProject,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
    bool isDark,
  ) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.riskAnalysis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _GradientButton(
              label: l10n.refreshAnalysis,
              icon: Icons.auto_awesome,
              onPressed: () {
                context.read<PredictionBloc>().add(const RefreshPrediction());
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return _GlassCard(
      isDark: isDark,
      borderColor: AppColors.riskHigh.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.riskHigh.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.riskHigh,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    RiskPredictionEntity prediction,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
    bool isDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RiskLevelCard(
            riskLevel: prediction.riskLevel,
            delayProbability: prediction.delayProbability,
            l10n: l10n,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          if (prediction.actionRequired) ...[
            _ActionRequiredCard(l10n: l10n, isDark: isDark),
            const SizedBox(height: 12),
          ],

          if (prediction.blockedTasks.isNotEmpty) ...[
            _SectionCard(
              title: l10n.blockedTasks,
              icon: Icons.block,
              iconColor: AppColors.riskHigh,
              items: prediction.blockedTasks,
              itemColor: AppColors.riskHigh,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],

          if (prediction.atRiskTasks.isNotEmpty) ...[
            _SectionCard(
              title: l10n.atRiskTasks,
              icon: Icons.warning_amber,
              iconColor: AppColors.riskMedium,
              items: prediction.atRiskTasks,
              itemColor: AppColors.riskMedium,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],

          if (prediction.recommendations.isNotEmpty) ...[
            _SectionCard(
              title: l10n.aiRecommendations,
              icon: Icons.lightbulb_outline,
              iconColor: AppColors.accentGold,
              items: prediction.recommendations,
              itemColor: AppColors.accentGold,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],

          _FooterCard(
            analyzedAt: prediction.analyzedAt,
            l10n: l10n,
            theme: theme,
            isDark: isDark,
            onRefresh: () {
              context.read<PredictionBloc>().add(const RefreshPrediction());
            },
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    required this.isDark,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final ThemeData theme;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, AppColors.accentGold],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskLevelCard extends StatelessWidget {
  final RiskLevel riskLevel;
  final int delayProbability;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isDark;

  const _RiskLevelCard({
    required this.riskLevel,
    required this.delayProbability,
    required this.l10n,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRiskColor(riskLevel);
    final label = _getRiskLabel(riskLevel, l10n);

    return _GlassCard(
      isDark: isDark,
      borderColor: color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shield_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.riskLevel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRiskEmoji(riskLevel),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.delayProbability,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.delayProbabilityPercent(delayProbability),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: delayProbability / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.medium:
        return AppColors.riskMedium;
      case RiskLevel.high:
        return AppColors.riskHigh;
    }
  }

  String _getRiskLabel(RiskLevel level, AppLocalizations l10n) {
    switch (level) {
      case RiskLevel.low:
        return l10n.riskLevelLow;
      case RiskLevel.medium:
        return l10n.riskLevelMedium;
      case RiskLevel.high:
        return l10n.riskLevelHigh;
    }
  }

  String _getRiskEmoji(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return '✅';
      case RiskLevel.medium:
        return '⚠️';
      case RiskLevel.high:
        return '🚨';
    }
  }
}

class _ActionRequiredCard extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const _ActionRequiredCard({required this.l10n, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.riskHigh.withValues(alpha: isDark ? 0.2 : 0.15),
              AppColors.riskCritical.withValues(alpha: isDark ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.riskHigh,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.actionRequired,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.riskHigh,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Immediate attention needed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.riskHigh.withValues(alpha: 0.8),
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;
  final Color itemColor;
  final bool isDark;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.itemColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassCard(
      isDark: isDark,
      borderColor: iconColor.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withValues(alpha: 0.2),
                        iconColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            ...items.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [itemColor, itemColor.withValues(alpha: 0.5)],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  final DateTime analyzedAt;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onRefresh;

  const _FooterCard({
    required this.analyzedAt,
    required this.l10n,
    required this.theme,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${l10n.lastAnalyzed}: ${timeago.format(analyzedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    AppColors.accentGold.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

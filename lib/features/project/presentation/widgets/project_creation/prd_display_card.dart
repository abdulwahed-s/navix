import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../ai/domain/entities/prd_entity.dart';

class PrdDisplayCard extends StatelessWidget {
  final PrdEntity prd;
  final bool isDark;
  final DateTimeRange? dateRange;
  final VoidCallback onSelectDateRange;
  final int teamSize;

  const PrdDisplayCard({
    super.key,
    required this.prd,
    required this.isDark,
    required this.dateRange,
    required this.onSelectDateRange,
    required this.teamSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCard(context, theme),
        const SizedBox(height: 16),

        Row(children: [Expanded(child: _buildQuickInfoCard(context, theme))]),
        const SizedBox(height: 16),

        _buildSectionCard(
          context,
          theme,
          title: 'Problem & Objective',
          icon: Icons.lightbulb_outline_rounded,
          color: AppColors.accentGold,
          children: [
            _buildTextBlock(
              context,
              'Problem Statement',
              prd.problemStatement,
              AppColors.accentRose,
            ),
            const SizedBox(height: 16),
            _buildTextBlock(
              context,
              'Project Objective',
              prd.projectObjective,
              AppColors.accentMint,
            ),
            const SizedBox(height: 16),
            _buildTextBlock(
              context,
              'Target Users',
              prd.targetUsers,
              AppColors.accentLavender,
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          context,
          theme,
          title: 'Scope of Work',
          icon: Icons.rule_rounded,
          color: Colors.green,
          children: [
            _buildTaggedList(
              context,
              'In Scope',
              prd.inScope,
              Colors.green,
              Icons.check_circle_rounded,
            ),
            if (prd.outOfScope.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTaggedList(
                context,
                'Out of Scope',
                prd.outOfScope,
                Colors.orange,
                Icons.remove_circle_rounded,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          context,
          theme,
          title: 'Core Features',
          icon: Icons.star_rounded,
          color: AppColors.accentGold,
          children: [_buildFeatureGrid(context, prd.coreFeatures)],
        ),
        const SizedBox(height: 16),

        _buildSectionCard(
          context,
          theme,
          title: 'Requirements',
          icon: Icons.checklist_rounded,
          color: AppColors.brandPrimary,
          children: [
            _buildNumberedList(
              context,
              'Functional Requirements',
              prd.functionalRequirements,
              AppColors.brandPrimary,
            ),
            if (prd.nonFunctionalRequirements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNumberedList(
                context,
                'Non-Functional Requirements',
                prd.nonFunctionalRequirements,
                AppColors.accentMint,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        if (prd.acceptanceCriteria.isNotEmpty)
          _buildSectionCard(
            context,
            theme,
            title: 'Acceptance Criteria',
            icon: Icons.verified_rounded,
            color: Colors.green,
            children: [_buildCheckList(context, prd.acceptanceCriteria)],
          ),
        const SizedBox(height: 16),

        _buildTimelineCard(context, theme),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.brandPrimary.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.08),
                    ]
                  : [
                      AppColors.brandPrimary.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.9),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandPrimary,
                          AppColors.brandPrimary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPrimary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Requirements',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prd.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                prd.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildQuickStat(
            context,
            Icons.group_rounded,
            '$teamSize',
            'Team',
            AppColors.brandPrimary,
          ),
          _buildVerticalDivider(),
          _buildQuickStat(
            context,
            Icons.schedule_rounded,
            _calculateDuration(),
            'Duration',
            AppColors.accentMint,
          ),
          _buildVerticalDivider(),
          _buildQuickStat(
            context,
            Icons.star_rounded,
            '${prd.coreFeatures.length}',
            'Features',
            AppColors.accentGold,
          ),
          _buildVerticalDivider(),
          _buildQuickStat(
            context,
            Icons.list_alt_rounded,
            '${prd.functionalRequirements.length}',
            'Requirements',
            AppColors.accentLavender,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextBlock(
    BuildContext context,
    String label,
    String content,
    Color color,
  ) {
    if (content.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaggedList(
    BuildContext context,
    String label,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              '$label (${items.length})',
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<String> features) {
    final theme = Theme.of(context);
    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        final colors = [
          AppColors.brandPrimary,
          AppColors.accentMint,
          AppColors.accentGold,
          AppColors.accentLavender,
          AppColors.accentRose,
        ];
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: color.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(
    BuildContext context,
    String label,
    List<String> items,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${items.length})',
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCheckList(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandPrimary.withValues(alpha: 0.2),
                      AppColors.brandPrimary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Timeline',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to edit dates',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelectDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.brandPrimary.withValues(alpha: 0.1)
                      : AppColors.brandPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: dateRange != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _calculateDuration(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.brandPrimary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Select project timeline',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _calculateDuration() {
    if (dateRange == null) {
      return '${prd.estimatedDurationWeeks} weeks';
    }

    final days = dateRange!.end.difference(dateRange!.start).inDays;
    final weeks = (days / 7).round();

    if (weeks == 1) {
      return '1 week';
    } else if (weeks < 1) {
      return '$days days';
    } else {
      return '$weeks weeks';
    }
  }
}

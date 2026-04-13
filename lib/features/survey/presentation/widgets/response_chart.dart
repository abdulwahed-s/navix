import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/survey_question_entity.dart';
import '../../domain/entities/survey_response_entity.dart';

class ResponseChart extends StatelessWidget {
  final SurveyQuestionEntity question;
  final List<SurveyResponseEntity> responses;

  const ResponseChart({
    super.key,
    required this.question,
    required this.responses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChart(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (question.type) {
      case SurveyQuestionType.radio:
      case SurveyQuestionType.checkbox:
        return _buildPieChart(context);
      case SurveyQuestionType.rating:
        return _buildBarChart(context);
      case SurveyQuestionType.text:
        return _buildTextResponses(context);
    }
  }

  Widget _buildPieChart(BuildContext context) {
    final theme = Theme.of(context);
    final data = _calculateOptionCounts();

    if (data.isEmpty) {
      return Center(
        child: Text(
          'No responses yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final colors = [
      AppColors.brandPrimary,
      AppColors.accentRose,
      AppColors.accentLavender,
      AppColors.accentGold,
      AppColors.successDark,
      Colors.orange,
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final total = data.values.fold<int>(0, (a, b) => a + b);
                final percentage = (item.value / total * 100).toStringAsFixed(
                  1,
                );

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: item.value.toDouble(),
                  title: '${percentage}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.key} (${item.value})',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final data = _calculateRatingCounts();

    if (data.isEmpty) {
      return Center(
        child: Text(
          'No responses yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final maxValue = data.values.fold<int>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue.toDouble() + 1,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt() + 1}★',
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(5, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (data[index + 1] ?? 0).toDouble(),
                  color: AppColors.brandPrimary,
                  width: 30,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTextResponses(BuildContext context) {
    final theme = Theme.of(context);
    final textAnswers = responses
        .map((r) => r.answers[question.id])
        .where((a) => a != null && a.toString().isNotEmpty)
        .take(5)
        .toList();

    if (textAnswers.isEmpty) {
      return Center(
        child: Text(
          'No responses yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textAnswers.map((answer) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(answer.toString(), style: theme.textTheme.bodyMedium),
        );
      }).toList(),
    );
  }

  Map<String, int> _calculateOptionCounts() {
    final counts = <String, int>{};

    for (final response in responses) {
      final answer = response.answers[question.id];
      if (answer == null) continue;

      if (answer is List) {
        for (final item in answer) {
          final key = item.toString();
          counts[key] = (counts[key] ?? 0) + 1;
        }
      } else {
        final key = answer.toString();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return counts;
  }

  Map<int, int> _calculateRatingCounts() {
    final counts = <int, int>{};

    for (final response in responses) {
      final answer = response.answers[question.id];
      if (answer == null) continue;

      final rating = answer is int ? answer : int.tryParse(answer.toString());
      if (rating != null && rating >= 1 && rating <= 5) {
        counts[rating] = (counts[rating] ?? 0) + 1;
      }
    }

    return counts;
  }
}

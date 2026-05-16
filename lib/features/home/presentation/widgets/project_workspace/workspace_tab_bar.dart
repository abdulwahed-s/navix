import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class WorkspaceTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDark;
  final bool isLeader;

  const WorkspaceTabBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isLeader,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isLeader,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, AppColors.accentGold],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.all(4),
        tabs: [
          if (isLeader) Tab(text: l10n.adminDashboard),
          Tab(text: l10n.overview),
          Tab(text: l10n.tasks),
          Tab(text: l10n.surveys),
          Tab(text: l10n.projectChat),
          if (isLeader) Tab(text: l10n.settings),
        ],
      ),
    );
  }
}

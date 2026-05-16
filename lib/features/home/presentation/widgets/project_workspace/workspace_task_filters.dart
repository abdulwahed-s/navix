import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../bloc/workspace_bloc.dart';

class WorkspaceTaskFilters extends StatelessWidget {
  final TaskGrouping grouping;
  final String? selectedRoleFilter;
  final String? selectedTimeFilter;
  final TaskSortOrder sortOrder;
  final List<String> roles;
  final ValueChanged<TaskGrouping?> onGroupingChanged;
  final ValueChanged<String?> onRoleFilterChanged;
  final ValueChanged<String?> onTimeFilterChanged;
  final ValueChanged<TaskSortOrder> onSortOrderChanged;

  const WorkspaceTaskFilters({
    super.key,
    required this.grouping,
    required this.selectedRoleFilter,
    required this.selectedTimeFilter,
    required this.sortOrder,
    required this.roles,
    required this.onGroupingChanged,
    required this.onRoleFilterChanged,
    required this.onTimeFilterChanged,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n, theme),

          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          if (grouping == TaskGrouping.byRole)
            _buildRoleFilters(context, l10n, theme),
          if (grouping == TaskGrouping.byTime)
            _buildTimeFilters(context, l10n, theme),

          _buildSortSection(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Icon(
            Icons.view_list_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.groupBy,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGroupChip(
                    context: context,
                    label: l10n.groupByNone,
                    isSelected: grouping == TaskGrouping.none,
                    onTap: () => onGroupingChanged(TaskGrouping.none),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildGroupChip(
                    context: context,
                    label: l10n.groupByRole,
                    isSelected: grouping == TaskGrouping.byRole,
                    onTap: () => onGroupingChanged(TaskGrouping.byRole),
                    theme: theme,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(width: 8),
                  _buildGroupChip(
                    context: context,
                    label: l10n.groupByTime,
                    isSelected: grouping == TaskGrouping.byTime,
                    onTap: () => onGroupingChanged(TaskGrouping.byTime),
                    theme: theme,
                    icon: Icons.schedule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilters(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.filterByRole,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: l10n.allRoles,
                  isSelected: selectedRoleFilter == null,
                  onTap: () => onRoleFilterChanged(null),
                  theme: theme,
                  icon: Icons.groups_outlined,
                ),
                const SizedBox(width: 8),

                ...roles.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      context: context,
                      label: role,
                      isSelected: selectedRoleFilter == role,
                      onTap: () => onRoleFilterChanged(
                        selectedRoleFilter == role ? null : role,
                      ),
                      theme: theme,
                    ),
                  ),
                ),
                if (roles.isEmpty)
                  _buildFilterChip(
                    context: context,
                    label: l10n.noRoleAssigned,
                    isSelected: false,
                    onTap: () {},
                    theme: theme,
                    isDisabled: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final timeGroups = [
      (null, l10n.allPeriods, Icons.calendar_today),
      ('overdue', l10n.tasksOverdue, Icons.warning_amber_rounded),
      ('today', l10n.tasksDueToday, Icons.today),
      ('thisWeek', l10n.tasksDueThisWeek, Icons.date_range),
      ('later', l10n.tasksLater, Icons.event),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.filterBy,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeGroups.map((group) {
                final (key, label, icon) = group;
                final isSelected = selectedTimeFilter == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    context: context,
                    label: label,
                    isSelected: isSelected,
                    onTap: () => onTimeFilterChanged(isSelected ? null : key),
                    theme: theme,
                    icon: icon,
                    isWarning: key == 'overdue',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    IconData? icon,
    bool isDisabled = false,
    bool isWarning = false,
  }) {
    Color chipColor;
    Color textColor;
    Color borderColor;

    if (isDisabled) {
      chipColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      borderColor = Colors.transparent;
    } else if (isSelected) {
      if (isWarning) {
        chipColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        borderColor = Colors.red.withValues(alpha: 0.5);
      } else {
        chipColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.secondary;
        borderColor = theme.colorScheme.secondary.withValues(alpha: 0.5);
      }
    } else {
      chipColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurfaceVariant;
      borderColor = Colors.transparent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final sortOptions = [
      (TaskSortOrder.none, l10n.noSorting, Icons.sort),
      (
        TaskSortOrder.priorityHighToLow,
        l10n.priorityHighToLow,
        Icons.arrow_downward,
      ),
      (
        TaskSortOrder.priorityLowToHigh,
        l10n.priorityLowToHigh,
        Icons.arrow_upward,
      ),
      (TaskSortOrder.deadlineAsc, l10n.deadlineAscending, Icons.schedule),
      (TaskSortOrder.deadlineDesc, l10n.deadlineDescending, Icons.event_busy),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_vert,
                size: 18,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.sortBy,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sortOptions.map((option) {
                final (order, label, icon) = option;
                final isSelected = sortOrder == order;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSortChip(
                    context: context,
                    label: label,
                    isSelected: isSelected,
                    onTap: () => onSortOrderChanged(order),
                    theme: theme,
                    icon: icon,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.tertiaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.tertiary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

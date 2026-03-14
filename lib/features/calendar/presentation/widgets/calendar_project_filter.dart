import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

typedef CalendarProject = ({String id, String name});

class CalendarProjectFilter extends StatelessWidget {
  final List<CalendarProject> projects;

  final String? selectedProjectId;

  final ValueChanged<String?> onProjectSelected;

  final bool isDark;

  const CalendarProjectFilter({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onProjectSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.7),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedProjectId,
                isExpanded: true,
                hint: Text(l10n.filterByProject),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.primary,
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.allProjects),
                      ],
                    ),
                  ),
                  ...projects.map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            size: 18,
                            color: AppColors.accentLavender,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: onProjectSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

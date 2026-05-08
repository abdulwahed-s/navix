import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

void showFilterBottomSheet({
  required BuildContext context,
  required List<String> selectedSkills,
  required ValueChanged<List<String>> onApply,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _FilterSheetContent(
        selectedSkills: List.from(selectedSkills),
        isDark: isDark,
        onApply: (skills) {
          Navigator.pop(sheetContext);
          onApply(skills);
        },
      );
    },
  );
}

class _FilterSheetContent extends StatefulWidget {
  final List<String> selectedSkills;
  final bool isDark;
  final ValueChanged<List<String>> onApply;

  const _FilterSheetContent({
    required this.selectedSkills,
    required this.isDark,
    required this.onApply,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late List<String> _selectedSkills;

  static const _commonSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'React',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'iOS',
    'Android',
    'Web',
    'Backend',
    'Frontend',
    'UI/UX',
    'Machine Learning',
    'DevOps',
    'Cloud',
    'Database',
    'API Design',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSkills = List.from(widget.selectedSkills);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  _DragHandle(theme: theme),
                  _FilterHeader(
                    onClear: () => setState(() => _selectedSkills.clear()),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.selectSkills,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SkillChips(
                        skills: _commonSkills,
                        selectedSkills: _selectedSkills,
                        isDark: widget.isDark,
                        onSkillToggled: (skill, selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ApplyButton(
                    isDark: widget.isDark,
                    onApply: () => widget.onApply(_selectedSkills),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final ThemeData theme;

  const _DragHandle({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final VoidCallback onClear;

  const _FilterHeader({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.filters,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
        ],
      ),
    );
  }
}

class _SkillChips extends StatelessWidget {
  final List<String> skills;
  final List<String> selectedSkills;
  final bool isDark;
  final void Function(String skill, bool selected) onSkillToggled;

  const _SkillChips({
    required this.skills,
    required this.selectedSkills,
    required this.isDark,
    required this.onSkillToggled,
  });

  @override
  Widget build(BuildContext context) {
    final accentColors = [
      AppColors.accentLavender,
      AppColors.accentMint,
      AppColors.accentGold,
      AppColors.accentRose,
    ];
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        final isSelected = selectedSkills.contains(skill);
        final colorIndex = skills.indexOf(skill) % 4;

        return FilterChip(
          label: Text(skill),
          selected: isSelected,
          selectedColor: accentColors[colorIndex].withValues(alpha: 0.4),
          checkmarkColor: isDark ? Colors.white : AppColors.brandPrimaryDark,
          side: BorderSide(
            color: isSelected
                ? accentColors[colorIndex]
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          onSelected: (selected) => onSkillToggled(skill, selected),
        );
      }).toList(),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onApply;

  const _ApplyButton({required this.isDark, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkPrimary, AppColors.accentRose]
                : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onApply,
            child: Center(
              child: Text(
                l10n.applyFilters,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.darkOnPrimary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

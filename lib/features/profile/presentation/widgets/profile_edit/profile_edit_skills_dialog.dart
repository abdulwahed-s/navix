import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/skill_entity.dart';
import '../../../domain/entities/skill_status.dart';
import '../../bloc/skill_bloc.dart';

class ProfileEditSkillsDialog extends StatefulWidget {
  final List<SkillEntity> selectedSkills;

  final List<String> predefinedSkills;

  final String dialogTitle;

  final String customSkillHint;

  final String doneButtonLabel;

  final bool isDark;

  final void Function(List<SkillEntity>) onSkillsChanged;

  const ProfileEditSkillsDialog({
    super.key,
    required this.selectedSkills,
    required this.predefinedSkills,
    required this.dialogTitle,
    required this.customSkillHint,
    required this.doneButtonLabel,
    required this.isDark,
    required this.onSkillsChanged,
  });

  @override
  State<ProfileEditSkillsDialog> createState() =>
      _ProfileEditSkillsDialogState();
}

class _ProfileEditSkillsDialogState extends State<ProfileEditSkillsDialog> {
  late List<SkillEntity> _skills;
  final _customSkillController = TextEditingController();
  bool _isValidating = false;
  String? _validationError;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.selectedSkills);
  }

  @override
  void dispose() {
    _customSkillController.dispose();
    super.dispose();
  }

  bool _isPredefined(String skillName) {
    return widget.predefinedSkills
        .map((s) => s.toLowerCase())
        .contains(skillName.toLowerCase());
  }

  Set<String> get _selectedSkillNames =>
      _skills.map((s) => s.skillName.toLowerCase()).toSet();

  void _togglePredefinedSkill(String skillName) {
    setState(() {
      final existingIndex = _skills.indexWhere(
        (s) => s.skillName.toLowerCase() == skillName.toLowerCase(),
      );

      if (existingIndex >= 0) {
        _skills.removeAt(existingIndex);
      } else {
        _skills.add(SkillEntity.predefined(skillName));
      }
      _validationError = null;
    });
    widget.onSkillsChanged(_skills);
  }

  Future<void> _addCustomSkill() async {
    final skillName = _customSkillController.text.trim();

    if (skillName.isEmpty) return;

    if (_selectedSkillNames.contains(skillName.toLowerCase())) {
      setState(() {
        _validationError = l10n.skillAlreadyAdded;
      });
      return;
    }

    if (_isPredefined(skillName)) {
      setState(() {
        _skills.add(SkillEntity.predefined(skillName));
        _validationError = null;
      });
      widget.onSkillsChanged(_skills);
      _customSkillController.clear();
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    context.read<SkillBloc>().add(ValidateSkill(skillName: skillName));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SkillBloc, SkillState>(
      listener: (context, state) {
        if (state is SkillValidated) {
          setState(() {
            _isValidating = false;
            if (state.skill.status == SkillStatus.approved) {
              _skills.add(state.skill);
              widget.onSkillsChanged(_skills);
              _customSkillController.clear();
              _validationError = null;
            } else {
              _validationError =
                  'Invalid skill: "${state.skill.skillName}" is not recognized as a valid skill';
            }
          });
        } else if (state is SkillError) {
          setState(() {
            _isValidating = false;
            _validationError = state.message;
          });
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                              AppColors.accentRose.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.dialogTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _GlassmorphicField(
                    controller: _customSkillController,
                    hintText: widget.customSkillHint,
                    isDark: widget.isDark,
                    enabled: !_isValidating,
                    suffixIcon: _isValidating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.brandPrimary,
                                    AppColors.accentRose,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            onPressed: _addCustomSkill,
                          ),
                    onSubmitted: (_) => _addCustomSkill(),
                  ),

                  if (_validationError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _validationError!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_isValidating)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Validating custom skill...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (_skills.isNotEmpty) ...[
                    Text(
                      'Selected Skills',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        return _SelectedSkillChip(
                          skill: skill,
                          isDark: widget.isDark,
                          onRemove: () {
                            setState(() {
                              _skills.remove(skill);
                            });
                            widget.onSkillsChanged(_skills);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    'Popular Skills',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.25,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.predefinedSkills.map((skill) {
                          final isSelected = _selectedSkillNames.contains(
                            skill.toLowerCase(),
                          );
                          return GestureDetector(
                            onTap: () => _togglePredefinedSkill(skill),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.brandPrimary,
                                          AppColors.accentRose,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (widget.isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : AppColors.brandLightGray),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: widget.isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                      ),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (widget.isDark
                                            ? Colors.white70
                                            : AppColors.brandPrimaryDark),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandPrimary,
                            AppColors.accentRose,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isValidating
                              ? null
                              : () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                widget.doneButtonLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedSkillChip extends StatelessWidget {
  final SkillEntity skill;
  final bool isDark;
  final VoidCallback onRemove;

  const _SelectedSkillChip({
    required this.skill,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    IconData? statusIcon;

    if (skill.isVerified) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success.withValues(alpha: 0.5);
      statusIcon = Icons.verified;
    } else if (skill.isRejected) {
      bgColor = Colors.red.withValues(alpha: 0.15);
      borderColor = Colors.red.withValues(alpha: 0.5);
      statusIcon = Icons.error;
    } else if (skill.isPending) {
      bgColor = AppColors.accentGold.withValues(alpha: 0.15);
      borderColor = AppColors.accentGold.withValues(alpha: 0.5);
      statusIcon = Icons.hourglass_empty;
    } else {
      bgColor = AppColors.brandPrimary.withValues(alpha: 0.15);
      borderColor = AppColors.brandPrimary.withValues(alpha: 0.5);
      statusIcon = null;
    }

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            Icon(statusIcon, size: 14, color: borderColor),
            const SizedBox(width: 4),
          ],
          Text(
            skill.skillName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassmorphicField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isDark;
  final Widget? suffixIcon;
  final bool enabled;
  final void Function(String)? onSubmitted;

  const _GlassmorphicField({
    required this.controller,
    required this.hintText,
    required this.isDark,
    this.suffixIcon,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}

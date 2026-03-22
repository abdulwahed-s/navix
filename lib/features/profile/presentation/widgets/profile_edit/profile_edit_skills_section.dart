import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/skill_entity.dart';
import '../../../domain/entities/skill_status.dart';

class ProfileEditSkillsSection extends StatelessWidget {
  final List<SkillEntity> skills;

  final String sectionTitle;

  final String addButtonLabel;

  final String emptyMessage;

  final bool isDark;

  final bool isLoading;

  final VoidCallback onAddTap;

  final void Function(SkillEntity skill) onRemoveSkill;

  final VoidCallback? onVerifyTap;

  final String? verifyButtonLabel;

  const ProfileEditSkillsSection({
    super.key,
    required this.skills,
    required this.sectionTitle,
    required this.addButtonLabel,
    required this.emptyMessage,
    required this.isDark,
    required this.isLoading,
    required this.onAddTap,
    required this.onRemoveSkill,
    this.onVerifyTap,
    this.verifyButtonLabel,
  });

  static const _colors = [
    AppColors.accentLavender,
    AppColors.accentMint,
    AppColors.accentGold,
    AppColors.accentRose,
    AppColors.brandPrimary,
  ];

  bool get _hasUnverifiedSkills =>
      skills.any((s) => s.status == SkillStatus.approved && !s.isVerified);

  bool get _hasRejectedSkills => skills.any((s) => s.isRejected);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  sectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandPrimary, AppColors.accentRose],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onAddTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          addButtonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_hasRejectedSkills)
          _buildWarningBanner(
            context,
            icon: Icons.warning_amber_rounded,
            message:
                'Some skills were not recognized. Please edit or remove them.',
            color: Colors.orange,
          ),

        if (skills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.brandLightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.85),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.brandPrimary.withValues(alpha: 0.1),
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.asMap().entries.map((entry) {
                    final color = _colors[entry.key % _colors.length];
                    return _SkillChip(
                      skill: entry.value,
                      color: color,
                      isDark: isDark,
                      isLoading: isLoading,
                      onRemove: () => onRemoveSkill(entry.value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

        if (_hasUnverifiedSkills && onVerifyTap != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildVerifyButton(context, l10n),
          ),
      ],
    );
  }

  Widget _buildWarningBanner(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white : color.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentMint.withValues(alpha: 0.2),
            AppColors.brandPrimary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onVerifyTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentMint.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    color: AppColors.accentMint,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verifyButtonLabel ?? l10n.verifySkills,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.brandPrimaryDark,
                        ),
                      ),
                      Text(
                        'Take a test to verify your skills',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillEntity skill;
  final Color color;
  final bool isDark;
  final bool isLoading;
  final VoidCallback onRemove;

  const _SkillChip({
    required this.skill,
    required this.color,
    required this.isDark,
    required this.isLoading,
    required this.onRemove,
  });

  Color get _chipColor {
    if (skill.isRejected) return Colors.red;
    if (skill.isPending) return Colors.orange;
    return color;
  }

  IconData? get _statusIcon {
    if (skill.isVerified) return Icons.verified;
    if (skill.isRejected) return Icons.error_outline;
    if (skill.isPending) return Icons.hourglass_empty;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _chipColor;

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withValues(alpha: 0.25),
            chipColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_statusIcon != null) ...[
            Icon(
              _statusIcon,
              size: 14,
              color: isDark ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
          ],

          Text(
            skill.skillName,
            style: TextStyle(
              color: isDark ? Colors.white : chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          if (skill.isVerified && skill.skillLevel != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                skill.skillLevel!.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),

          if (!isLoading)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark ? Colors.white70 : chipColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

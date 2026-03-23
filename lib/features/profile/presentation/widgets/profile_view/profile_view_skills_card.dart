import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/skill_entity.dart';
import '../../../domain/entities/skill_status.dart';

class ProfileViewSkillsCard extends StatelessWidget {
  final List<SkillEntity> skills;

  final bool isDark;

  final bool isOwnProfile;

  final VoidCallback? onVerifyTap;

  final VoidCallback? onRetakeTap;

  final String? verifyButtonLabel;

  final String? retakeButtonLabel;

  const ProfileViewSkillsCard({
    super.key,
    required this.skills,
    required this.isDark,
    this.isOwnProfile = false,
    this.onVerifyTap,
    this.onRetakeTap,
    this.verifyButtonLabel,
    this.retakeButtonLabel,
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

  bool get _hasVerifiedSkills => skills.any((s) => s.isVerified);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.brandPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: skills.asMap().entries.map((entry) {
                  final color = _colors[entry.key % _colors.length];
                  return _SkillChip(
                    skill: entry.value,
                    color: color,
                    isDark: isDark,
                  );
                }).toList(),
              ),

              if (isOwnProfile &&
                  _hasUnverifiedSkills &&
                  onVerifyTap != null) ...[
                const SizedBox(height: 16),
                _buildVerifyPrompt(context, l10n),
              ],

              if (isOwnProfile &&
                  _hasVerifiedSkills &&
                  onRetakeTap != null) ...[
                const SizedBox(height: 12),
                _buildRetakeButton(context, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyPrompt(BuildContext context, AppLocalizations l10n) {
    final unverifiedCount = skills
        .where((s) => s.status == SkillStatus.approved && !s.isVerified)
        .length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.accentMint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$unverifiedCount unverified skill${unverifiedCount > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.brandPrimaryDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: onVerifyTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentMint, AppColors.brandPrimary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                verifyButtonLabel ?? l10n.verify,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetakeButton(BuildContext context, AppLocalizations l10n) {
    final verifiedCount = skills.where((s) => s.isVerified).length;

    return GestureDetector(
      onTap: onRetakeTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.replay_rounded, color: AppColors.accentGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Improve $verifiedCount verified skill${verifiedCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppColors.brandPrimaryDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                retakeButtonLabel ?? l10n.retake,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final SkillEntity skill;
  final Color color;
  final bool isDark;

  const _SkillChip({
    required this.skill,
    required this.color,
    required this.isDark,
  });

  Color get _chipColor {
    if (skill.isRejected) return Colors.red;
    if (skill.isPending) return Colors.orange;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _chipColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          if (skill.isVerified)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.verified,
                size: 14,
                color: isDark ? Colors.white : chipColor.withValues(alpha: 0.8),
              ),
            ),

          Text(
            skill.skillName,
            style: TextStyle(
              color: isDark ? Colors.white : chipColor.withValues(alpha: 0.8),
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
        ],
      ),
    );
  }
}

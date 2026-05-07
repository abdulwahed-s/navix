import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import 'glass_text_field.dart';
import 'gradient_button.dart';

class InputView extends StatelessWidget {
  final TextEditingController ideaController;
  final TextEditingController additionalContextController;
  final bool showAdditionalContext;
  final bool isDark;
  final int characterCount;
  final String describeYourIdeaLabel;
  final String minCharactersLabel;
  final String characterCountLabel;
  final String provideMoreDetailsLabel;
  final String refineIdeaLabel;
  final VoidCallback? onSubmit;
  final VoidCallback onTextChanged;

  const InputView({
    super.key,
    required this.ideaController,
    required this.additionalContextController,
    required this.showAdditionalContext,
    required this.isDark,
    required this.characterCount,
    required this.describeYourIdeaLabel,
    required this.minCharactersLabel,
    required this.characterCountLabel,
    required this.provideMoreDetailsLabel,
    required this.refineIdeaLabel,
    required this.onSubmit,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = characterCount >= 50;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputHeader(
            title: describeYourIdeaLabel,
            subtitle: minCharactersLabel,
          ),
          const SizedBox(height: 24),

          GlassTextField(
            controller: ideaController,
            hint: describeYourIdeaLabel,
            isDark: isDark,
            maxLines: 8,
            onChanged: (_) => onTextChanged(),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: characterCount < 50
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                characterCountLabel,
                style: TextStyle(
                  color: characterCount < 50
                      ? theme.colorScheme.error
                      : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (showAdditionalContext) ...[
            const SizedBox(height: 24),
            _AdditionalContextHeader(label: provideMoreDetailsLabel),
            const SizedBox(height: 16),
            GlassTextField(
              controller: additionalContextController,
              hint: provideMoreDetailsLabel,
              isDark: isDark,
              maxLines: 4,
            ),
          ],
          const SizedBox(height: 32),

          GradientButton(
            label: refineIdeaLabel,
            icon: Icons.auto_awesome,
            onPressed: isValid ? onSubmit : null,
            enabled: isValid,
          ),
        ],
      ),
    );
  }
}

class _InputHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InputHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentGold.withValues(alpha: 0.2),
                AppColors.accentGold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lightbulb_rounded,
            color: AppColors.accentGold,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdditionalContextHeader extends StatelessWidget {
  final String label;

  const _AdditionalContextHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentMint.withValues(alpha: 0.2),
                AppColors.accentMint.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add_circle_outline,
            color: AppColors.accentMint,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

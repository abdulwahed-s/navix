import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import 'gradient_button.dart';

class IdeaNavigationButtons extends StatelessWidget {
  final int currentPage;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool isLastPage;
  final bool isDark;

  const IdeaNavigationButtons({
    super.key,
    required this.currentPage,
    required this.onPrevious,
    required this.onSkip,
    required this.onNext,
    required this.isLastPage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              if (currentPage > 0)
                OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.back),
                ),
              if (currentPage > 0) const SizedBox(width: 8),
              TextButton(onPressed: onSkip, child: Text(l10n.skipStep)),
              const Spacer(),
              IdeaGradientButton(
                label: isLastPage ? l10n.generateIdeas : l10n.continueToNext,
                icon: isLastPage
                    ? Icons.auto_awesome
                    : Icons.arrow_forward_rounded,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

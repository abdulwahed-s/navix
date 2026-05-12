import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class HomeLoadingState extends StatelessWidget {
  final Animation<double> floatingAnimation;

  const HomeLoadingState({super.key, required this.floatingAnimation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, floatingAnimation.value * 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.loadingProjects,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

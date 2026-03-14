import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class CalendarEmptyState extends StatelessWidget {
  final double animationValue;

  const CalendarEmptyState({super.key, required this.animationValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Transform.translate(
        offset: Offset(0, animationValue * 0.5),
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
              child: Icon(
                Icons.event_busy_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noEventsMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

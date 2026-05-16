import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class WorkspaceTeamSection extends StatelessWidget {
  final VoidCallback onManageTeam;

  const WorkspaceTeamSection({super.key, required this.onManageTeam});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.teamMembers,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton.icon(
          onPressed: onManageTeam,
          icon: const Icon(Icons.group, size: 18),
          label: Text(l10n.manageTeam),
        ),
      ],
    );
  }
}

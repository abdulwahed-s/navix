import 'package:flutter/material.dart';

class WorkspaceEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const WorkspaceEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

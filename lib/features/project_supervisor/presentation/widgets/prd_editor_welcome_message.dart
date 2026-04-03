import 'package:flutter/material.dart';

class PrdEditorWelcomeMessage extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final Animation<double> floatingAnimation;
  final Function(String) onExampleTap;

  const PrdEditorWelcomeMessage({
    super.key,
    required this.theme,
    required this.isDark,
    required this.floatingAnimation,
    required this.onExampleTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatingAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_document,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Edit PRD with Navi',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'I can help you refine your Project Requirements Document. '
            'Ask questions, request changes, or let me explain sections.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Text(
            'Try asking me...',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          _buildExamplePrompt(
            icon: Icons.compress,
            text: 'Make the scope smaller, focus on MVP',
            theme: theme,
            isDark: isDark,
          ),
          _buildExamplePrompt(
            icon: Icons.phone_android,
            text: 'Focus on mobile app instead of cross-platform',
            theme: theme,
            isDark: isDark,
          ),
          _buildExamplePrompt(
            icon: Icons.help_outline,
            text: 'Explain why we need these functional requirements',
            theme: theme,
            isDark: isDark,
          ),
          _buildExamplePrompt(
            icon: Icons.add_box,
            text: 'Add user authentication as a core feature',
            theme: theme,
            isDark: isDark,
          ),
          _buildExamplePrompt(
            icon: Icons.remove_circle_outline,
            text: 'Remove the social sharing features',
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePrompt({
    required IconData icon,
    required String text,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onExampleTap(text),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

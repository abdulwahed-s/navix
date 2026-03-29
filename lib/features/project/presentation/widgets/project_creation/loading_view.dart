import 'dart:ui';

import 'package:flutter/material.dart';

class ProjectCreationLoadingView extends StatelessWidget {
  final String message;
  final Animation<double> floatingAnimation;
  final bool isDark;

  const ProjectCreationLoadingView({
    super.key,
    required this.message,
    required this.floatingAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, floatingAnimation.value * 0.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.5,
                              ),
                            ],
                          ),
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 36,
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
                        message,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

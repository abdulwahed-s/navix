import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class MessageInputArea extends StatelessWidget {
  final TextEditingController controller;

  final FocusNode focusNode;

  final bool isDark;

  final Animation<double> sendButtonAnimation;

  final VoidCallback onSend;

  final VoidCallback onTapDown;

  final VoidCallback onTapUp;

  final VoidCallback onTapCancel;

  final ValueChanged<bool> onFocusChange;

  const MessageInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.sendButtonAnimation,
    required this.onSend,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTextField(theme, l10n)),
                const SizedBox(width: 12),

                _buildSendButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, AppLocalizations l10n) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: l10n.typeMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          maxLines: 4,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => onSend(),
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    return ScaleTransition(
      scale: sendButtonAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkPrimary, AppColors.accentRose]
                : [AppColors.brandPrimary, AppColors.brandPrimaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkPrimary : AppColors.brandPrimary)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTapDown: (_) => onTapDown(),
            onTapUp: (_) => onTapUp(),
            onTapCancel: onTapCancel,
            onTap: onSend,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                Icons.send_rounded,
                color: isDark ? AppColors.darkOnPrimary : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

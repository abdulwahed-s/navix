import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileEditOtherLinksSection extends StatelessWidget {
  final List<TextEditingController> controllers;

  final String sectionTitle;

  final String addButtonLabel;

  final String linkHint;

  final String invalidUrlMessage;

  final bool isDark;

  final bool isLoading;

  final bool Function(String) urlValidator;

  final VoidCallback onAddLink;

  final void Function(int index) onRemoveLink;

  const ProfileEditOtherLinksSection({
    super.key,
    required this.controllers,
    required this.sectionTitle,
    required this.addButtonLabel,
    required this.linkHint,
    required this.invalidUrlMessage,
    required this.isDark,
    required this.isLoading,
    required this.urlValidator,
    required this.onAddLink,
    required this.onRemoveLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentMint.withValues(alpha: 0.3),
                        AppColors.accentMint.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: AppColors.successDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  sectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentMint, AppColors.successDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onAddLink,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          addButtonLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.85),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: TextFormField(
                          controller: controllers[index],
                          enabled: !isLoading,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: linkHint,
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentMint.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.link_rounded,
                                color: AppColors.successDark,
                                size: 18,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !urlValidator(value)) {
                              return invalidUrlMessage;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : () => onRemoveLink(index),
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

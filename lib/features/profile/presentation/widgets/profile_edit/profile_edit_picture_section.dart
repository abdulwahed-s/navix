import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileEditPictureSection extends StatelessWidget {
  final File? selectedImageFile;

  final String? existingImageUrl;

  final bool isDark;

  final bool isLoading;

  final String changePhotoLabel;

  final VoidCallback onTap;

  const ProfileEditPictureSection({
    super.key,
    required this.selectedImageFile,
    required this.existingImageUrl,
    required this.isDark,
    required this.isLoading,
    required this.changePhotoLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandPrimary, AppColors.accentRose],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurface : Colors.white,
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: selectedImageFile != null
                          ? FileImage(selectedImageFile!)
                          : existingImageUrl != null
                          ? CachedNetworkImageProvider(existingImageUrl!)
                          : null,
                      child:
                          selectedImageFile == null && existingImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 52,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.brandPrimary,
                              AppColors.accentRose,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandPrimary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : onTap,
            child: Text(
              changePhotoLabel,
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ProfileEditImagePickerSheet extends StatelessWidget {
  final bool isDark;

  final String takePhotoLabel;

  final String galleryLabel;

  final String? removePhotoLabel;

  final VoidCallback onTakePhoto;

  final VoidCallback onChooseGallery;

  final VoidCallback? onRemovePhoto;

  const ProfileEditImagePickerSheet({
    super.key,
    required this.isDark,
    required this.takePhotoLabel,
    required this.galleryLabel,
    this.removePhotoLabel,
    required this.onTakePhoto,
    required this.onChooseGallery,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                _ImagePickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: takePhotoLabel,
                  color: AppColors.brandPrimary,
                  onTap: onTakePhoto,
                  isDark: isDark,
                ),

                _ImagePickerOption(
                  icon: Icons.photo_library_rounded,
                  label: galleryLabel,
                  color: AppColors.accentLavender,
                  onTap: onChooseGallery,
                  isDark: isDark,
                ),

                if (removePhotoLabel != null && onRemovePhoto != null)
                  _ImagePickerOption(
                    icon: Icons.delete_outline_rounded,
                    label: removePhotoLabel!,
                    color: theme.colorScheme.error,
                    onTap: onRemovePhoto!,
                    isDark: isDark,
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.brandPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';

class AuthorInfoWidget extends StatefulWidget {
  final String authorId;
  final DateTime createdAt;
  final TextStyle? nameStyle;
  final double avatarRadius;

  const AuthorInfoWidget({
    super.key,
    required this.authorId,
    required this.createdAt,
    this.nameStyle,
    this.avatarRadius = 16,
  });

  @override
  State<AuthorInfoWidget> createState() => _AuthorInfoWidgetState();
}

class _AuthorInfoWidgetState extends State<AuthorInfoWidget>
    with SingleTickerProviderStateMixin {
  static final Map<String, ProfileEntity?> _profileCache = {};

  ProfileEntity? _profile;
  bool _isLoading = true;
  bool _hasError = false;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_profileCache.containsKey(widget.authorId)) {
      setState(() {
        _profile = _profileCache[widget.authorId];
        _isLoading = false;
      });
      return;
    }

    try {
      final profileRepo = sl<ProfileRepository>();
      final result = await profileRepo.getProfile(widget.authorId);

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        },
        (profile) {
          _profileCache[widget.authorId] = profile;
          if (mounted) {
            setState(() {
              _profile = profile;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingSkeleton(theme, isDark);
    }

    final displayName = _hasError || _profile == null
        ? 'Unknown User'
        : _profile?.name ?? 'Unknown User';
    final avatarUrl = _hasError || _profile == null
        ? null
        : _profile?.profilePicUrl;

    return Row(
      children: [
        _buildGradientAvatar(theme, avatarUrl, displayName, isDark),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style:
                    widget.nameStyle ??
                    theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientAvatar(
    ThemeData theme,
    String? avatarUrl,
    String displayName,
    bool isDark,
  ) {
    final gradientColors = [
      AppColors.accentLavender,
      AppColors.brandPrimary,
      AppColors.accentRose,
    ];

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.darkSurface : AppColors.brandCream,
        ),
        child: CircleAvatar(
          radius: widget.avatarRadius,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: avatarUrl != null
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: avatarUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;
        final shimmerColor = isDark
            ? Color.lerp(
                Colors.grey[800],
                Colors.grey[600],
                (shimmerValue * 2 - 1).abs(),
              )!
            : Color.lerp(
                Colors.grey[300],
                Colors.grey[100],
                (shimmerValue * 2 - 1).abs(),
              )!;

        return Row(
          children: [
            Container(
              width: widget.avatarRadius * 2 + 8,
              height: widget.avatarRadius * 2 + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: shimmerColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

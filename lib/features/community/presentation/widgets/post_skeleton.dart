import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PostSkeleton extends StatefulWidget {
  const PostSkeleton({super.key});

  @override
  State<PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<PostSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.85),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildShimmerCircle(44, isDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShimmerBox(120, 14, isDark),
                              const SizedBox(height: 6),
                              _buildShimmerBox(80, 12, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildShimmerBox(double.infinity, 20, isDark),
                    const SizedBox(height: 8),
                    _buildShimmerBox(200, 20, isDark),
                    const SizedBox(height: 6),

                    _buildShimmerBox(40, 3, isDark),
                    const SizedBox(height: 12),

                    _buildShimmerBox(double.infinity, 14, isDark),
                    const SizedBox(height: 6),
                    _buildShimmerBox(double.infinity, 14, isDark),
                    const SizedBox(height: 6),
                    _buildShimmerBox(180, 14, isDark),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildShimmerBox(100, 36, isDark, borderRadius: 24),
                        const SizedBox(width: 12),
                        _buildShimmerBox(60, 32, isDark, borderRadius: 20),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    bool isDark, {
    double borderRadius = 8,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _shimmerAnimation.value, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: isDark
                  ? [Colors.grey[850]!, Colors.grey[700]!, Colors.grey[850]!]
                  : [
                      AppColors.brandLightGray,
                      Colors.white,
                      AppColors.brandLightGray,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCircle(double size, bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment(-1 + _shimmerAnimation.value, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: isDark
                  ? [Colors.grey[850]!, Colors.grey[700]!, Colors.grey[850]!]
                  : [
                      AppColors.brandLightGray,
                      Colors.white,
                      AppColors.brandLightGray,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

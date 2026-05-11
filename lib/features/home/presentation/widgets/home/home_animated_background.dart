import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class HomeAnimatedBackground extends StatelessWidget {
  final Animation<double> floatingAnimation;

  final bool isDark;

  final Size size;

  const HomeAnimatedBackground({
    super.key,
    required this.floatingAnimation,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.2),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentLavender.withValues(alpha: 0.2),
                      AppColors.brandCream,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: HomeBackgroundPatternPainter(
              isDark: isDark,
              animationValue: floatingAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class HomeBackgroundPatternPainter extends CustomPainter {
  final bool isDark;

  final double animationValue;

  HomeBackgroundPatternPainter({
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : AppColors.brandPrimary.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 60.0;
    for (var x = 0.0; x < size.width + spacing; x += spacing) {
      final offsetX = x + (animationValue * 0.5);
      canvas.drawLine(Offset(offsetX, 0), Offset(offsetX, size.height), paint);
    }
    for (var y = 0.0; y < size.height + spacing; y += spacing) {
      final offsetY = y + (animationValue * 0.3);
      canvas.drawLine(Offset(0, offsetY), Offset(size.width, offsetY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant HomeBackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class ChatListAnimatedBackground extends StatelessWidget {
  final bool isDark;

  final Size size;

  final double animationValue;

  const ChatListAnimatedBackground({
    super.key,
    required this.isDark,
    required this.size,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.darkPrimaryContainer.withValues(alpha: 0.2),
                  AppColors.darkSurface,
                ]
              : [
                  AppColors.brandCream,
                  AppColors.lightPrimaryContainer.withValues(alpha: 0.3),
                  AppColors.brandCream,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        size: size,
        painter: _BackgroundPatternPainter(
          isDark: isDark,
          animationValue: animationValue,
        ),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final bool isDark;
  final double animationValue;

  _BackgroundPatternPainter({
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    paint.color = (isDark ? Colors.white : AppColors.brandPrimaryDark)
        .withValues(alpha: 0.015);

    const spacing = 50.0;
    for (var i = 0; i < size.width / spacing; i++) {
      final x = i * spacing + (animationValue * 0.3);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var i = 0; i < size.height / spacing; i++) {
      final y = i * spacing - (animationValue * 0.2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.style = PaintingStyle.fill;
    final random = math.Random(42);
    for (var i = 0; i < 6; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      paint.color = AppColors.brandPrimary.withValues(
        alpha: random.nextDouble() * 0.06,
      );
      canvas.drawCircle(
        Offset(x, y + animationValue * (i.isEven ? 1 : -1) * 0.15),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}

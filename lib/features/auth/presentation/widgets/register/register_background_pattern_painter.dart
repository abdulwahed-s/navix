import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class RegisterBackgroundPatternPainter extends CustomPainter {
  final bool isDark;

  final double animationValue;

  RegisterBackgroundPatternPainter({
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    paint.color = (isDark ? Colors.white : AppColors.brandPrimaryDark)
        .withValues(alpha: 0.02);

    const spacing = 40.0;
    for (var i = 0; i < size.width / spacing; i++) {
      final x = i * spacing - (animationValue * 0.5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var i = 0; i < size.height / spacing; i++) {
      final y = i * spacing + (animationValue * 0.3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.style = PaintingStyle.fill;
    final random = math.Random(24);
    final accentColors = [
      AppColors.accentGold,
      AppColors.accentLavender,
      AppColors.accentMint,
      AppColors.accentRose,
    ];

    for (var i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      final colorIndex = i % accentColors.length;
      paint.color = accentColors[colorIndex].withValues(
        alpha: random.nextDouble() * 0.08,
      );
      canvas.drawCircle(
        Offset(x, y + animationValue * (i.isEven ? 1 : -1) * 0.2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RegisterBackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}

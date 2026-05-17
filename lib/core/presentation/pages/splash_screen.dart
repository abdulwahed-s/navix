import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SplashBackgroundPatternPainter(
                    animationValue: _animation.value,
                  ),
                );
              },
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/navi.png', width: 150, height: 150),
                const SizedBox(height: 24),

                Image.asset('assets/images/logoWhite.png', width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  _SplashBackgroundPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
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
  bool shouldRepaint(covariant _SplashBackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

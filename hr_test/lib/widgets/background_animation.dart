// lib/widgets/background_animation.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({Key? key}) : super(key: key);

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (ctx, child) {
        return CustomPaint(
          painter: _WavePainter(_waveAnimation.value),
          child: Container(),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    const waveHeight = 40.0;
    final waveLength = size.width / 1.5;
    final offset = animationValue * waveLength;
    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = -waveLength + offset; x <= size.width + waveLength; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 4, size.height / 2 - waveHeight,
        x + waveLength / 2, size.height / 2,
      );
      path.quadraticBezierTo(
        x + 3 * waveLength / 4, size.height / 2 + waveHeight,
        x + waveLength, size.height / 2,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

class EnhancedAntiCameraText extends StatefulWidget {
  final String text;
  final double fontSize;

  const EnhancedAntiCameraText({
    super.key,
    required this.text,
    this.fontSize = 24,
  });

  @override
  State<EnhancedAntiCameraText> createState() => _EnhancedAntiCameraTextState();
}

class _EnhancedAntiCameraTextState extends State<EnhancedAntiCameraText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _colorTimer;
  Color _currentColor1 = Colors.blue;
  Color _currentColor2 = Colors.red;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat(reverse: true);

    // 빠른 색상 변화를 위한 타이머
    _colorTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          _updateColors();
        });
      }
    });
  }

  void _updateColors() {
    final random = math.Random();
    // IR 감지를 방해하는 특수한 색상 조합 사용
    _currentColor1 = Color.fromARGB(
        255,
        200 + random.nextInt(56), // 높은 R값
        random.nextInt(50), // 낮은 G값
        random.nextInt(50) // 낮은 B값
        );

    _currentColor2 = Color.fromARGB(
        255,
        random.nextInt(50), // 낮은 R값
        200 + random.nextInt(56), // 높은 G값
        200 + random.nextInt(56) // 높은 B값
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 기본 텍스트
        Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // 깜빡이는 레이어
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    _currentColor1,
                    _currentColor2,
                  ],
                  transform: GradientRotation(_controller.value * math.pi * 2),
                ).createShader(bounds);
              },
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        // 고주파 간섭 패턴
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: InterferencePatternPainter(
                color1: _currentColor1,
                color2: _currentColor2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InterferencePatternPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double frequency = 2.0;

  InterferencePatternPainter({
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 1) {
      for (double j = 0; j < size.height; j += 1) {
        final sin1 = math.sin((i + j) * frequency);
        final sin2 = math.sin((i - j) * frequency);
        final pattern = (sin1 + sin2).abs();

        paint.color = Color.lerp(
            color1.withOpacity(0.3), color2.withOpacity(0.3), pattern)!;

        canvas.drawPoints(
          ui.PointMode.points,
          [Offset(i, j)],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(InterferencePatternPainter oldDelegate) {
    return color1 != oldDelegate.color1 || color2 != oldDelegate.color2;
  }
}

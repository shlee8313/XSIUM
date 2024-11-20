import 'package:flutter/material.dart';

class ThemeSwitcherWidget extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final Function(bool) onThemeChanged;

  const ThemeSwitcherWidget({
    super.key,
    required this.child,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSwitcherWidget> createState() => _ThemeSwitcherWidgetState();
}

class _ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isDark = false;
  Offset? _tapPosition;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onThemeChanged(_isDark);
      _isAnimating = false;
      _tapPosition = null;
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation(Offset position) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _tapPosition = position;
      _isDark = !_isDark;
    });

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 기존 UI 유지
        widget.child,

        // 애니메이션 레이어
        if (_tapPosition != null && _isAnimating)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CircleRevealPainter(
                  center: _tapPosition!,
                  radius: _animation.value *
                      (MediaQuery.of(context).size.longestSide * 1.5),
                  isDark: _isDark,
                  progress: _animation.value,
                ),
              );
            },
          ),

        // 탭 감지를 위한 투명 레이어
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (details) {
              if (!_isAnimating) {
                _startAnimation(details.globalPosition);
              }
            },
          ),
        ),
      ],
    );
  }
}

class CircleRevealPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final bool isDark;
  final double progress;

  CircleRevealPainter({
    required this.center,
    required this.radius,
    required this.isDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF5F5F5);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CircleRevealPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.progress != progress;
  }
}

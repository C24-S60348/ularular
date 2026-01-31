import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Creates a pulsing animation widget
/// [child] - The widget to animate
/// [maxScale] - Maximum scale (e.g., 1.2 for 120% size)
/// [minScale] - Minimum scale (e.g., 0.9 for 90% size)
/// [duration] - Duration of one complete pulse cycle
Widget buildPulsingWidget({
  required Widget child,
  double maxScale = 1.2,
  double minScale = 0.9,
  Duration duration = const Duration(milliseconds: 1500),
}) {
  return PulsingWidget(
    maxScale: maxScale,
    minScale: minScale,
    duration: duration,
    child: child,
  );
}

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final double minScale;
  final Duration duration;

  const PulsingWidget({
    super.key,
    required this.child,
    this.maxScale = 1.2,
    this.minScale = 0.9,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Repeat the animation back and forth continuously
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Creates a floating rotation animation widget
/// [child] - The widget to animate
/// [minAngle] - Minimum rotation angle in degrees (e.g., -5)
/// [maxAngle] - Maximum rotation angle in degrees (e.g., 5)
/// [duration] - Duration of one complete rotation cycle
Widget buildFloatingWidget({
  required Widget child,
  double minAngle = -5.0,
  double maxAngle = 5.0,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  return FloatingWidget(
    minAngle: minAngle,
    maxAngle: maxAngle,
    duration: duration,
    child: child,
  );
}

class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double minAngle;
  final double maxAngle;
  final Duration duration;

  const FloatingWidget({
    super.key,
    required this.child,
    this.minAngle = -5.0,
    this.maxAngle = 5.0,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minAngle,
      end: widget.maxAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Repeat the animation back and forth continuously
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * math.pi / 180, // Convert degrees to radians
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Creates a bold title with stroke effect and letter spacing
/// [text] - The text to display
/// [fontSize] - Font size (default: 32)
/// [color] - Main text color
/// [strokeColor] - Outline/stroke color
/// [strokeWidth] - Width of the stroke (default: 2)
/// [letterSpacing] - Letter spacing (default: 3)
Widget buildBoldTitle({
  required String text,
  double fontSize = 32,
  Color color = const Color.fromARGB(255, 15, 102, 173),
  Color strokeColor = const Color.fromARGB(255, 19, 128, 218),
  double strokeWidth = 2,
  double letterSpacing = 2,
}) {
  return Stack(
    children: [
      // Stroke/outline effect
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: letterSpacing,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = strokeColor,
        ),
      ),
      // Filled text on top
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: letterSpacing,
          color: color,
        ),
      ),
    ],
  );
}

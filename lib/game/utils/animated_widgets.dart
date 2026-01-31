import 'package:flutter/material.dart';

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

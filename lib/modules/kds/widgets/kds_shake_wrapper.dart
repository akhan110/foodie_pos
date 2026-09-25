import 'dart:math' as math;
import 'package:flutter/material.dart';

class KdsShakeWrapper extends StatefulWidget {
  final Widget child;
  final bool isShaking;

  const KdsShakeWrapper({
    super.key,
    required this.child,
    required this.isShaking,
  });

  @override
  State<KdsShakeWrapper> createState() => _KdsShakeWrapperState();
}

class _KdsShakeWrapperState extends State<KdsShakeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isShaking) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant KdsShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward(from: 0.0);
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _controller.reset();
    }
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
        if (!_controller.isAnimating && !widget.isShaking) {
          return child!;
        }

        // Oscillate with 10 waves over the 3.5s duration, decaying smoothly
        final progress = _animation.value;
        final decay = 1.0 - (progress * 0.5); // stays energetic, softly eases at the end
        final offset = math.sin(progress * math.pi * 14) * 7.0 * decay;
        final glowAlpha = (math.sin(progress * math.pi * 7).abs() * 0.45 * decay).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: glowAlpha),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

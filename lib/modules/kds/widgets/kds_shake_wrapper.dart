import 'dart:math' as math;
import 'package:flutter/material.dart';

class KdsShakeWrapper extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final Color? pulseGlowColor; // Ambient glow for 2-min warning & overdue

  const KdsShakeWrapper({
    super.key,
    required this.child,
    required this.isShaking,
    this.pulseGlowColor,
  });

  @override
  State<KdsShakeWrapper> createState() => _KdsShakeWrapperState();
}

class _KdsShakeWrapperState extends State<KdsShakeWrapper>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Gentle arrival nudge (1.8s, calm and refined - no violent dancing)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeOutCubic),
    );

    // 2. Ambient breathing pulse for 2-min remaining and overdue ending timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isShaking) {
      _shakeController.forward(from: 0.0);
    }

    if (widget.pulseGlowColor != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant KdsShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward(from: 0.0);
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _shakeController.reset();
    }

    if (widget.pulseGlowColor != null && oldWidget.pulseGlowColor == null) {
      _pulseController.repeat(reverse: true);
    } else if (widget.pulseGlowColor == null && oldWidget.pulseGlowColor != null) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _pulseAnimation]),
      builder: (context, child) {
        // --- 1. Arrival Nudge Calculation ---
        double offsetX = 0.0;
        double angle = 0.0;

        if (_shakeController.isAnimating) {
          final progress = _shakeAnimation.value;
          final decay = math.pow(1.0 - progress, 2).toDouble(); // fast smooth decay

          // Subtle 2-cycle gentle nudge (max ±1.2 degrees)
          angle = math.sin(progress * math.pi * 5) * 0.022 * decay;
          offsetX = math.sin(progress * math.pi * 5) * 2.5 * decay;
        }

        // --- 2. Ambient Glowing Border for Warning & Overdue ---
        final glowColor = widget.pulseGlowColor;
        final glowAlpha = glowColor != null ? _pulseAnimation.value : 0.0;

        Widget content = child!;

        if (glowColor != null) {
          content = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowAlpha * 0.55),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: content,
          );
        }

        if (offsetX != 0.0 || angle != 0.0) {
          content = Transform.translate(
            offset: Offset(offsetX, 0.0),
            child: Transform.rotate(
              angle: angle,
              alignment: Alignment.center,
              child: content,
            ),
          );
        }

        return content;
      },
      child: widget.child,
    );
  }
}

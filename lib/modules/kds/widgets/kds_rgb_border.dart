import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated RGB Travelling Light Border Wrapper.
///
/// Draws a continuous, revolving rainbow / RGB gradient border around the child card
/// with a luminous outer neon bloom glow when [isRgbActive] is true.
/// Also incorporates gentle arrival nudge shake if [isShaking] is true.
class KdsRgbBorderWrapper extends StatefulWidget {
  final Widget child;
  final bool isRgbActive;
  final bool isShaking;
  final double borderRadius;
  final double borderWidth;
  final Color? fallbackPulseGlowColor;

  const KdsRgbBorderWrapper({
    super.key,
    required this.child,
    required this.isRgbActive,
    this.isShaking = false,
    this.borderRadius = 16.0,
    this.borderWidth = 3.0,
    this.fallbackPulseGlowColor,
  });

  @override
  State<KdsRgbBorderWrapper> createState() => _KdsRgbBorderWrapperState();
}

class _KdsRgbBorderWrapperState extends State<KdsRgbBorderWrapper>
    with TickerProviderStateMixin {
  late AnimationController _rgbController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Continuous RGB travelling light rotation loop (2.4s period)
    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 2. Arrival nudge shake (1.8s)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeOutCubic),
    );

    // 3. Ambient breathing pulse for non-RGB fallback states
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRgbActive) {
      _rgbController.repeat();
    }

    if (widget.isShaking) {
      _shakeController.forward(from: 0.0);
    }

    if (widget.fallbackPulseGlowColor != null && !widget.isRgbActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant KdsRgbBorderWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRgbActive && !oldWidget.isRgbActive) {
      _rgbController.repeat();
      _pulseController.stop();
    } else if (!widget.isRgbActive && oldWidget.isRgbActive) {
      _rgbController.stop();
      _rgbController.reset();
      if (widget.fallbackPulseGlowColor != null) {
        _pulseController.repeat(reverse: true);
      }
    }

    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward(from: 0.0);
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _shakeController.reset();
    }

    if (!widget.isRgbActive) {
      if (widget.fallbackPulseGlowColor != null && oldWidget.fallbackPulseGlowColor == null) {
        _pulseController.repeat(reverse: true);
      } else if (widget.fallbackPulseGlowColor == null && oldWidget.fallbackPulseGlowColor != null) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _rgbController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rgbController, _shakeAnimation, _pulseAnimation]),
      builder: (context, child) {
        // --- 1. Arrival Nudge Offset & Angle ---
        double offsetX = 0.0;
        double angle = 0.0;

        if (_shakeController.isAnimating) {
          final progress = _shakeAnimation.value;
          final decay = math.pow(1.0 - progress, 2).toDouble();
          angle = math.sin(progress * math.pi * 5) * 0.022 * decay;
          offsetX = math.sin(progress * math.pi * 5) * 2.5 * decay;
        }

        // --- 2. Build Card Content with Border ---
        Widget content = child!;

        if (widget.isRgbActive) {
          content = CustomPaint(
            foregroundPainter: _RgbTravellingBorderPainter(
              animationValue: _rgbController.value,
              borderWidth: widget.borderWidth,
              borderRadius: widget.borderRadius,
            ),
            child: content,
          );
        } else if (widget.fallbackPulseGlowColor != null) {
          final glowColor = widget.fallbackPulseGlowColor!;
          final glowAlpha = _pulseAnimation.value;
          content = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
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

class _RgbTravellingBorderPainter extends CustomPainter {
  final double animationValue; // 0.0 -> 1.0
  final double borderWidth;
  final double borderRadius;

  _RgbTravellingBorderPainter({
    required this.animationValue,
    required this.borderWidth,
    required this.borderRadius,
  });

  // Full rich spectral rainbow sequence
  static const List<Color> _rainbowColors = [
    Color(0xFFFF0055), // Vibrant Crimson Pink
    Color(0xFFFF5500), // Electric Orange
    Color(0xFFFFCC00), // Bright Yellow
    Color(0xFF00FF66), // Neon Green
    Color(0xFF00E5FF), // Vivid Cyan
    Color(0xFF3B82F6), // Deep Royal Blue
    Color(0xFF9333EA), // Electric Purple
    Color(0xFFFF00AA), // Hot Magenta
    Color(0xFFFF0055), // Loop back
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );

    final angle = animationValue * 2 * math.pi;

    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: _rainbowColors,
      transform: GradientRotation(angle),
    );

    final shader = sweepGradient.createShader(rect);

    // 1. Soft Outer Neon Bloom / Travelling Glow
    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawRRect(rrect, glowPaint);

    // 2. Crisp Primary Travelling RGB Stroke
    final borderPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RgbTravellingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

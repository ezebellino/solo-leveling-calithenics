import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class HolographicPanel extends StatefulWidget {
  const HolographicPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.glowColor = const Color(0xFF69D6FF),
    this.borderRadius = 28,
    this.decorate = true,
    this.cornerInset = 6,
    this.cornerSize = 18,
    this.showCorners = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color glowColor;
  final double borderRadius;
  final bool decorate;
  final double cornerInset;
  final double cornerSize;
  final bool showCorners;

  @override
  State<HolographicPanel> createState() => _HolographicPanelState();
}

class _HolographicPanelState extends State<HolographicPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.18),
                blurRadius: 30,
                spreadRadius: -6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B1621).withValues(alpha: 0.92),
                      const Color(0xFF091018).withValues(alpha: 0.80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: widget.glowColor.withValues(alpha: 0.60),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AmbientPanelPainter(
                          phase: _controller.value,
                          accent: widget.glowColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    if (widget.decorate)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CircuitPainter(
                            accent: widget.glowColor.withValues(alpha: 0.09),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF08111A).withValues(alpha: 0.90),
                              const Color(0xFF08111A).withValues(alpha: 0.76),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.50, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.10, -0.08),
                              radius: 0.92,
                              colors: [
                                const Color(0xFF08111A).withValues(alpha: 0.72),
                                const Color(0xFF08111A).withValues(alpha: 0.40),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.46, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.child,
                    if (widget.showCorners) ...[
                      Positioned(
                        left: widget.cornerInset,
                        top: widget.cornerInset,
                        child: _PanelCorner(
                          color: widget.glowColor,
                          top: true,
                          left: true,
                          size: widget.cornerSize,
                        ),
                      ),
                      Positioned(
                        right: widget.cornerInset,
                        top: widget.cornerInset,
                        child: _PanelCorner(
                          color: widget.glowColor,
                          top: true,
                          left: false,
                          size: widget.cornerSize,
                        ),
                      ),
                      Positioned(
                        left: widget.cornerInset,
                        bottom: widget.cornerInset,
                        child: _PanelCorner(
                          color: widget.glowColor,
                          top: false,
                          left: true,
                          size: widget.cornerSize,
                        ),
                      ),
                      Positioned(
                        right: widget.cornerInset,
                        bottom: widget.cornerInset,
                        child: _PanelCorner(
                          color: widget.glowColor,
                          top: false,
                          left: false,
                          size: widget.cornerSize,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AmbientPanelPainter extends CustomPainter {
  const _AmbientPanelPainter({
    required this.phase,
    required this.accent,
  });

  final double phase;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final mistPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.0),
          accent.withValues(alpha: 0.22),
          accent.withValues(alpha: 0.10),
          accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var i = 0; i < 2; i++) {
      final startX = (-size.width * 0.25) +
          (((phase * size.width * (0.55 + (i * 0.22))) +
                  (i * size.width * 0.35)) %
              (size.width * 1.35));
      final baseY = size.height * (0.26 + (i * 0.28));
      final path = Path()
        ..moveTo(startX, baseY + _panelWave(startX, size, 0.8 + (i * 0.15)))
        ..cubicTo(
          startX + size.width * 0.10,
          baseY - 12 + _panelWave(startX + 40, size, 0.9 + (i * 0.1)),
          startX + size.width * 0.24,
          baseY + 18 + _panelWave(startX + 90, size, 1.0 + (i * 0.1)),
          startX + size.width * 0.38,
          baseY + _panelWave(startX + 140, size, 0.92 + (i * 0.08)),
        )
        ..cubicTo(
          startX + size.width * 0.52,
          baseY - 14 + _panelWave(startX + 200, size, 1.1 + (i * 0.1)),
          startX + size.width * 0.68,
          baseY + 12 + _panelWave(startX + 260, size, 0.95 + (i * 0.08)),
          startX + size.width * 0.86,
          baseY + _panelWave(startX + 320, size, 0.84 + (i * 0.1)),
        );

      canvas.drawPath(path, mistPaint);
    }

    final orbX = (size.width * 0.18) + (math.sin(phase * math.pi * 2) * 18);
    final orbY =
        (size.height * 0.22) + (math.cos(phase * math.pi * 2 * 0.8) * 10);
    final orbPaint = Paint()
      ..color = accent.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(orbX, orbY), 34, orbPaint);
  }

  double _panelWave(double seed, Size size, double speed) {
    final t = (phase * math.pi * 2 * speed) + (seed / size.width * math.pi * 2);
    return (math.sin(t) * 5) + (math.cos(t * 0.72) * 3);
  }

  @override
  bool shouldRepaint(covariant _AmbientPanelPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.accent != accent;
}

class _PanelCorner extends StatelessWidget {
  const _PanelCorner({
    required this.color,
    required this.top,
    required this.left,
    required this.size,
  });

  final Color color;
  final bool top;
  final bool left;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: !left,
      flipY: !top,
      child: CustomPaint(
        size: Size.square(size),
        painter: _CornerPainter(color),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.55, 0)
      ..moveTo(0, size.height * 0.82)
      ..lineTo(size.width * 0.22, size.height * 0.82)
      ..lineTo(size.width * 0.22, size.height)
      ..moveTo(size.width * 0.82, 0)
      ..lineTo(size.width * 0.82, size.height * 0.22)
      ..lineTo(size.width, size.height * 0.22);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CircuitPainter extends CustomPainter {
  const _CircuitPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final verticalA = Path()
      ..moveTo(size.width * 0.68, size.height * 0.12)
      ..lineTo(size.width * 0.80, size.height * 0.12)
      ..lineTo(size.width * 0.80, size.height * 0.30)
      ..lineTo(size.width * 0.92, size.height * 0.30);

    final verticalB = Path()
      ..moveTo(size.width * 0.72, size.height * 0.66)
      ..lineTo(size.width * 0.84, size.height * 0.66)
      ..lineTo(size.width * 0.84, size.height * 0.80)
      ..lineTo(size.width * 0.92, size.height * 0.80);

    final diagonal = Path()
      ..moveTo(size.width * 0.62, size.height * 0.82)
      ..lineTo(size.width * 0.72, size.height * 0.76)
      ..lineTo(size.width * 0.82, size.height * 0.82)
      ..lineTo(size.width * 0.92, size.height * 0.78);

    canvas.drawPath(verticalA, paint);
    canvas.drawPath(verticalB, paint);
    canvas.drawPath(diagonal, paint);

    final glow = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.30),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.50,
        size.width * 0.66,
        1.4,
      ),
      glow,
    );

    final speckPaint = Paint()..color = accent.withValues(alpha: 0.18);
    for (var i = 0; i < 6; i++) {
      final dx = size.width * (0.60 + (i * 0.055));
      final dy = size.height * (0.16 + ((i % 3) * 0.20));
      canvas.drawCircle(Offset(dx, dy), 1.2 + (i % 2), speckPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

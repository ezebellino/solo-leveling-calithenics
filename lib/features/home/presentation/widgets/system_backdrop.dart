import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'section_palette.dart';

class SystemBackdrop extends StatefulWidget {
  const SystemBackdrop({required this.mode, super.key});

  final int mode;

  @override
  State<SystemBackdrop> createState() => _SystemBackdropState();
}

class _SystemBackdropState extends State<SystemBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    Color(0xFF10263A),
                    Color(0xFF050A12),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BackdropPainter(
                  phase: _controller.value,
                  mode: widget.mode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.phase, required this.mode});

  final double phase;
  final int mode;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = switch (mode) {
      1 => const SectionPalette(
          primary: Color(0xFF4DF0FF),
          secondary: Color(0xFF24FFAE),
          highlight: Color(0xFFDCFFF6),
        ),
      2 => const SectionPalette(
          primary: Color(0xFF6DDCFF),
          secondary: Color(0xFF7AB8FF),
          highlight: Color(0xFFD7EEFF),
        ),
      3 => const SectionPalette(
          primary: Color(0xFF8ED8FF),
          secondary: Color(0xFF7AF0D4),
          highlight: Color(0xFFF3FBFF),
        ),
      _ => const SectionPalette(
          primary: Color(0xFF79E7FF),
          secondary: Color(0xFF25F3B4),
          highlight: Color(0xFFB7F2FF),
        ),
    };

    final linePaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.08)
      ..strokeWidth = 0.9;

    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.08 + (i * 0.11));
      canvas.drawLine(
        Offset(size.width * 0.06, y),
        Offset(size.width * 0.94, y),
        linePaint,
      );
    }

    final glowPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawLine(
      Offset(size.width * 0.08, 26),
      Offset(size.width * 0.92, 26),
      glowPaint..strokeWidth = 6,
    );

    final intensity = switch (mode) {
      1 => 1.15,
      2 => 1.35,
      3 => 0.9,
      _ => 1.0,
    };

    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.primary,
      colorB: palette.secondary,
      opacity: 0.16 * intensity,
      strokeWidth: 2.6 + (mode == 2 ? 0.4 : 0),
      verticalOffset: size.height * 0.22,
      speed: 1.0 + (mode * 0.08),
    );
    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.secondary,
      colorB: palette.primary,
      opacity: 0.11 * intensity,
      strokeWidth: 1.9 + (mode == 1 ? 0.2 : 0),
      verticalOffset: size.height * 0.48,
      speed: 1.45 + (mode * 0.06),
    );
    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.highlight,
      colorB: palette.primary,
      opacity: 0.08 * intensity,
      strokeWidth: 1.5,
      verticalOffset: size.height * 0.72,
      speed: 1.9 + (mode * 0.05),
    );
  }

  void _drawSmokeLayer(
    Canvas canvas,
    Size size, {
    required Color colorA,
    required Color colorB,
    required double opacity,
    required double strokeWidth,
    required double verticalOffset,
    required double speed,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          colorA.withValues(alpha: 0.0),
          colorA.withValues(alpha: opacity),
          colorB.withValues(alpha: opacity * 0.72),
          colorA.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, verticalOffset - 80, size.width, 160))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    final shift = (phase * size.width * 0.9 * speed) % (size.width * 1.4);
    for (var i = -1; i < 3; i++) {
      final startX = -size.width * 0.35 + (i * size.width * 0.52) + shift;
      final laneDrift = math.sin((phase * math.pi * 2 * 0.55) + (i * 1.3)) * 18;
      final breeze = math.cos((phase * math.pi * 2 * 0.35) + (i * 0.9)) * 14;
      final a = 24 + (math.sin((phase * math.pi * 2) + i) * 12);
      final b = 38 + (math.cos((phase * math.pi * 2 * 0.8) + i) * 14);
      final c = 20 + (math.sin((phase * math.pi * 2 * 1.2) + i) * 10);
      final path = Path()
        ..moveTo(
          startX,
          verticalOffset + laneDrift + _wave(startX, size, speed),
        )
        ..cubicTo(
          startX + size.width * 0.10,
          verticalOffset - a + laneDrift + _wave(startX + 20, size, speed),
          startX + size.width * 0.24,
          verticalOffset + b + breeze + _wave(startX + 80, size, speed),
          startX + size.width * 0.38,
          verticalOffset + laneDrift + _wave(startX + 140, size, speed),
        )
        ..cubicTo(
          startX + size.width * 0.50,
          verticalOffset - (a + 10) + breeze + _wave(startX + 180, size, speed),
          startX + size.width * 0.62,
          verticalOffset + c + laneDrift + _wave(startX + 240, size, speed),
          startX + size.width * 0.78,
          verticalOffset + breeze + _wave(startX + 320, size, speed),
        );

      canvas.drawPath(path, paint);

      final ghostPaint = Paint()
        ..color = colorA.withValues(alpha: opacity * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawPath(
        path.shift(Offset(-28 - (i * 6), 6 + (i * 2))),
        ghostPaint,
      );
    }
  }

  double _wave(double seed, Size size, double speed) {
    final t = (phase * math.pi * 2 * speed) + (seed / size.width * math.pi * 2);
    return (math.sin(t) * 8) +
        (math.cos(t * 0.63) * 6) +
        (math.sin((t * 1.7) + 1.2) * 3.5);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.mode != mode;
}

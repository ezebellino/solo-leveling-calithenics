import 'dart:math' as math;

import 'package:flutter/material.dart';

class ScreenFrame extends StatefulWidget {
  const ScreenFrame({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.children,
    super.key,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
  final List<Widget> children;

  @override
  State<ScreenFrame> createState() => _ScreenFrameState();
}

class _ScreenFrameState extends State<ScreenFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width < 420 ? 10.0 : 18.0;
            final innerPadding = width < 420 ? 14.0 : 18.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                110,
              ),
              children: [
                CustomPaint(
                  painter: _FramePainter(
                    primary: widget.primary,
                    secondary: widget.secondary,
                    highlight: widget.highlight,
                    phase: _controller.value,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      innerPadding,
                      22,
                      innerPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.phase,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final innerRect = Rect.fromLTWH(15, 44, size.width - 30, size.height - 58);
    final pulse = 0.70 + (math.sin(phase * math.pi * 2) * 0.18);
    final sweepCenter = (size.width * 0.18) + (phase * size.width * 0.64);

    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          secondary.withValues(alpha: 0.48 + (0.10 * pulse)),
          primary.withValues(alpha: 0.88 + (0.12 * pulse)),
          secondary.withValues(alpha: 0.46 + (0.08 * pulse)),
        ],
      ).createShader(outerRect)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = primary.withValues(alpha: 0.10 + (0.06 * pulse))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + (6 * pulse))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(outerRect.inflate(1.5), glowPaint);
    canvas.drawRect(outerRect, borderPaint);

    final innerPaint = Paint()
      ..color = primary.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(innerRect, innerPaint);

    final topBarPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          secondary.withValues(alpha: 0.0),
          primary.withValues(alpha: 0.75),
          highlight.withValues(alpha: 0.95),
          primary.withValues(alpha: 0.75),
          secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.14, 0, size.width * 0.72, 10))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;

    canvas.drawLine(
      Offset(size.width * 0.16, 8),
      Offset(size.width * 0.84, 8),
      topBarPaint,
    );

    final sweepRect = Rect.fromCenter(
      center: Offset(sweepCenter, 8),
      width: size.width * 0.18,
      height: 14,
    );
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          highlight.withValues(alpha: 0.0),
          highlight.withValues(alpha: 0.95),
          highlight.withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
      ).createShader(sweepRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(sweepRect, sweepPaint);

    final topGlowPaint = Paint()
      ..color = highlight.withValues(alpha: 0.18 + (0.10 * pulse))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 + (4 * pulse))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
    canvas.drawLine(
      Offset(size.width * 0.22, 10),
      Offset(size.width * 0.78, 10),
      topGlowPaint,
    );

    _drawFrameCorner(canvas, const Offset(6, 10), top: true, left: true);
    _drawFrameCorner(
      canvas,
      Offset(size.width - 42, 10),
      top: true,
      left: false,
    );
    _drawFrameCorner(
      canvas,
      Offset(6, size.height - 42),
      top: false,
      left: true,
    );
    _drawFrameCorner(
      canvas,
      Offset(size.width - 42, size.height - 42),
      top: false,
      left: false,
    );

    final sideGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primary.withValues(alpha: 0.0),
          primary.withValues(alpha: 0.14 + (0.10 * pulse)),
          primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.16, 8, size.height * 0.68));
    canvas.drawRect(
      Rect.fromLTWH(4, size.height * 0.16, 3, size.height * 0.68),
      sideGlow,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 7, size.height * 0.16, 3, size.height * 0.68),
      sideGlow,
    );
  }

  void _drawFrameCorner(
    Canvas canvas,
    Offset origin, {
    required bool top,
    required bool left,
  }) {
    final width = 36.0;
    final height = 30.0;
    final path = Path()
      ..moveTo(origin.dx + (left ? 0 : width), origin.dy + (top ? height * 0.55 : 0))
      ..lineTo(origin.dx + (left ? 0 : width), origin.dy + (top ? 0 : height))
      ..lineTo(origin.dx + (left ? width * 0.62 : width * 0.38), origin.dy + (top ? 0 : height))
      ..moveTo(origin.dx + (left ? 0 : width), origin.dy + (top ? height * 0.82 : height * 0.18))
      ..lineTo(origin.dx + (left ? width * 0.22 : width * 0.78), origin.dy + (top ? height * 0.82 : height * 0.18))
      ..lineTo(origin.dx + (left ? width * 0.22 : width * 0.78), origin.dy + (top ? height : 0))
      ..moveTo(origin.dx + (left ? width * 0.82 : width * 0.18), origin.dy + (top ? 0 : height))
      ..lineTo(origin.dx + (left ? width * 0.82 : width * 0.18), origin.dy + (top ? height * 0.22 : height * 0.78))
      ..lineTo(origin.dx + (left ? width : 0), origin.dy + (top ? height * 0.22 : height * 0.78));

    final glow = Paint()
      ..color = primary.withValues(alpha: 0.24)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final paint = Paint()
      ..color = primary.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.highlight != highlight ||
      oldDelegate.phase != phase;
}

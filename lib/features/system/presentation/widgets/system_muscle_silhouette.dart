import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/section_palette.dart';
import 'system_muscle_map_models.dart';

class SystemMuscleSilhouettePanel extends StatefulWidget {
  const SystemMuscleSilhouettePanel({
    required this.palette,
    required this.frontZones,
    required this.backZones,
    super.key,
  });

  final SectionPalette palette;
  final List<SystemMuscleZone> frontZones;
  final List<SystemMuscleZone> backZones;

  @override
  State<SystemMuscleSilhouettePanel> createState() =>
      _SystemMuscleSilhouettePanelState();
}

class _SystemMuscleSilhouettePanelState
    extends State<SystemMuscleSilhouettePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _frontOpacity;
  late final Animation<double> _backOpacity;
  late final Animation<double> _frontScale;
  late final Animation<double> _backScale;
  bool _showRevealOverlay = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _frontOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    _backOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.82, curve: Curves.easeOutCubic),
    );
    _frontScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.01)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 74,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.01, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 26,
      ),
    ]).animate(_controller);
    _backScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.96, end: 1.008)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 76,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.008, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 24,
      ),
    ]).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _showRevealOverlay && mounted) {
        setState(() {
          _showRevealOverlay = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FadeTransition(
            key: const Key('system-muscle-front-reveal'),
            opacity: _frontOpacity,
            child: ScaleTransition(
              key: const Key('system-muscle-front-scale'),
              scale: _frontScale,
              child: _SilhouetteCard(
                key: const Key('system-muscle-front'),
                title: 'Vista frontal',
                subtitle: _zoneSummary(widget.frontZones),
                palette: widget.palette,
                zones: widget.frontZones,
                isFront: true,
                showRevealOverlay: _showRevealOverlay,
                revealOverlayKey: const Key('system-muscle-front-reveal-overlay'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FadeTransition(
            key: const Key('system-muscle-back-reveal'),
            opacity: _backOpacity,
            child: ScaleTransition(
              key: const Key('system-muscle-back-scale'),
              scale: _backScale,
              child: _SilhouetteCard(
                key: const Key('system-muscle-back'),
                title: 'Vista dorsal',
                subtitle: _zoneSummary(widget.backZones),
                palette: widget.palette,
                zones: widget.backZones,
                isFront: false,
                showRevealOverlay: _showRevealOverlay,
                revealOverlayKey: const Key('system-muscle-back-reveal-overlay'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _zoneSummary(List<SystemMuscleZone> zones) {
    final count = zones.toSet().length;
    if (count == 1) {
      return '1 zona activa';
    }
    return '$count zonas activas';
  }
}

class _SilhouetteCard extends StatelessWidget {
  const _SilhouetteCard({
    required super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.zones,
    required this.isFront,
    required this.showRevealOverlay,
    required this.revealOverlayKey,
  });

  final String title;
  final String subtitle;
  final SectionPalette palette;
  final List<SystemMuscleZone> zones;
  final bool isFront;
  final bool showRevealOverlay;
  final Key revealOverlayKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF07111A).withValues(alpha: 0.92),
            const Color(0xFF0B1822).withValues(alpha: 0.78),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.secondary,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 0.92,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.35),
                          radius: 1.05,
                          colors: [
                            palette.primary.withValues(alpha: 0.14),
                            palette.secondary.withValues(alpha: 0.10),
                            const Color(0xFF050B11),
                          ],
                          stops: const [0.0, 0.38, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SystemSilhouettePainter(
                        palette: palette,
                        zones: zones,
                        isFront: isFront,
                      ),
                    ),
                  ),
                  if (showRevealOverlay)
                    Positioned.fill(
                      key: revealOverlayKey,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                palette.highlight.withValues(alpha: 0.12),
                                palette.primary.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.32, 0.78],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemSilhouettePainter extends CustomPainter {
  const _SystemSilhouettePainter({
    required this.palette,
    required this.zones,
    required this.isFront,
  });

  final SectionPalette palette;
  final List<SystemMuscleZone> zones;
  final bool isFront;

  static final Map<SystemMuscleZone, _ZonePathDefinition> _zoneDefinitions = {
    SystemMuscleZone.chest: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedOval(
        y: 0.30,
        xOffset: 0.09,
        width: 0.13,
        height: 0.09,
      ),
    ),
    SystemMuscleZone.shoulders: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedOval(
        y: 0.24,
        xOffset: 0.16,
        width: 0.12,
        height: 0.08,
      ),
      back: _ZoneShapeSpec.pairedOval(
        y: 0.24,
        xOffset: 0.16,
        width: 0.12,
        height: 0.08,
      ),
    ),
    SystemMuscleZone.triceps: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.34,
        xOffset: 0.20,
        width: 0.07,
        height: 0.16,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.34,
        xOffset: 0.20,
        width: 0.07,
        height: 0.16,
      ),
    ),
    SystemMuscleZone.back: const _ZonePathDefinition(
      back: _ZoneShapeSpec.pairedOval(
        y: 0.33,
        xOffset: 0.08,
        width: 0.15,
        height: 0.16,
      ),
    ),
    SystemMuscleZone.biceps: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.34,
        xOffset: 0.17,
        width: 0.08,
        height: 0.14,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.34,
        xOffset: 0.17,
        width: 0.06,
        height: 0.12,
      ),
    ),
    SystemMuscleZone.forearms: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.53,
        xOffset: 0.20,
        width: 0.06,
        height: 0.16,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.53,
        xOffset: 0.20,
        width: 0.06,
        height: 0.16,
      ),
    ),
    SystemMuscleZone.wrists: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedOval(
        y: 0.63,
        xOffset: 0.21,
        width: 0.05,
        height: 0.04,
      ),
      back: _ZoneShapeSpec.pairedOval(
        y: 0.63,
        xOffset: 0.21,
        width: 0.05,
        height: 0.04,
      ),
    ),
    SystemMuscleZone.quadriceps: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.73,
        xOffset: 0.07,
        width: 0.09,
        height: 0.20,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.73,
        xOffset: 0.07,
        width: 0.07,
        height: 0.14,
      ),
    ),
    SystemMuscleZone.glutes: const _ZonePathDefinition(
      back: _ZoneShapeSpec.pairedOval(
        y: 0.59,
        xOffset: 0.07,
        width: 0.11,
        height: 0.10,
      ),
    ),
    SystemMuscleZone.hamstrings: const _ZonePathDefinition(
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.75,
        xOffset: 0.07,
        width: 0.08,
        height: 0.18,
      ),
    ),
    SystemMuscleZone.calves: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.90,
        xOffset: 0.07,
        width: 0.07,
        height: 0.12,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.90,
        xOffset: 0.07,
        width: 0.07,
        height: 0.12,
      ),
    ),
    SystemMuscleZone.core: const _ZonePathDefinition(
      front: _ZoneShapeSpec.singleCapsule(
        x: 0.50,
        y: 0.45,
        width: 0.16,
        height: 0.22,
      ),
      back: _ZoneShapeSpec.singleCapsule(
        x: 0.50,
        y: 0.45,
        width: 0.16,
        height: 0.22,
      ),
    ),
    SystemMuscleZone.obliques: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedCapsule(
        y: 0.46,
        xOffset: 0.09,
        width: 0.06,
        height: 0.17,
      ),
      back: _ZoneShapeSpec.pairedCapsule(
        y: 0.46,
        xOffset: 0.09,
        width: 0.06,
        height: 0.17,
      ),
    ),
    SystemMuscleZone.lowerBack: const _ZonePathDefinition(
      back: _ZoneShapeSpec.singleCapsule(
        x: 0.50,
        y: 0.55,
        width: 0.14,
        height: 0.12,
      ),
    ),
    SystemMuscleZone.hips: const _ZonePathDefinition(
      front: _ZoneShapeSpec.pairedOval(
        y: 0.57,
        xOffset: 0.10,
        width: 0.08,
        height: 0.07,
      ),
      back: _ZoneShapeSpec.pairedOval(
        y: 0.57,
        xOffset: 0.10,
        width: 0.08,
        height: 0.07,
      ),
    ),
  };

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackdrop(canvas, size);

    final outline = _buildOutline(size);
    final outlineRect = outline.getBounds();

    final bodyFill = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFF0D1A26),
          Color(0xFF102435),
          Color(0xFF0B1620),
        ],
        stops: const [0.0, 0.42, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(outlineRect);
    canvas.drawPath(outline, bodyFill);

    final silhouetteGlow = Paint()
      ..color = palette.primary.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawPath(outline, silhouetteGlow);

    for (final zone in zones.toSet()) {
      final zonePath = _zonePath(zone, size);
      if (zonePath == null) {
        continue;
      }

      final zoneRect = zonePath.getBounds();
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            palette.highlight.withValues(alpha: 0.82),
            palette.primary.withValues(alpha: 0.54),
            palette.secondary.withValues(alpha: 0.22),
            Colors.transparent,
          ],
          stops: const [0.0, 0.36, 0.72, 1.0],
        ).createShader(zoneRect.inflate(10))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      final fill = Paint()
        ..shader = LinearGradient(
          colors: [
            palette.highlight.withValues(alpha: 0.82),
            palette.primary.withValues(alpha: 0.62),
            palette.secondary.withValues(alpha: 0.42),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(zoneRect);
      canvas.drawPath(zonePath, glow);
      canvas.drawPath(zonePath, fill);
    }

    _paintAnatomyLines(canvas, size);

    final outlineStroke = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.primary.withValues(alpha: 0.82),
          palette.highlight.withValues(alpha: 0.44),
          palette.secondary.withValues(alpha: 0.68),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(outlineRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(outline, outlineStroke);
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(18),
    );
    canvas.drawRRect(frame, framePaint);

    final centerX = size.width / 2;
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.primary.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(centerX, size.height * 0.1),
      Offset(centerX, size.height * 0.92),
      sweepPaint,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final dy = size.height * (0.22 + (i * 0.18));
      canvas.drawLine(
        Offset(size.width * 0.18, dy),
        Offset(size.width * 0.82, dy),
        gridPaint,
      );
    }
  }

  Path _buildOutline(Size size) {
    final centerX = size.width / 2;
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(centerX, size.height * 0.14),
          width: size.width * 0.18,
          height: size.height * 0.13,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, size.height * 0.36),
            width: size.width * 0.23,
            height: size.height * 0.32,
          ),
          Radius.circular(size.width * 0.09),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, size.height * 0.59),
            width: size.width * 0.17,
            height: size.height * 0.18,
          ),
          Radius.circular(size.width * 0.08),
        ),
      );

    path.addPath(
      _pairedLimbPath(
        size,
        y: 0.30,
        width: 0.11,
        height: 0.24,
        xOffset: 0.18,
      ),
      Offset.zero,
    );
    path.addPath(
      _pairedLimbPath(
        size,
        y: 0.50,
        width: 0.09,
        height: 0.22,
        xOffset: 0.19,
      ),
      Offset.zero,
    );
    path.addPath(
      _pairedLimbPath(
        size,
        y: 0.73,
        width: 0.12,
        height: 0.28,
        xOffset: 0.10,
      ),
      Offset.zero,
    );
    path.addPath(
      _pairedLimbPath(
        size,
        y: 0.90,
        width: 0.09,
        height: 0.12,
        xOffset: 0.10,
      ),
      Offset.zero,
    );

    return path;
  }

  void _paintAnatomyLines(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final torsoPath = Path()
      ..moveTo(centerX, size.height * 0.24)
      ..lineTo(centerX, size.height * 0.66)
      ..moveTo(size.width * 0.35, size.height * 0.31)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.28,
        size.width * 0.65,
        size.height * 0.31,
      )
      ..moveTo(size.width * 0.38, size.height * 0.45)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.42,
        size.width * 0.62,
        size.height * 0.45,
      )
      ..moveTo(size.width * 0.42, size.height * 0.58)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.56,
        size.width * 0.58,
        size.height * 0.58,
      );

    if (!isFront) {
      torsoPath
        ..moveTo(size.width * 0.40, size.height * 0.35)
        ..quadraticBezierTo(
          centerX,
          size.height * 0.39,
          size.width * 0.60,
          size.height * 0.35,
        )
        ..moveTo(size.width * 0.44, size.height * 0.53)
        ..quadraticBezierTo(
          centerX,
          size.height * 0.57,
          size.width * 0.56,
          size.height * 0.53,
        );
    }

    canvas.drawPath(torsoPath, linePaint);
  }

  Path? _zonePath(SystemMuscleZone zone, Size size) {
    final definition = _zoneDefinitions[zone];
    if (definition == null) {
      return null;
    }
    final spec = isFront ? definition.front : definition.back;
    return spec?.build(size);
  }

  Path _pairedLimbPath(
    Size size, {
    required double y,
    required double width,
    required double height,
    required double xOffset,
  }) {
    final path = Path();
    final centers = [0.5 - xOffset, 0.5 + xOffset];
    for (final x in centers) {
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * x, size.height * y),
            width: size.width * width,
            height: size.height * height,
          ),
          Radius.circular(size.width * width * 0.45),
        ),
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _SystemSilhouettePainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.isFront != isFront ||
        !_sameZones(oldDelegate.zones, zones);
  }

  bool _sameZones(List<SystemMuscleZone> a, List<SystemMuscleZone> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

class _ZonePathDefinition {
  const _ZonePathDefinition({
    this.front,
    this.back,
  });

  final _ZoneShapeSpec? front;
  final _ZoneShapeSpec? back;
}

enum _ZoneShapeKind {
  pairedOval,
  pairedCapsule,
  singleCapsule,
}

class _ZoneShapeSpec {
  const _ZoneShapeSpec._({
    required this.kind,
    required this.x,
    required this.y,
    required this.xOffset,
    required this.width,
    required this.height,
  });

  const _ZoneShapeSpec.pairedOval({
    required double y,
    required double xOffset,
    required double width,
    required double height,
  }) : this._(
          kind: _ZoneShapeKind.pairedOval,
          x: 0.5,
          y: y,
          xOffset: xOffset,
          width: width,
          height: height,
        );

  const _ZoneShapeSpec.pairedCapsule({
    required double y,
    required double xOffset,
    required double width,
    required double height,
  }) : this._(
          kind: _ZoneShapeKind.pairedCapsule,
          x: 0.5,
          y: y,
          xOffset: xOffset,
          width: width,
          height: height,
        );

  const _ZoneShapeSpec.singleCapsule({
    required double x,
    required double y,
    required double width,
    required double height,
  }) : this._(
          kind: _ZoneShapeKind.singleCapsule,
          x: x,
          y: y,
          xOffset: 0,
          width: width,
          height: height,
        );

  final _ZoneShapeKind kind;
  final double x;
  final double y;
  final double xOffset;
  final double width;
  final double height;

  Path build(Size size) {
    switch (kind) {
      case _ZoneShapeKind.pairedOval:
        return _buildPairedOval(size);
      case _ZoneShapeKind.pairedCapsule:
        return _buildPairedCapsule(size);
      case _ZoneShapeKind.singleCapsule:
        return _buildSingleCapsule(size);
    }
  }

  Path _buildPairedOval(Size size) {
    final path = Path();
    final centers = [0.5 - xOffset, 0.5 + xOffset];
    for (final centerX in centers) {
      path.addOval(
        Rect.fromCenter(
          center: Offset(size.width * centerX, size.height * y),
          width: size.width * width,
          height: size.height * height,
        ),
      );
    }
    return path;
  }

  Path _buildPairedCapsule(Size size) {
    final path = Path();
    final centers = [0.5 - xOffset, 0.5 + xOffset];
    for (final centerX in centers) {
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * centerX, size.height * y),
            width: size.width * width,
            height: size.height * height,
          ),
          Radius.circular(size.width * math.min(width, height) * 0.60),
        ),
      );
    }
    return path;
  }

  Path _buildSingleCapsule(Size size) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * x, size.height * y),
            width: size.width * width,
            height: size.height * height,
          ),
          Radius.circular(size.width * math.min(width, height) * 0.75),
        ),
      );
  }
}

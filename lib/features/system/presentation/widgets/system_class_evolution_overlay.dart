import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/section_palette.dart';

class SystemClassEvolutionOverlay extends StatefulWidget {
  const SystemClassEvolutionOverlay({
    required this.previousClass,
    required this.nextClass,
    required this.palette,
    this.onDismiss,
    super.key,
  });

  final String previousClass;
  final String nextClass;
  final SectionPalette palette;
  final VoidCallback? onDismiss;

  @override
  State<SystemClassEvolutionOverlay> createState() =>
      _SystemClassEvolutionOverlayState();
}

class _SystemClassEvolutionOverlayState
    extends State<SystemClassEvolutionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1850),
  )..forward();

  late final Animation<double> _previousOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.34, curve: Curves.easeOut),
  );

  late final Animation<double> _glyphScale = Tween<double>(
    begin: 0.84,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.68, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _glyphGlow = Tween<double>(
    begin: 0.18,
    end: 0.42,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.74, curve: Curves.easeInOut),
    ),
  );

  late final Animation<Offset> _nextSlide = Tween<Offset>(
    begin: const Offset(0, 0.16),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.46, 1.0, curve: Curves.easeOutCubic),
    ),
  );

  late final Animation<double> _nextOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.46, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: HolographicPanel(
        glowColor: widget.palette.primary,
        borderRadius: 30,
        padding: EdgeInsets.zero,
        showCorners: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.72),
                          radius: 1.05,
                          colors: [
                            widget.palette.primary.withValues(alpha: 0.22),
                            widget.palette.secondary.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.34, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 20,
                  height: 96,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            widget.palette.primary.withValues(alpha: 0.10),
                            widget.palette.secondary.withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: widget.palette.primary.withValues(
                                alpha: 0.34,
                              ),
                            ),
                            color: Colors.black.withValues(alpha: 0.18),
                          ),
                          child: Text(
                            'ASIGNACION DE CLASE',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: widget.palette.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'El Sistema reevalua tu condicion actual.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: ReverseAnimation(_previousOpacity),
                          child: _ClassPlate(
                            label: 'CLASE ANTERIOR',
                            value: widget.previousClass,
                            accent: widget.palette.primary.withValues(
                              alpha: 0.72,
                            ),
                            textStyle: theme.textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Transform.scale(
                          scale: _glyphScale.value,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.palette.secondary.withValues(
                                  alpha: 0.46,
                                ),
                              ),
                              gradient: RadialGradient(
                                colors: [
                                  widget.palette.secondary.withValues(
                                    alpha: _glyphGlow.value,
                                  ),
                                  widget.palette.primary.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.42, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.palette.secondary.withValues(
                                    alpha: _glyphGlow.value,
                                  ),
                                  blurRadius: 26,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 34,
                              color: widget.palette.highlight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: _nextOpacity,
                          child: SlideTransition(
                            position: _nextSlide,
                            child: _ClassPlate(
                              label: 'NUEVA CLASE',
                              value: widget.nextClass,
                              accent: widget.palette.secondary,
                              textStyle: theme.textTheme.headlineSmall,
                              emphasize: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'El Sistema confirma tu mejora y habilita una nueva etapa de crecimiento.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.4,
                          ),
                        ),
                        if (widget.onDismiss != null) ...[
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: widget.onDismiss,
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.palette.primary.withValues(
                                alpha: 0.14,
                              ),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(190, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: widget.palette.secondary.withValues(
                                    alpha: 0.34,
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              'CONTINUAR',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClassPlate extends StatelessWidget {
  const _ClassPlate({
    required this.label,
    required this.value,
    required this.accent,
    required this.textStyle,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color accent;
  final TextStyle? textStyle;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: emphasize ? 0.44 : 0.28),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.04),
            accent.withValues(alpha: emphasize ? 0.08 : 0.04),
            Colors.black.withValues(alpha: 0.10),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: emphasize
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: textStyle?.copyWith(
              color: Colors.white,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              height: 1.05,
              shadows: emphasize
                  ? [
                      Shadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';

class ShadowUnlockOverlay extends StatefulWidget {
  const ShadowUnlockOverlay({
    required this.shadow,
    required this.palette,
    required this.onDismiss,
    super.key,
  });

  final ShadowEntity shadow;
  final SectionPalette palette;
  final VoidCallback? onDismiss;

  @override
  State<ShadowUnlockOverlay> createState() => _ShadowUnlockOverlayState();
}

class _ShadowUnlockOverlayState extends State<ShadowUnlockOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );
    _pulseAnimation = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadow = widget.shadow;
    final palette = widget.palette;
    final accent = _colorFromHex(shadow.borderTheme.accentHex, palette.highlight);
    final border = _colorFromHex(shadow.borderTheme.secondaryHex, palette.secondary);
    final glow = _colorFromHex(shadow.borderTheme.primaryHex, palette.primary);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.28),
                  blurRadius: 34,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: border.withValues(alpha: 0.72),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0C1823).withValues(alpha: 0.97),
                      const Color(0xFF08111A).withValues(alpha: 0.99),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.8),
                              radius: 1.2,
                              colors: [
                                palette.primary.withValues(alpha: 0.26),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                accent.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.52, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 420;
                          final preview = _PreviewCard(
                            shadow: shadow,
                            palette: palette,
                            accent: accent,
                            border: border,
                            pulseAnimation: _pulseAnimation,
                          );
                          final details = _OverlayDetails(
                            shadow: shadow,
                            palette: palette,
                            accent: accent,
                            theme: theme,
                            onDismiss: widget.onDismiss,
                          );

                          if (stacked) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(width: 132, child: preview),
                                ),
                                const SizedBox(height: 18),
                                details,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: details),
                              const SizedBox(width: 18),
                              SizedBox(width: 132, child: preview),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayDetails extends StatelessWidget {
  const _OverlayDetails({
    required this.shadow,
    required this.palette,
    required this.accent,
    required this.theme,
    required this.onDismiss,
  });

  final ShadowEntity shadow;
  final SectionPalette palette;
  final Color accent;
  final ThemeData theme;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.highlight.withValues(alpha: 0.34)),
            color: Colors.black.withValues(alpha: 0.24),
          ),
          child: Text(
            'Nueva sombra obtenida',
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.highlight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          shadow.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          shadow.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          shadow.flavorText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            height: 1.45,
          ),
        ),
        if (onDismiss != null) ...[
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onDismiss,
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary.withValues(alpha: 0.18),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: palette.highlight.withValues(alpha: 0.36),
                ),
              ),
            ),
            child: Text(
              'CONTINUAR',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.shadow,
    required this.palette,
    required this.accent,
    required this.border,
    required this.pulseAnimation,
  });

  final ShadowEntity shadow;
  final SectionPalette palette;
  final Color accent;
  final Color border;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: -10,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  shadow.assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            palette.primary.withValues(alpha: 0.24),
                            const Color(0xFF071019),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            shadow.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.06),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        stops: const [0.0, 0.35, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        shadow.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _colorFromHex(String value, Color fallback) {
  final normalized = value.replaceFirst('#', '');
  if (normalized.length != 6) {
    return fallback;
  }
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    return fallback;
  }
  return Color(0xFF000000 | parsed);
}

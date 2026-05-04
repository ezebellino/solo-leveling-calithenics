import 'package:flutter/material.dart';

import 'holographic_panel.dart';

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    required this.level,
    required this.primary,
    required this.secondary,
    this.onDismiss,
    super.key,
  });

  final int level;
  final Color primary;
  final Color secondary;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: HolographicPanel(
        glowColor: primary,
        padding: EdgeInsets.zero,
        borderRadius: 30,
        showCorners: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.75),
                      radius: 1.05,
                      colors: [
                        primary.withValues(alpha: 0.20),
                        secondary.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.38, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 18,
              height: 88,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primary.withValues(alpha: 0.10),
                        secondary.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.30, 0.60, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 52),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          secondary.withValues(alpha: 0.12),
                          secondary.withValues(alpha: 0.50),
                          secondary.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.20),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
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
                        color: primary.withValues(alpha: 0.34),
                      ),
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                    child: Text(
                      'NOTIFICACION',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Subiste de nivel',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      shadows: [
                        Shadow(
                          color: primary.withValues(alpha: 0.18),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: secondary.withValues(alpha: 0.34),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          secondary.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Lv. $level',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: secondary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                            height: 0.96,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'El Sistema reconoce tu crecimiento.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onDismiss,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: secondary.withValues(alpha: 0.32),
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
          ],
        ),
      ),
    );
  }
}

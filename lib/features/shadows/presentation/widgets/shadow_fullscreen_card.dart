import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import 'shadow_visual_identity.dart';

class ShadowFullscreenCard extends StatelessWidget {
  const ShadowFullscreenCard({
    required this.shadow,
    required this.isUnlocked,
    required this.palette,
    super.key,
  });

  final ShadowEntity shadow;
  final bool isUnlocked;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = ShadowVisualIdentity.resolve(shadow: shadow, fallback: palette);
    final frameRadius = BorderRadius.circular(28);

    return Dialog.fullscreen(
      backgroundColor: const Color(0xF4091017),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? RadialGradient(
                          center: const Alignment(0, -0.22),
                          radius: 1.12,
                          colors: [
                            identity.glowColor.withValues(alpha: identity.glowOpacity),
                            const Color(0xF4091017),
                          ],
                        )
                      : RadialGradient(
                          center: const Alignment(0, -0.2),
                          radius: 1.08,
                          colors: [
                            palette.primary.withValues(alpha: 0.08),
                            const Color(0xF4091017),
                          ],
                        ),
                ),
              ),
            ),
            if (isUnlocked) ...[
              Positioned(
                top: 72,
                right: -32,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: identity.glowColor.withValues(alpha: 0.36),
                          blurRadius: 88,
                          spreadRadius: 22,
                        ),
                      ],
                    ),
                    child: const SizedBox(width: 180, height: 180),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 64,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          identity.smokeColor.withValues(alpha: 0.0),
                          identity.smokeColor.withValues(alpha: 0.24),
                          identity.smokeColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: const SizedBox(height: 120),
                  ),
                ),
              ),
            ],
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shadow.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isUnlocked) ...[
                              const SizedBox(height: 4),
                              Text(
                                shadow.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: identity.accentColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ] else
                              const SizedBox(height: 10),
                            Text(
                              isUnlocked ? shadow.flavorText : shadow.unlockHint,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isUnlocked ? Colors.white70 : Colors.white60,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    child: InteractiveViewer(
                      minScale: 0.9,
                      maxScale: 2.2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: frameRadius,
                          border: Border.all(
                            color: isUnlocked
                                ? identity.frameColor.withValues(alpha: 0.88)
                                : Colors.white24,
                            width: isUnlocked ? identity.borderWidth : 1.2,
                          ),
                          gradient: LinearGradient(
                            colors: isUnlocked
                                ? [
                                    identity.surfaceTop,
                                    identity.surfaceMid,
                                    identity.surfaceBottom,
                                  ]
                                : const [
                                    Color(0xFF0A1118),
                                    Color(0xFF05090F),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isUnlocked ? identity.glowColor : Colors.black).withValues(
                                alpha: isUnlocked ? 0.28 : 0.22,
                              ),
                              blurRadius: isUnlocked ? 44 : 20,
                              spreadRadius: isUnlocked ? -6 : -10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: frameRadius,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                shadow.assetPath,
                                fit: BoxFit.contain,
                                color: isUnlocked ? null : Colors.black.withValues(alpha: 0.72),
                                colorBlendMode: isUnlocked ? null : BlendMode.darken,
                                errorBuilder: (context, error, stackTrace) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: frameRadius,
                                      gradient: LinearGradient(
                                        colors: [
                                          identity.glowColor.withValues(
                                            alpha: isUnlocked ? 0.2 : 0.08,
                                          ),
                                          const Color(0xFF060C12),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(28),
                                        child: Text(
                                          shadow.name,
                                          style: theme.textTheme.displaySmall?.copyWith(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w900,
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
                                    borderRadius: frameRadius,
                                    gradient: LinearGradient(
                                      colors: [
                                        if (isUnlocked)
                                          identity.glowColor.withValues(alpha: 0.12)
                                        else
                                          Colors.black.withValues(alpha: 0.12),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: isUnlocked ? 0.36 : 0.58),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isUnlocked)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      shadow.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

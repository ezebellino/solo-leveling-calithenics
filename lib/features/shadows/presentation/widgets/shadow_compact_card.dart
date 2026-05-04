import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import 'shadow_visual_identity.dart';

class ShadowCompactCard extends StatelessWidget {
  const ShadowCompactCard({
    required this.shadow,
    required this.isUnlocked,
    required this.palette,
    required this.onTap,
    super.key,
  });

  final ShadowEntity shadow;
  final bool isUnlocked;
  final SectionPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final identity = ShadowVisualIdentity.resolve(shadow: shadow, fallback: palette);
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: isUnlocked
                  ? identity.frameColor.withValues(alpha: 0.92)
                  : Colors.white24,
              width: isUnlocked ? identity.borderWidth : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUnlocked ? identity.glowColor : Colors.black).withValues(
                  alpha: isUnlocked ? identity.glowOpacity : 0.22,
                ),
                blurRadius: isUnlocked ? 28 : 18,
                spreadRadius: isUnlocked ? -4 : -10,
              ),
            ],
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      identity.surfaceTop,
                      identity.surfaceMid,
                      identity.surfaceBottom,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF0B1621).withValues(alpha: 0.96),
                      const Color(0xFF050A10).withValues(alpha: 0.98),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: borderRadius,
                  child: Image.asset(
                    shadow.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    color: isUnlocked ? null : Colors.black.withValues(alpha: 0.7),
                    colorBlendMode: isUnlocked ? null : BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              identity.glowColor.withValues(alpha: isUnlocked ? 0.22 : 0.08),
                              const Color(0xFF061018),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            shadow.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isUnlocked) ...[
                  Positioned(
                    top: -18,
                    right: -10,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: identity.glowColor.withValues(alpha: identity.glowOpacity),
                              blurRadius: 42,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const SizedBox(width: 108, height: 108),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -18,
                    right: -18,
                    bottom: 56,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              identity.smokeColor.withValues(alpha: 0.0),
                              identity.smokeColor.withValues(alpha: 0.22),
                              identity.smokeColor.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const SizedBox(height: 88),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: RadialGradient(
                          center: const Alignment(0.45, -0.6),
                          radius: 1.05,
                          colors: [
                            identity.glowColor.withValues(alpha: 0.24),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        colors: [
                          if (isUnlocked)
                            identity.glowColor.withValues(alpha: 0.08)
                          else
                            Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: isUnlocked ? 0.88 : 0.94),
                        ],
                        stops: const [0.0, 0.48, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 14,
                  child: isUnlocked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 3,
                              width: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  colors: [
                                    identity.frameColor.withValues(alpha: 0.0),
                                    identity.frameColor,
                                    identity.accentColor.withValues(alpha: 0.82),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: identity.glowColor.withValues(alpha: 0.32),
                                    blurRadius: 14,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              shadow.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shadow.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: identity.accentColor.withValues(alpha: 0.88),
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              shadow.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shadow.unlockHint,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                                height: 1.35,
                              ),
                            ),
                          ],
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

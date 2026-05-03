import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';

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
    final badgeColor = isUnlocked ? palette.secondary : Colors.white54;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isUnlocked ? palette.primary : Colors.white30).withValues(alpha: 0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: (isUnlocked ? palette.primary : Colors.black).withValues(alpha: 0.18),
                blurRadius: 22,
                spreadRadius: -8,
              ),
            ],
            gradient: LinearGradient(
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
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    shadow.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    color: isUnlocked ? null : Colors.black.withValues(alpha: 0.58),
                    colorBlendMode: isUnlocked ? null : BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              palette.primary.withValues(alpha: 0.18),
                              const Color(0xFF061018),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            shadow.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.06),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                        stops: const [0.0, 0.52, 1.0],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.75)),
                          color: Colors.black.withValues(alpha: 0.34),
                        ),
                        child: Text(
                          isUnlocked ? 'Obtenida' : 'Bloqueada',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shadow.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUnlocked ? shadow.title : shadow.unlockHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnlocked ? Colors.white70 : Colors.white60,
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

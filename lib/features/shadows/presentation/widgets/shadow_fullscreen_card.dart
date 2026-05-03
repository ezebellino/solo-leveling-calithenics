import 'package:flutter/material.dart';

import '../../domain/shadow_entity.dart';
import '../../../home/presentation/widgets/section_palette.dart';

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

    return Dialog.fullscreen(
      backgroundColor: const Color(0xF4091017),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.08,
                    colors: [
                      palette.primary.withValues(alpha: 0.18),
                      const Color(0xF4091017),
                    ],
                  ),
                ),
              ),
            ),
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
                            const SizedBox(height: 4),
                            Text(
                              shadow.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: palette.secondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isUnlocked ? shadow.flavorText : shadow.unlockHint,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          shadow.assetPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: palette.primary.withValues(alpha: 0.7)),
                                gradient: LinearGradient(
                                  colors: [
                                    palette.primary.withValues(alpha: 0.18),
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
                      ),
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

import 'package:flutter/material.dart';

import '../../domain/shadow_catalog.dart';
import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../../home/presentation/widgets/system_badge.dart';
import 'shadow_compact_card.dart';
import 'shadow_fullscreen_card.dart';

class ShadowsGalleryPanel extends StatelessWidget {
  const ShadowsGalleryPanel({
    required this.unlockedShadowIds,
    required this.lastUnlockedShadowId,
    required this.palette,
    super.key,
  });

  final List<String> unlockedShadowIds;
  final String lastUnlockedShadowId;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = ShadowCatalog.initialRoster;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 980
        ? 3
        : width >= 620
            ? 2
            : 1;

    ShadowCatalogEntry? lastUnlockedEntry;
    for (final entry in entries) {
      if (entry.shadow.id == lastUnlockedShadowId) {
        lastUnlockedEntry = entry;
        break;
      }
    }
    final lastUnlocked = lastUnlockedEntry?.shadow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SystemBadge(label: 'Inventario de sombras', glowColor: palette.primary),
        const SizedBox(height: 14),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${unlockedShadowIds.length} / ${entries.length} Sombras obtenidas',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lastUnlocked == null
                    ? 'El Sistema todavia no te ha concedido una sombra. Las primeras aparecen con disciplina sostenida.'
                    : 'Ultima sombra obtenida: ${lastUnlocked.name}. Toca cualquier carta para abrir su version completa.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: crossAxisCount == 1 ? 1.08 : 0.72,
                ),
                itemBuilder: (context, index) {
                  final shadow = entries[index].shadow;
                  final isUnlocked = unlockedShadowIds.contains(shadow.id);

                  return ShadowCompactCard(
                    shadow: shadow,
                    isUnlocked: isUnlocked,
                    palette: palette,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.86),
                        builder: (_) => ShadowFullscreenCard(
                          shadow: shadow,
                          isUnlocked: isUnlocked,
                          palette: palette,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

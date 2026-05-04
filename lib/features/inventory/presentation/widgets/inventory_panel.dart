import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../application/inventory_controller.dart';
import '../widgets/inventory_tile.dart';

class InventoryPanel extends ConsumerWidget {
  const InventoryPanel({
    required this.title,
    required this.inventory,
    required this.xpBoostArmed,
    required this.palette,
    this.showRerollAction = false,
    this.showXpBoostAction = true,
    this.xpBoostCtaLabel = 'Usar XP Boost',
    this.onResetProgress,
    super.key,
  });

  final String title;
  final Map<String, int> inventory;
  final bool xpBoostArmed;
  final SectionPalette palette;
  final bool showRerollAction;
  final bool showXpBoostAction;
  final String xpBoostCtaLabel;
  final VoidCallback? onResetProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);
    final actions = ref.read(inventoryControllerProvider.notifier);

    return HolographicPanel(
      glowColor: palette.primary,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decorate: false,
      showCorners: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final compact = constraints.maxWidth < 420;
          final xpBoostBusy =
              state.isSubmitting &&
              state.activeActionKey == 'inventory:xp_boost';
          final rerollBusy =
              state.isSubmitting && state.activeActionKey == 'inventory:reroll';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 20) / 3,
                    child: InventoryTile(
                      label: 'Freeze',
                      value: '${inventory['freeze'] ?? 0}',
                      accent: palette.primary,
                    ),
                  ),
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 20) / 3,
                    child: InventoryTile(
                      label: 'XP Boost',
                      value: xpBoostArmed
                          ? 'Activo'
                          : '${inventory['xp_boost'] ?? 0}',
                      accent: palette.secondary,
                    ),
                  ),
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 20) / 3,
                    child: InventoryTile(
                      label: 'Re-roll',
                      value: '${inventory['reroll'] ?? 0}',
                      accent: palette.primary,
                    ),
                  ),
                ],
              ),
              if (showXpBoostAction || showRerollAction || onResetProgress != null)
                const SizedBox(height: 14),
              if (compact)
                Column(
                  children: [
                    if (showXpBoostAction) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: xpBoostArmed || state.isSubmitting
                              ? null
                              : actions.useXpBoost,
                          child: Text(
                            xpBoostBusy ? 'Procesando...' : xpBoostCtaLabel,
                          ),
                        ),
                      ),
                      if (showRerollAction || onResetProgress != null)
                        const SizedBox(height: 10),
                    ],
                    if (showRerollAction) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: state.isSubmitting ? null : actions.useReroll,
                          child: Text(
                            rerollBusy ? 'Procesando...' : 'Usar Re-roll',
                          ),
                        ),
                      ),
                      if (onResetProgress != null) const SizedBox(height: 10),
                    ],
                    if (onResetProgress != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onResetProgress,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7D7D),
                            side: const BorderSide(color: Color(0x66FF7D7D)),
                          ),
                          child: const Text('Reset progreso'),
                        ),
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    if (showXpBoostAction)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: xpBoostArmed || state.isSubmitting
                              ? null
                              : actions.useXpBoost,
                          child: Text(
                            xpBoostBusy ? 'Procesando...' : xpBoostCtaLabel,
                          ),
                        ),
                      ),
                    if (showXpBoostAction && showRerollAction)
                      const SizedBox(width: 12),
                    if (showRerollAction)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSubmitting ? null : actions.useReroll,
                          child: Text(
                            rerollBusy ? 'Procesando...' : 'Usar Re-roll',
                          ),
                        ),
                      ),
                    if ((showXpBoostAction || showRerollAction) &&
                        onResetProgress != null)
                      const SizedBox(width: 12),
                    if (onResetProgress != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onResetProgress,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7D7D),
                            side: const BorderSide(color: Color(0x66FF7D7D)),
                          ),
                          child: const Text('Reset progreso'),
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

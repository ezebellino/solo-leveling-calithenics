import 'package:flutter/material.dart';

import '../../../home/domain/hunter_profile.dart';
import '../../../home/domain/training_path.dart';
import '../../../shadows/presentation/widgets/shadows_gallery_panel.dart';
import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/screen_frame.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../../home/presentation/widgets/stat_hex_tile.dart';
import '../../../home/presentation/widgets/system_badge.dart';
import '../../../home/presentation/widgets/training_widgets.dart';

class PlayerStatsTab extends StatelessWidget {
  const PlayerStatsTab({
    required this.profile,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.unlockedShadowIds,
    required this.lastUnlockedShadowId,
    required this.palette,
    super.key,
  });

  final HunterProfile profile;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final List<String> unlockedShadowIds;
  final String lastUnlockedShadowId;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenFrame(
      primary: palette.primary,
      secondary: palette.secondary,
      highlight: palette.highlight,
      children: [
        SystemBadge(label: 'Ventana de stats', glowColor: palette.primary),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
          cornerInset: 8,
          cornerSize: 18,
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROTOCOLO SHADOW MONARCH',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.secondary,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 18),
              StatBar(label: 'Fuerza', value: profile.strength, max: 30, palette: palette),
              StatBar(label: 'Agilidad', value: profile.agility, max: 30, palette: palette),
              StatBar(label: 'Resistencia', value: profile.endurance, max: 30, palette: palette),
              StatBar(label: 'Disciplina', value: profile.discipline, max: 30, palette: palette),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: StatHexTile(
                label: 'Nivel',
                value: '${profile.level}',
                icon: Icons.stacked_line_chart_rounded,
                accent: palette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatHexTile(
                label: 'Rango',
                value: profile.rank,
                icon: Icons.workspace_premium_rounded,
                accent: palette.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decorate: false,
          showCorners: false,
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              MiniMetric(
                label: 'Etapa activa',
                value: trainingPath.stages[selectedStageIndex].title,
                accent: palette.primary,
              ),
              MiniMetric(
                label: 'Ganancia',
                value: '+3 puntos por nivel',
                accent: palette.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REGLAS DE PROGRESION',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.secondary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 14),
              ...trainingPath.rules.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProgressRuleTile(rule: rule, palette: palette),
                ),
              ),
              ProgressRuleTile(
                rule: TrainingRule(
                  title: 'Etapa seleccionada',
                  detail:
                      'El Sistema te ubica en ${trainingPath.stages[selectedStageIndex].title}. Frecuencia sugerida: ${trainingPath.stages[selectedStageIndex].frequency}.',
                ),
                palette: palette,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ShadowsGalleryPanel(
          unlockedShadowIds: unlockedShadowIds,
          lastUnlockedShadowId: lastUnlockedShadowId,
          palette: palette,
        ),
      ],
    );
  }
}

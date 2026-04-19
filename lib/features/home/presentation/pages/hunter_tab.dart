import 'package:flutter/material.dart';

import '../../domain/hunter_profile.dart';
import '../../domain/training_path.dart';
import '../widgets/holographic_panel.dart';
import '../widgets/inventory_tile.dart';
import '../widgets/screen_frame.dart';
import '../widgets/section_palette.dart';
import '../widgets/system_badge.dart';
import '../widgets/training_widgets.dart';

class HunterTab extends StatelessWidget {
  const HunterTab({
    required this.profile,
    required this.inventory,
    required this.xpBoostArmed,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.onStageSelected,
    required this.onUseXpBoost,
    required this.onResetProgress,
    required this.palette,
    super.key,
  });

  final HunterProfile profile;
  final Map<String, int> inventory;
  final bool xpBoostArmed;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final ValueChanged<int> onStageSelected;
  final VoidCallback onUseXpBoost;
  final VoidCallback onResetProgress;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenFrame(
      primary: palette.primary,
      secondary: palette.secondary,
      highlight: palette.highlight,
      children: [
        SystemBadge(label: 'Datos del jugador', glowColor: palette.primary),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
          cornerInset: 8,
          cornerSize: 18,
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HunterAvatar(alias: profile.alias, accent: palette.primary),
                  const SizedBox(height: 14),
                  Text(
                    profile.alias,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Objetivo actual: consolidar el habito, completar misiones diarias del sistema y ganar el derecho a progresiones mas dificiles.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decorate: false,
          cornerInset: 8,
          cornerSize: 18,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileLine(
                label: 'Clase',
                value: 'Jugador progresivo de calistenia',
                accent: palette.primary,
              ),
              const SizedBox(height: 12),
              ProfileLine(
                label: 'Especializacion',
                value: 'Fuerza con peso corporal + disciplina de habito',
                accent: palette.secondary,
              ),
              const SizedBox(height: 12),
              ProfileLine(
                label: 'Estado de penalizacion',
                value: 'Ninguno',
                accent: palette.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decorate: false,
          showCorners: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INVENTARIO',
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
                        width: compact ? constraints.maxWidth : (constraints.maxWidth - 20) / 3,
                        child: InventoryTile(
                          label: 'Freeze',
                          value: '${inventory['freeze'] ?? 0}',
                          accent: palette.primary,
                        ),
                      ),
                      SizedBox(
                        width: compact ? constraints.maxWidth : (constraints.maxWidth - 20) / 3,
                        child: InventoryTile(
                          label: 'XP Boost',
                          value: xpBoostArmed ? 'Activo' : '${inventory['xp_boost'] ?? 0}',
                          accent: palette.secondary,
                        ),
                      ),
                      SizedBox(
                        width: compact ? constraints.maxWidth : (constraints.maxWidth - 20) / 3,
                        child: InventoryTile(
                          label: 'Re-roll',
                          value: '${inventory['reroll'] ?? 0}',
                          accent: palette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: xpBoostArmed ? null : onUseXpBoost,
                      child: const Text('Activar XP Boost'),
                    ),
                  ),
                  const SizedBox(height: 10),
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
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DIAGNOSTICO DEL SISTEMA',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Elegi el nivel que mejor refleje tu punto de partida. La app ajustara el bloque semanal y la recomendacion de progreso.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Etapa actual: ${trainingPath.stages[selectedStageIndex].title}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  trainingPath.stages.length,
                  (index) => StageChip(
                    label: trainingPath.stages[index].title,
                    isSelected: index == selectedStageIndex,
                    accent:
                        index == selectedStageIndex ? palette.secondary : palette.primary,
                    onTap: () => onStageSelected(index),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASCENSO DE RANGO',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 14),
              ...trainingPath.stages.map(
                    (stage) => TrainingStageTile(
                      stage: stage,
                      palette: palette,
                      isActive:
                          trainingPath.stages[selectedStageIndex].title == stage.title,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

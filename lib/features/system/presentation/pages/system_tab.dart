import 'package:flutter/material.dart';

import '../../../home/domain/daily_quest.dart';
import '../../../home/domain/hunter_profile.dart';
import '../../../home/domain/training_path.dart';
import '../../../home/domain/workout_day.dart';
import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/screen_frame.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../../home/presentation/widgets/stat_hex_tile.dart';
import '../../../home/presentation/widgets/system_badge.dart';
import '../../../quests/presentation/widgets/quest_card.dart';
import '../widgets/system_muscle_map_models.dart';
import '../widgets/system_muscle_silhouette.dart';

class SystemTab extends StatelessWidget {
  const SystemTab({
    required this.profile,
    required this.quests,
    required this.weeklyPlan,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.onQuestAdvance,
    required this.palette,
    super.key,
  });

  final HunterProfile profile;
  final List<DailyQuest> quests;
  final List<WorkoutDay> weeklyPlan;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final ValueChanged<DailyQuest> onQuestAdvance;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _todayWorkout(weeklyPlan);
    final selectedStageTitle = trainingPath.stages[selectedStageIndex].title;
    final muscleMapModel = SystemMuscleMapModel.fromWorkoutFocus(
      focus: today.focus,
      stageTitle: selectedStageTitle,
    );

    return ScreenFrame(
      primary: palette.primary,
      secondary: palette.secondary,
      highlight: palette.highlight,
      children: [
        Row(
          children: [
            SystemBadge(label: 'Sistema', glowColor: palette.primary),
            const Spacer(),
            Text(
              '${profile.rank}  Lv.${profile.level}',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.8,
                color: Colors.white70,
                shadows: const [
                  Shadow(color: Color(0xCC02070D), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
          cornerInset: 8,
          cornerSize: 18,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.alias.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.primary,
                  letterSpacing: 3.2,
                  shadows: const [
                    Shadow(color: Color(0xCC02070D), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Subiste de nivel.',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      color: Color(0xCC02070D),
                      blurRadius: 18,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sigue completando misiones y bloques de entrenamiento para ascender de ${profile.rank} a D-Rank.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.5,
                  shadows: const [
                    Shadow(color: Color(0xCC02070D), blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 14,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x6679E7FF)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: profile.xpProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [palette.primary, palette.secondary],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${profile.currentXp} / ${profile.nextLevelXp} XP',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _SystemInfoChip(
                    label: 'Proxima meta',
                    value: '${profile.nextLevelXp - profile.currentXp} XP',
                    accent: palette.primary,
                  ),
                  _SystemInfoChip(
                    label: 'Ganancia',
                    value: '+3 stats / nivel',
                    accent: palette.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: StatHexTile(
                label: 'Racha',
                value: '${profile.streakDays} dias',
                icon: Icons.local_fire_department_rounded,
                accent: palette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatHexTile(
                label: 'Sombras',
                value: '${profile.shadowArmy}',
                icon: Icons.groups_rounded,
                accent: palette.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'MISIONES DIARIAS',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 2.4,
            color: palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...quests.take(2).map(
              (quest) => QuestCard(
                quest: quest,
                primary: palette.primary,
                secondary: palette.secondary,
                highlight: palette.highlight,
                onAdvance: () => onQuestAdvance(quest),
              ),
            ),
        const SizedBox(height: 18),
        Text(
          'PROTOCOLO DE HOY',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 2.4,
            color: palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      today.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      today.focus,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    today.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: today.isCompleted ? palette.secondary : Colors.white38,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Los bloques de los dias siguientes se desbloquean con el calendario real. Solo se muestra el protocolo actual para evitar confusiones.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'MAPA MUSCULAR DEL DIA',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 2.4,
            color: palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decorate: false,
          showCorners: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ETAPA ACTIVA \u00b7 ${selectedStageTitle.toUpperCase()}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.secondary,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El Sistema resalta los grupos que deberian cargar mas trabajo hoy segun el protocolo actual.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: muscleMapModel.highlightTags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: palette.secondary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: palette.secondary,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              SystemMuscleSilhouettePanel(
                palette: palette,
                frontZones: muscleMapModel.highlightZonesFront,
                backZones: muscleMapModel.highlightZonesBack,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SystemInfoChip extends StatelessWidget {
  const _SystemInfoChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

WorkoutDay _todayWorkout(List<WorkoutDay> weeklyPlan) {
  final weekday = DateTime.now().weekday;
  final index = (weekday - 1).clamp(0, weeklyPlan.length - 1);
  return weeklyPlan[index];
}

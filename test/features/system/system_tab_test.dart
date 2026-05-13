import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/daily_quest.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/hunter_profile.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/training_path.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/workout_day.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/pages/system_tab.dart';

void main() {
  testWidgets('SystemTab shows muscle map instead of hunter path block', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: SystemTab(
          profile: const HunterProfile(
            alias: 'Eze Bellino',
            avatarUrl: '',
            avatarImageBase64: '',
            rank: 'E-Rank',
            title: 'Humano novato',
            level: 1,
            currentXp: 0,
            nextLevelXp: 120,
            streakDays: 0,
            shadowArmy: 0,
            strength: 1,
            agility: 1,
            endurance: 1,
            discipline: 0,
          ),
          quests: const [
            DailyQuest(
              id: 'q1',
              title: 'Mision diaria',
              detail: 'Detalle',
              rewardXp: 120,
              progress: 0,
              target: 4,
            ),
          ],
          weeklyPlan: const [
            WorkoutDay(label: 'LUN', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'MAR', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'MIE', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'JUE', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'VIE', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'SAB', focus: 'Empuje + hombro', isCompleted: false),
            WorkoutDay(label: 'DOM', focus: 'Empuje + hombro', isCompleted: false),
          ],
          trainingPath: const TrainingPath(
            currentBlock: 'Bloque base 3 dias',
            summary: 'Resumen',
            stages: [
              TrainingStage(
                tier: 'NIVEL 0',
                title: 'Pre Beginner',
                goal: 'Base',
                frequency: '2-3 sesiones',
                focus: 'Base',
                exitRule: 'Salida',
                isCurrent: false,
              ),
              TrainingStage(
                tier: 'FASE I',
                title: 'Beginner',
                goal: 'Base',
                frequency: '3 sesiones',
                focus: 'Base',
                exitRule: 'Salida',
                isCurrent: true,
              ),
              TrainingStage(
                tier: 'FASE II',
                title: 'Intermediate',
                goal: 'Base',
                frequency: '4 sesiones',
                focus: 'Base',
                exitRule: 'Salida',
                isCurrent: false,
              ),
              TrainingStage(
                tier: 'FASE III',
                title: 'Advanced',
                goal: 'Base',
                frequency: '5 sesiones',
                focus: 'Base',
                exitRule: 'Salida',
                isCurrent: false,
              ),
              TrainingStage(
                tier: 'FASE IV',
                title: 'Expert / Pro',
                goal: 'Base',
                frequency: '5 sesiones',
                focus: 'Base',
                exitRule: 'Salida',
                isCurrent: false,
              ),
            ],
            rules: [],
          ),
          selectedStageIndex: 3,
          onQuestAdvance: (_) {},
          palette: const SectionPalette(
            primary: Color(0xFF79E7FF),
            secondary: Color(0xFF25F3B4),
            highlight: Color(0xFFF2FFFF),
          ),
        ),
      ),
    );

    expect(find.text('MAPA MUSCULAR DEL DIA'), findsOneWidget);
    expect(find.textContaining('ETAPA ACTIVA \u00b7 ADVANCED'), findsOneWidget);
    expect(find.text('Vista frontal'), findsOneWidget);
    expect(find.text('Vista dorsal'), findsOneWidget);
    expect(find.text('4 ZONAS ACTIVAS'), findsOneWidget);
    expect(find.text('2 ZONAS ACTIVAS'), findsOneWidget);
    expect(find.text('Pecho'), findsOneWidget);
    expect(find.text('Hombro'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(find.text('Core'), findsOneWidget);
    expect(find.text('EJERCICIOS EN FOCO'), findsOneWidget);
    expect(find.text('Foco principal'), findsOneWidget);
    expect(find.text('Recuperacion sugerida'), findsOneWidget);
    expect(find.text('Pecho, hombro y triceps'), findsOneWidget);
    expect(find.text('Movilidad de hombro y pectoral'), findsOneWidget);
    expect(find.text('Flexiones'), findsOneWidget);
    expect(find.text('Pike push-ups'), findsOneWidget);
    expect(find.text('MUSCULOS INVOLUCRADOS'), findsNWidgets(2));
    expect(find.text('Pecho \u00b7 Hombro \u00b7 Triceps'), findsOneWidget);
    expect(find.text('Hombro \u00b7 Triceps \u00b7 Core'), findsOneWidget);
    expect(find.byKey(const Key('muscle-map-summary-primary')), findsOneWidget);
    expect(find.byKey(const Key('muscle-map-summary-recovery')), findsOneWidget);
    expect(find.byKey(const Key('muscle-map-exercise-0')), findsOneWidget);
    expect(find.byKey(const Key('muscle-map-exercise-1')), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-front')), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-back')), findsOneWidget);
    expect(find.text('CAMINO DEL CAZADOR'), findsNothing);
  });
}

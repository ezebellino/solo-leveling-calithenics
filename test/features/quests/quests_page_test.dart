import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/daily_quest.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/hunter_profile.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/training_path.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/inventory/application/inventory_action_handler.dart';
import 'package:solo_leveling_calisthenics/features/inventory/application/inventory_controller.dart';
import 'package:solo_leveling_calisthenics/features/quests/application/quest_action_handler.dart';
import 'package:solo_leveling_calisthenics/features/quests/application/quest_actions_controller.dart';
import 'package:solo_leveling_calisthenics/features/quests/presentation/pages/quests_page.dart';

void main() {
  const palette = SectionPalette(
    primary: Color(0xFF4DF0FF),
    secondary: Color(0xFF24FFAE),
    highlight: Color(0xFFDCFFF6),
  );

  const profile = HunterProfile(
    alias: 'Eze Bellino',
    avatarUrl: '',
    avatarImageBase64: '',
    rank: 'E-Rank',
    title: 'Humano novato',
    level: 1,
    currentXp: 0,
    nextLevelXp: 120,
    streakDays: 3,
    shadowArmy: 0,
    strength: 1,
    agility: 1,
    endurance: 1,
    discipline: 0,
  );

  const trainingPath = TrainingPath(
    currentBlock: 'Base',
    summary: 'Resumen',
    stages: [
      TrainingStage(
        tier: 'FASE I',
        title: 'Beginner',
        goal: 'Goal',
        frequency: '3 dias',
        focus: 'Focus',
        exitRule: 'Exit',
        isCurrent: true,
      ),
    ],
    rules: [
      TrainingRule(title: 'Regla', detail: 'Detalle'),
    ],
  );

  const quest = DailyQuest(
    id: 'stage1-strength',
    title: 'Mision diaria: Fuerza base',
    detail: 'Detalle',
    rewardXp: 120,
    progress: 0,
    target: 4,
  );

  const specialQuest = DailyQuest(
    id: 'special-stage1',
    title: 'Quest especial semanal',
    detail: 'Detalle especial',
    rewardXp: 220,
    progress: 0,
    target: 5,
  );

  Widget buildSubject({
    required Future<void> Function(bool accept) decideSpecialQuest,
    Future<void> Function(DailyQuest quest)? advanceQuest,
    Future<void> Function(DailyQuest quest)? advanceSpecialQuest,
    String specialQuestStatus = 'pending',
  }) {
    return ProviderScope(
      overrides: [
        inventoryActionHandlerProvider.overrideWithValue(
          const InventoryActionHandler(
            useXpBoost: _noop,
            useReroll: _noop,
            clearChestRewards: _noopSync,
          ),
        ),
        questActionHandlerProvider.overrideWithValue(
          QuestActionHandler(
            advanceQuest: advanceQuest ?? _noopQuest,
            advanceSpecialQuest: advanceSpecialQuest ?? _noopQuest,
            decideSpecialQuest: decideSpecialQuest,
          ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF020611),
          body: QuestsPage(
            profile: profile,
            quests: [quest],
            specialQuest: specialQuest,
            specialQuestStatus: specialQuestStatus,
            inventory: {'freeze': 1, 'xp_boost': 0, 'reroll': 0},
            xpBoostArmed: false,
            trainingPath: trainingPath,
            selectedStageIndex: 0,
            palette: palette,
          ),
        ),
      ),
    );
  }

  testWidgets('daily notification is dismissed when mission starts', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(decideSpecialQuest: (_) async {}),
    );

    expect(find.text('[ Comenzar mision ]'), findsOneWidget);

    await tester.tap(find.text('[ Comenzar mision ]'));
    await tester.pump();

    expect(find.text('[ Comenzar mision ]'), findsNothing);
    expect(find.text('REGISTRO DE MISIONES'), findsOneWidget);
  });

  testWidgets('accepting special quest updates the panel immediately', (
    tester,
  ) async {
    var accepted = false;

    await tester.pumpWidget(
      buildSubject(
        decideSpecialQuest: (accept) async {
          accepted = accept;
        },
      ),
    );

    expect(find.text('Aceptar'), findsOneWidget);

    await tester.tap(find.text('Aceptar'));
    await tester.pump();

    expect(accepted, isTrue);
    expect(find.text('Aceptar'), findsNothing);
    expect(find.text('Quest especial semanal'), findsWidgets);
  });
}

Future<void> _noop() async {}

Future<void> _noopQuest(DailyQuest _) async {}

void _noopSync() {}

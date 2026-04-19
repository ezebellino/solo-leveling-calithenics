import 'dart:math' as math;

import 'daily_quest.dart';
import 'hunter_profile.dart';
import 'player_state.dart';
import 'workout_day.dart';

class PlayerSystemUpdate {
  const PlayerSystemUpdate({
    required this.state,
    this.levelUp,
    this.notices = const [],
  });

  final PlayerState state;
  final int? levelUp;
  final List<String> notices;
}

class PlayerSystemService {
  const PlayerSystemService({required this.baseProfile});

  final HunterProfile baseProfile;

  PlayerState initialState({DateTime? now}) {
    final current = now ?? DateTime.now();
    return PlayerState(
      profile: baseProfile,
      selectedStageIndex: 1,
      quests: _buildQuestsForStage(1),
      weeklySpecialQuest: _buildSpecialQuestForStage(1),
      weeklySpecialWeekKey: _weekKey(current),
      weeklySpecialStatus: 'pending',
      playerAccepted: false,
      jobChanged: false,
      lastQuestRefresh: _todayKey(current),
      inventory: const {
        'freeze': 1,
        'xp_boost': 0,
        'reroll': 0,
      },
      completedDays: 0,
      xpBoostArmed: false,
      lastStreakCreditDate: '',
    );
  }

  PlayerSystemUpdate hydrate(PlayerState? loaded, {DateTime? now}) {
    return refreshForNewDay(loaded ?? initialState(now: now), now: now);
  }

  PlayerSystemUpdate refreshForNewDay(PlayerState state, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = _todayKey(current);
    final week = _weekKey(current);
    if (state.lastQuestRefresh == today && state.weeklySpecialWeekKey == week) {
      return PlayerSystemUpdate(state: state);
    }

    var profile = state.profile;
    final inventory = Map<String, int>.from(state.inventory);
    final notices = <String>[];

    if (state.lastQuestRefresh != today &&
        state.quests.isNotEmpty &&
        !state.quests.first.isCompleted) {
      final freezeCount = inventory['freeze'] ?? 0;
      if (freezeCount > 0) {
        inventory['freeze'] = freezeCount - 1;
        notices.add('Freeze de racha usado para proteger tu progreso');
      } else {
        profile = profile.copyWith(streakDays: 0);
      }
    }

    return PlayerSystemUpdate(
      state: state.copyWith(
        profile: profile,
        quests: _buildQuestsForStage(state.selectedStageIndex),
        weeklySpecialQuest: state.weeklySpecialWeekKey == week
            ? state.weeklySpecialQuest
            : _buildSpecialQuestForStage(state.selectedStageIndex),
        weeklySpecialWeekKey: week,
        weeklySpecialStatus:
            state.weeklySpecialWeekKey == week ? state.weeklySpecialStatus : 'pending',
        lastQuestRefresh: today,
        inventory: inventory,
        xpBoostArmed: false,
        lastStreakCreditDate: state.lastStreakCreditDate,
      ),
      notices: notices,
    );
  }

  PlayerSystemUpdate changeStage(PlayerState state, int index, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return PlayerSystemUpdate(
      state: state.copyWith(
        selectedStageIndex: index,
        quests: _buildQuestsForStage(index),
        weeklySpecialQuest: _buildSpecialQuestForStage(index),
        weeklySpecialStatus: 'pending',
        weeklySpecialWeekKey: _weekKey(current),
      ),
    );
  }

  PlayerSystemUpdate advanceQuest(PlayerState state, DailyQuest quest, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final updatedQuests = state.quests.map((item) {
      if (item.id != quest.id || item.isCompleted) {
        return item;
      }

      final nextProgress = math.min(item.progress + _questStep(item), item.target);
      return item.copyWith(progress: nextProgress);
    }).toList();

    final previous = state.quests.firstWhere((item) => item.id == quest.id);
    final currentQuest = updatedQuests.firstWhere((item) => item.id == quest.id);

    var profile = state.profile;
    final previousLevel = profile.level;
    var completedDays = state.completedDays;
    final inventory = Map<String, int>.from(state.inventory);
    var xpBoostArmed = state.xpBoostArmed;
    var lastStreakCreditDate = state.lastStreakCreditDate;
    final notices = <String>[];

    if (!previous.isCompleted && currentQuest.isCompleted) {
      final rewardXp = xpBoostArmed ? (currentQuest.rewardXp * 1.2).round() : currentQuest.rewardXp;
      final shouldCreditDay =
          state.quests.isNotEmpty &&
          quest.id == state.quests.first.id &&
          lastStreakCreditDate != _todayKey(current);

      profile = _applyQuestReward(
        profile,
        rewardXp,
        incrementStreak: shouldCreditDay,
      );

      if (xpBoostArmed) {
        xpBoostArmed = false;
        notices.add('XP Boost consumido: recompensa aumentada');
      }

      if (shouldCreditDay) {
        completedDays += 1;
        lastStreakCreditDate = _todayKey(current);
        final chestReward = _awardChestReward(completedDays, inventory);
        if (chestReward != null) {
          notices.add(chestReward);
        }
      }

      if (updatedQuests.every((item) => item.isCompleted)) {
        profile = _applyQuestReward(profile, 40);
        notices.add('Bonus diario completo: +40 XP');
      }
    }

    return PlayerSystemUpdate(
      state: state.copyWith(
        profile: profile,
        quests: updatedQuests,
        inventory: inventory,
        completedDays: completedDays,
        xpBoostArmed: xpBoostArmed,
        lastStreakCreditDate: lastStreakCreditDate,
      ),
      levelUp: profile.level > previousLevel ? profile.level : null,
      notices: notices,
    );
  }

  PlayerSystemUpdate advanceSpecialQuest(PlayerState state, DailyQuest quest) {
    final special = state.weeklySpecialQuest;
    if (special == null || state.weeklySpecialStatus != 'accepted' || special.isCompleted) {
      return PlayerSystemUpdate(state: state);
    }

    final nextProgress = math.min(special.progress + _questStep(special), special.target);
    final updatedSpecial = special.copyWith(progress: nextProgress);

    var profile = state.profile;
    final previousLevel = profile.level;
    final notices = <String>[];
    var xpBoostArmed = state.xpBoostArmed;

    if (!special.isCompleted && updatedSpecial.isCompleted) {
      final rewardXp = xpBoostArmed ? (updatedSpecial.rewardXp * 1.2).round() : updatedSpecial.rewardXp;
      profile = _applyQuestReward(profile, rewardXp);
      notices.add('Quest especial completada: +$rewardXp XP');
      xpBoostArmed = false;
    }

    return PlayerSystemUpdate(
      state: state.copyWith(
        profile: profile,
        weeklySpecialQuest: updatedSpecial,
        weeklySpecialStatus: updatedSpecial.isCompleted ? 'completed' : state.weeklySpecialStatus,
        xpBoostArmed: xpBoostArmed,
      ),
      levelUp: profile.level > previousLevel ? profile.level : null,
      notices: notices,
    );
  }

  PlayerSystemUpdate decideSpecialQuest(PlayerState state, bool accept) {
    return PlayerSystemUpdate(
      state: state.copyWith(
        weeklySpecialStatus: accept ? 'accepted' : 'rejected',
      ),
      notices: [
        accept
            ? 'Quest especial aceptada'
            : 'Quest especial rechazada: se mantiene la rutina comun',
      ],
    );
  }

  PlayerSystemUpdate useXpBoost(PlayerState state) {
    final count = state.inventory['xp_boost'] ?? 0;
    if (count <= 0 || state.xpBoostArmed) {
      return PlayerSystemUpdate(state: state);
    }

    final inventory = Map<String, int>.from(state.inventory)
      ..['xp_boost'] = count - 1;

    return PlayerSystemUpdate(
      state: state.copyWith(
        inventory: inventory,
        xpBoostArmed: true,
      ),
      notices: const ['XP Boost activado para la próxima misión completada'],
    );
  }

  PlayerSystemUpdate useReroll(PlayerState state) {
    final count = state.inventory['reroll'] ?? 0;
    if (count <= 0) {
      return PlayerSystemUpdate(state: state);
    }

    final questIndex = state.quests.indexWhere((quest) => !quest.isCompleted);
    if (questIndex == -1) {
      return PlayerSystemUpdate(
        state: state,
        notices: const ['No hay misiones pendientes para recalibrar'],
      );
    }

    final current = state.quests[questIndex];
    final replacement = _rerollQuest(current);
    final quests = [...state.quests]..[questIndex] = replacement;
    final inventory = Map<String, int>.from(state.inventory)
      ..['reroll'] = count - 1;

    return PlayerSystemUpdate(
      state: state.copyWith(quests: quests, inventory: inventory),
      notices: const ['Misión recalibrada por el Sistema'],
    );
  }

  PlayerSystemUpdate resetProgress({DateTime? now}) {
    return PlayerSystemUpdate(
      state: initialState(now: now),
      notices: const ['Progreso reiniciado desde cero'],
    );
  }

  List<WorkoutDay> buildWeeklyPlan(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return const [
          WorkoutDay(label: 'LUN', focus: 'Nivel 0 A: empuje + pierna', isCompleted: true),
          WorkoutDay(label: 'MAR', focus: 'Movilidad + caminata', isCompleted: true),
          WorkoutDay(label: 'MIE', focus: 'Nivel 0 B: tiron + base', isCompleted: false),
          WorkoutDay(label: 'JUE', focus: 'Respiracion + core suave', isCompleted: false),
          WorkoutDay(label: 'VIE', focus: 'Nivel 0 C: full body asistido', isCompleted: false),
        ];
      case 1:
        return const [
          WorkoutDay(label: 'LUN', focus: 'Base full body A', isCompleted: true),
          WorkoutDay(label: 'MAR', focus: 'Movilidad + caminata', isCompleted: true),
          WorkoutDay(label: 'MIE', focus: 'Base full body B', isCompleted: false),
          WorkoutDay(label: 'JUE', focus: 'Core + recuperacion', isCompleted: false),
          WorkoutDay(label: 'VIE', focus: 'Base full body C', isCompleted: false),
          WorkoutDay(label: 'SAB', focus: 'Tecnica suave + paseo', isCompleted: false),
        ];
      case 2:
        return const [
          WorkoutDay(label: 'LUN', focus: 'Empuje + hombro', isCompleted: true),
          WorkoutDay(label: 'MAR', focus: 'Tiron vertical + core', isCompleted: true),
          WorkoutDay(label: 'MIE', focus: 'Pierna + movilidad', isCompleted: false),
          WorkoutDay(label: 'JUE', focus: 'Skill base + handstand', isCompleted: false),
          WorkoutDay(label: 'VIE', focus: 'Full body de progreso', isCompleted: false),
          WorkoutDay(label: 'SAB', focus: 'Caminata + descarga', isCompleted: false),
        ];
      case 3:
        return const [
          WorkoutDay(label: 'LUN', focus: 'Fuerza de empuje', isCompleted: true),
          WorkoutDay(label: 'MAR', focus: 'Fuerza de tiron', isCompleted: true),
          WorkoutDay(label: 'MIE', focus: 'Pierna + core denso', isCompleted: false),
          WorkoutDay(label: 'JUE', focus: 'Skill session', isCompleted: false),
          WorkoutDay(label: 'VIE', focus: 'Resistencia', isCompleted: false),
          WorkoutDay(label: 'SAB', focus: 'Movilidad + tecnica', isCompleted: false),
        ];
      default:
        return const [
          WorkoutDay(label: 'LUN', focus: 'Bloque tecnico principal', isCompleted: true),
          WorkoutDay(label: 'MAR', focus: 'Fuerza maxima', isCompleted: true),
          WorkoutDay(label: 'MIE', focus: 'Descarga activa', isCompleted: false),
          WorkoutDay(label: 'JUE', focus: 'Skill avanzado', isCompleted: false),
          WorkoutDay(label: 'VIE', focus: 'Resistencia especifica', isCompleted: false),
          WorkoutDay(label: 'SAB', focus: 'Revision de forma + movilidad', isCompleted: false),
        ];
    }
  }

  HunterProfile _applyQuestReward(
    HunterProfile profile,
    int rewardXp, {
    bool incrementStreak = false,
  }) {
    var currentXp = profile.currentXp + rewardXp;
    var nextLevelXp = profile.nextLevelXp;
    var level = profile.level;
    var strength = profile.strength;
    var agility = profile.agility;
    var endurance = profile.endurance;
    var discipline = profile.discipline;
    var shadowArmy = profile.shadowArmy;

    while (currentXp >= nextLevelXp) {
      currentXp -= nextLevelXp;
      level += 1;
      nextLevelXp += 120;
      final gains = _statGainForLevel(level);
      strength += gains.$1;
      agility += gains.$2;
      endurance += gains.$3;
      discipline += gains.$4;
      if (level % 3 == 0) {
        shadowArmy += 1;
      }
    }

    return profile.copyWith(
      level: level,
      currentXp: currentXp,
      nextLevelXp: nextLevelXp,
      streakDays: incrementStreak ? profile.streakDays + 1 : profile.streakDays,
      strength: strength,
      agility: agility,
      endurance: endurance,
      discipline: discipline,
      shadowArmy: shadowArmy,
      rank: _rankForLevel(level),
    );
  }

  (int, int, int, int) _statGainForLevel(int level) {
    switch (level % 4) {
      case 0:
        return (1, 1, 1, 0);
      case 1:
        return (1, 0, 1, 1);
      case 2:
        return (1, 1, 0, 1);
      default:
        return (0, 1, 1, 1);
    }
  }

  int _questStep(DailyQuest quest) {
    if (quest.target == 1) {
      return 1;
    }

    return math.max(1, (quest.target / 4).round());
  }

  List<DailyQuest> _buildQuestsForStage(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return const [
          DailyQuest(
            id: 'stage0-assisted-pull',
            title: 'Mision diaria: Base asistida',
            detail: '4 series de dominadas asistidas, flexiones inclinadas y sentadillas controladas.',
            rewardXp: 80,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage0-core',
            title: 'Respiracion y core',
            detail: 'Completa 4 bloques de hollow hold suave con respiracion nasal.',
            rewardXp: 60,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage0-log',
            title: 'Registro de habito',
            detail: 'Marca la sesion del dia y registra energia, fatiga y caminata.',
            rewardXp: 40,
            progress: 0,
            target: 1,
          ),
        ];
      case 1:
        return const [
          DailyQuest(
            id: 'stage1-strength',
            title: 'Mision diaria: Fuerza base',
            detail: 'Completa 4 bloques de flexiones, sentadillas, remo y trabajo de core.',
            rewardXp: 120,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage1-shadow',
            title: 'Disciplina de sombra',
            detail: 'Sostene hollow hold y cadencia de respiracion durante 4 rondas solidas.',
            rewardXp: 90,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage1-log',
            title: 'Registro de recuperacion',
            detail: 'Registra sueño, fatiga y peso corporal antes de la medianoche.',
            rewardXp: 60,
            progress: 0,
            target: 1,
          ),
        ];
      case 2:
        return const [
          DailyQuest(
            id: 'stage2-progression',
            title: 'Mision diaria: Progresion media',
            detail: 'Completa 5 bloques de empuje o tiron con una variante mas dificil que la semana pasada.',
            rewardXp: 150,
            progress: 0,
            target: 5,
          ),
          DailyQuest(
            id: 'stage2-skill',
            title: 'Ventana tecnica',
            detail: 'Dedica 5 rondas a handstand, escapulas y control corporal.',
            rewardXp: 110,
            progress: 0,
            target: 5,
          ),
          DailyQuest(
            id: 'stage2-log',
            title: 'Chequeo del sistema',
            detail: 'Confirma descanso, movilidad y estado general del jugador.',
            rewardXp: 70,
            progress: 0,
            target: 1,
          ),
        ];
      case 3:
        return const [
          DailyQuest(
            id: 'stage3-strength',
            title: 'Mision diaria: Bloque de fuerza',
            detail: 'Completa 5 sets pesados de tiron o empuje tecnico con descanso controlado.',
            rewardXp: 180,
            progress: 0,
            target: 5,
          ),
          DailyQuest(
            id: 'stage3-skill',
            title: 'Objetivo de skill',
            detail: 'Trabaja 4 intentos de front lever, handstand o muscle up con progresion limpia.',
            rewardXp: 130,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage3-recovery',
            title: 'Protocolo de recuperacion',
            detail: 'Completa la rutina de movilidad y descarga del dia.',
            rewardXp: 80,
            progress: 0,
            target: 1,
          ),
        ];
      default:
        return const [
          DailyQuest(
            id: 'stage4-specialization',
            title: 'Mision diaria: Especializacion',
            detail: 'Completa 6 bloques especificos del objetivo principal con tecnica premium.',
            rewardXp: 220,
            progress: 0,
            target: 6,
          ),
          DailyQuest(
            id: 'stage4-resistance',
            title: 'Sistema de resistencia',
            detail: 'Cierra 4 rondas de resistencia o densidad segun el bloque semanal.',
            rewardXp: 150,
            progress: 0,
            target: 4,
          ),
          DailyQuest(
            id: 'stage4-review',
            title: 'Revision del cazador',
            detail: 'Registra rendimiento, dolor articular y necesidad de descarga.',
            rewardXp: 90,
            progress: 0,
            target: 1,
          ),
        ];
    }
  }

  DailyQuest _buildSpecialQuestForStage(int stageIndex) {
    switch (stageIndex) {
      case 0:
        return const DailyQuest(
          id: 'special-stage0',
          title: 'Quest especial semanal',
          detail: 'Aumenta el bloque base: 5 rondas asistidas y caminata mas larga para probar tu constancia.',
          rewardXp: 160,
          progress: 0,
          target: 5,
        );
      case 1:
        return const DailyQuest(
          id: 'special-stage1',
          title: 'Quest especial semanal',
          detail: 'Escala la mision comun: 5 km de trote o caminata rapida y un bloque extra de fuerza base.',
          rewardXp: 220,
          progress: 0,
          target: 5,
        );
      case 2:
        return const DailyQuest(
          id: 'special-stage2',
          title: 'Quest especial semanal',
          detail: 'Completa 6 rondas tecnicas con menos descanso y cierra una ventana extendida de handstand.',
          rewardXp: 260,
          progress: 0,
          target: 6,
        );
      case 3:
        return const DailyQuest(
          id: 'special-stage3',
          title: 'Quest especial semanal',
          detail: 'Haz una sesion pesada de fuerza y termina con un bloque extra de skill avanzada.',
          rewardXp: 320,
          progress: 0,
          target: 5,
        );
      default:
        return const DailyQuest(
          id: 'special-stage4',
          title: 'Quest especial semanal',
          detail: 'Sesion elite del sistema: bloque tecnico premium, densidad extra y control total del esfuerzo.',
          rewardXp: 380,
          progress: 0,
          target: 6,
        );
    }
  }

  String? _awardChestReward(int completedDays, Map<String, int> inventory) {
    if (completedDays % 30 == 0) {
      inventory['freeze'] = (inventory['freeze'] ?? 0) + 1;
      inventory['xp_boost'] = (inventory['xp_boost'] ?? 0) + 1;
      inventory['reroll'] = (inventory['reroll'] ?? 0) + 1;
      return 'Cofre elite abierto: Freeze + XP Boost + Re-roll';
    }
    if (completedDays % 14 == 0) {
      inventory['xp_boost'] = (inventory['xp_boost'] ?? 0) + 1;
      inventory['reroll'] = (inventory['reroll'] ?? 0) + 1;
      return 'Cofre raro abierto: XP Boost + Re-roll';
    }
    if (completedDays % 7 == 0) {
      inventory['freeze'] = (inventory['freeze'] ?? 0) + 1;
      return 'Cofre semanal abierto: Freeze de racha x1';
    }
    if (completedDays % 3 == 0) {
      inventory['reroll'] = (inventory['reroll'] ?? 0) + 1;
      return 'Cofre menor abierto: Re-roll x1';
    }
    return null;
  }

  DailyQuest _rerollQuest(DailyQuest quest) {
    return quest.copyWith(
      id: '${quest.id}-reroll',
      title: 'Mision recalibrada',
      detail: 'El Sistema ajusto tu objetivo: cambia de estimulo pero manten el compromiso del dia.',
      rewardXp: quest.rewardXp + 15,
      progress: 0,
      target: math.max(1, quest.target - 1),
    );
  }

  String _rankForLevel(int level) {
    if (level >= 30) {
      return 'B-Rank';
    }
    if (level >= 24) {
      return 'C-Rank';
    }
    if (level >= 16) {
      return 'D-Rank';
    }
    return 'E-Rank';
  }

  String _todayKey(DateTime now) {
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  String _weekKey(DateTime now) {
    final startOfYear = DateTime(now.year, 1, 1);
    final daysOffset = now.difference(startOfYear).inDays;
    final week = ((daysOffset + startOfYear.weekday - 1) / 7).floor() + 1;
    return '${now.year}-W$week';
  }
}

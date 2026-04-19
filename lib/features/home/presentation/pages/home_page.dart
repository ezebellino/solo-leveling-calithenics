import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/local_player_state_repository.dart';
import '../../domain/daily_quest.dart';
import '../../domain/hunter_profile.dart';
import '../../domain/player_state.dart';
import '../../domain/training_path.dart';
import '../../domain/workout_day.dart';
import 'hunter_tab.dart';
import 'quest_tab.dart';
import 'stats_tab.dart';
import 'system_tab.dart';
import '../widgets/hud_navigation_bar.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/notification_panel.dart';
import '../widgets/reward_notice_banner.dart';
import '../widgets/section_palette.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _systemPalette = SectionPalette(
    primary: Color(0xFF79E7FF),
    secondary: Color(0xFF25F3B4),
    highlight: Color(0xFFB7F2FF),
  );
  static const _questPalette = SectionPalette(
    primary: Color(0xFF4DF0FF),
    secondary: Color(0xFF24FFAE),
    highlight: Color(0xFFDCFFF6),
  );
  static const _statsPalette = SectionPalette(
    primary: Color(0xFF6DDCFF),
    secondary: Color(0xFF7AB8FF),
    highlight: Color(0xFFD7EEFF),
  );
  static const _playerPalette = SectionPalette(
    primary: Color(0xFF8ED8FF),
    secondary: Color(0xFF7AF0D4),
    highlight: Color(0xFFF3FBFF),
  );
  static const _navItems = [
    HudNavItemData(
      label: 'Sistema',
      icon: Icons.home_rounded,
    ),
    HudNavItemData(
      label: 'Misiones',
      icon: Icons.assignment_turned_in_rounded,
    ),
    HudNavItemData(
      label: 'Atributos',
      icon: Icons.bolt_rounded,
    ),
    HudNavItemData(
      label: 'Jugador',
      icon: Icons.person_rounded,
    ),
  ];

  static const _profile = HunterProfile(
    alias: 'Eze Bellino',
    rank: 'E-Rank',
    title: 'Jugador de calistenia',
    level: 1,
    currentXp: 0,
    nextLevelXp: 120,
    streakDays: 0,
    shadowArmy: 0,
    strength: 1,
    agility: 1,
    endurance: 1,
    discipline: 0,
  );
  static final _storage = LocalPlayerStateRepository();

  static const _trainingPath = TrainingPath(
    currentBlock: 'Bloque base 3 dias',
    summary:
        'Progresion paulatina inspirada en la guia: primero dominio tecnico y constancia, luego fuerza, despues volumen, y por ultimo habilidades avanzadas.',
    stages: [
      TrainingStage(
        tier: 'NIVEL 0',
        title: 'Pre Beginner',
        goal: 'Construir fuerza minima para empuje, tiron y pierna.',
        frequency: '2-3 sesiones por semana',
        focus:
            'Dominadas asistidas, flexiones inclinadas, australian pull ups asistidas y sentadillas.',
        exitRule: 'Salir cuando estos ejercicios ya se sientan faciles.',
        isCurrent: false,
      ),
      TrainingStage(
        tier: 'FASE I',
        title: 'Beginner',
        goal: 'Consolidar habito, tecnica limpia y tolerancia articular.',
        frequency: '3 sesiones full body por semana',
        focus:
            'Flexiones, remos, sentadillas, zancadas, hollow hold y caminatas.',
        exitRule:
            'Subir cuando los ejercicios base lleguen a 12-15 repeticiones con forma solida.',
        isCurrent: true,
      ),
      TrainingStage(
        tier: 'FASE II',
        title: 'Intermediate',
        goal: 'Aumentar dificultad del ejercicio, no solo sumar cansancio.',
        frequency: '4 sesiones semanales',
        focus:
            'Variantes mas duras, trabajo de hombro, tiron vertical y progresiones de skill.',
        exitRule:
            'Pasar cuando las variantes medias entren en rango de 8-12 repeticiones controladas.',
        isCurrent: false,
      ),
      TrainingStage(
        tier: 'FASE III',
        title: 'Advanced',
        goal: 'Separar fuerza, resistencia y objetivos tecnicos.',
        frequency: '4-5 sesiones semanales',
        focus:
            'Front lever, handstand, muscle up, fondos y dominadas avanzadas.',
        exitRule:
            'Avanzar cuando las progresiones se sostienen con control sin dolor articular.',
        isCurrent: false,
      ),
      TrainingStage(
        tier: 'FASE IV',
        title: 'Expert / Pro',
        goal: 'Especializar el rendimiento sin perder base ni movilidad.',
        frequency: '5 sesiones con descarga y rotacion cada 6 semanas',
        focus:
            'Bloques especificos de fuerza, skills, resistencia y trabajo tecnico fino.',
        exitRule:
            'Mantener solo si la recuperacion, movilidad y tecnica siguen al mismo nivel que la fuerza.',
        isCurrent: false,
      ),
    ],
    rules: [
      TrainingRule(
        title: 'Regla de progreso',
        detail:
            'En full body y grupos musculares conviene cambiar de ejercicio cuando llegas a 12-15 repeticiones; en ejercicios faciles podes esperar 20-25 y en dificiles 5-8.',
      ),
      TrainingRule(
        title: 'Regla de seguridad',
        detail:
            'Aunque la fuerza llegue primero, tendones y articulaciones tardan mas en adaptarse. El libro insiste en mantener progresiones durante semanas antes de saltar al siguiente gesto.',
      ),
      TrainingRule(
        title: 'Regla de variedad',
        detail:
            'Cada 6 semanas conviene hacer una semana mas ligera o de otro estilo para evitar monotonia, descompensaciones y estancamiento.',
      ),
    ],
  );

  var _selectedIndex = 0;
  var _previousIndex = 0;
  PlayerState? _playerState;
  var _isLoading = true;
  int? _levelUpNotice;
  String? _rewardNotice;

  int get _selectedStageIndex => _playerState?.selectedStageIndex ?? 1;
  HunterProfile get _profileState => _playerState?.profile ?? _profile;
  List<DailyQuest> get _quests => _playerState?.quests ?? _buildQuestsForStage(1);
  DailyQuest? get _weeklySpecialQuest => _playerState?.weeklySpecialQuest;
  String get _weeklySpecialStatus =>
      _playerState?.weeklySpecialStatus ?? 'pending';
  Map<String, int> get _inventory => _playerState?.inventory ?? const {};
  bool get _xpBoostArmed => _playerState?.xpBoostArmed ?? false;
  bool get _playerAccepted => _playerState?.playerAccepted ?? false;
  bool get _jobChanged => _playerState?.jobChanged ?? false;
  List<WorkoutDay> get _weeklyPlan => _buildWeeklyPlan(_selectedStageIndex);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final loaded = await _storage.load();
    final hydrated = _refreshForNewDay(loaded ?? _initialState());
    if (!mounted) {
      return;
    }

    setState(() {
      _playerState = hydrated;
      _isLoading = false;
    });
    await _storage.save(hydrated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _SystemBackdrop(mode: _selectedIndex),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, animation) {
                final key = child.key;
                final isIncoming = key == ValueKey('tab-$_selectedIndex');
                final fromRight = _selectedIndex >= _previousIndex;
                final begin = isIncoming
                    ? Offset(fromRight ? 0.10 : -0.10, 0)
                    : Offset(fromRight ? -0.06 : 0.06, 0);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: begin,
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('tab-$_selectedIndex'),
                child: _buildCurrentTab(),
              ),
            ),
          ),
          if (!_playerAccepted || !_jobChanged)
            Positioned.fill(
              child: Container(
                color: const Color(0xCC03080F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_playerAccepted
                          ? NotificationPanel(
                              key: const ValueKey('accept-player'),
                              title: 'Notificacion',
                              lines: const [
                                'Has adquirido las condiciones para convertirte en un Jugador.',
                                'Acepta el Sistema y comienza tu progresion diaria.',
                              ],
                              secondaryLabel: '[ Rechazar ]',
                              ctaLabel: '[ Aceptar ]',
                              onSecondary: () {},
                              onAccept: () {
                                _updateState(
                                  _playerState!.copyWith(playerAccepted: true),
                                );
                              },
                            )
                          : NotificationPanel(
                              key: const ValueKey('job-change'),
                              title: 'Notificacion',
                              lines: const [
                                'Tu clase ha cambiado.',
                                '[ necromancer ]',
                                'El Sistema reconoce tu disciplina como [ shadow monarch ].',
                              ],
                              ctaLabel: '[ Continuar ]',
                              emphasisColor: const Color(0xFF25F3B4),
                              onAccept: () {
                                _updateState(
                                  _playerState!.copyWith(jobChanged: true),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          if (_levelUpNotice != null && _playerAccepted && _jobChanged)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  color: const Color(0x2203080F),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: LevelUpOverlay(
                      level: _levelUpNotice!,
                      primary: _paletteForIndex(_selectedIndex).primary,
                      secondary: _paletteForIndex(_selectedIndex).secondary,
                    ),
                  ),
                ),
              ),
            ),
          if (_rewardNotice != null && _playerAccepted && _jobChanged)
            Positioned(
              left: 24,
              right: 24,
              top: 110,
              child: IgnorePointer(
                child: RewardNoticeBanner(
                  message: _rewardNotice!,
                  secondary: _paletteForIndex(_selectedIndex).secondary,
                  highlight: _paletteForIndex(_selectedIndex).highlight,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: HudNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        primary: _paletteForIndex(_selectedIndex).primary,
        secondary: _paletteForIndex(_selectedIndex).secondary,
        highlight: _paletteForIndex(_selectedIndex).highlight,
        onTap: (index) {
          setState(() {
            _previousIndex = _selectedIndex;
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  SectionPalette _paletteForIndex(int index) {
    switch (index) {
      case 1:
        return _questPalette;
      case 2:
        return _statsPalette;
      case 3:
        return _playerPalette;
      default:
        return _systemPalette;
    }
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 1:
        return QuestTab(
          profile: _profileState,
          quests: _quests,
          specialQuest: _weeklySpecialQuest,
          specialQuestStatus: _weeklySpecialStatus,
          inventory: _inventory,
          xpBoostArmed: _xpBoostArmed,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onQuestAdvance: _advanceQuest,
          onSpecialAdvance: _advanceSpecialQuest,
          onSpecialDecision: _handleSpecialQuestDecision,
          onUseXpBoost: _useXpBoost,
          onUseReroll: _useReroll,
          palette: _questPalette,
        );
      case 2:
        return StatsTab(
          profile: _profileState,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          palette: _statsPalette,
        );
      case 3:
        return HunterTab(
          profile: _profileState,
          inventory: _inventory,
          xpBoostArmed: _xpBoostArmed,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onStageSelected: _handleStageSelected,
          onUseXpBoost: _useXpBoost,
          onResetProgress: _resetProgress,
          palette: _playerPalette,
        );
      default:
        return SystemTab(
          profile: _profileState,
          quests: _quests,
          weeklyPlan: _weeklyPlan,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onQuestAdvance: _advanceQuest,
          palette: _systemPalette,
        );
    }
  }

  void _handleStageSelected(int index) {
    final newState = _playerState!.copyWith(
      selectedStageIndex: index,
      quests: _buildQuestsForStage(index),
      weeklySpecialQuest: _buildSpecialQuestForStage(index),
      weeklySpecialStatus: 'pending',
      weeklySpecialWeekKey: _weekKey(),
    );
    _updateState(newState);
  }

  Future<void> _advanceQuest(DailyQuest quest) async {
    final state = _playerState!;
    final updatedQuests = state.quests.map((item) {
      if (item.id != quest.id || item.isCompleted) {
        return item;
      }

      final nextProgress = math.min(item.progress + _questStep(item), item.target);
      return item.copyWith(progress: nextProgress);
    }).toList();

    final previous = state.quests.firstWhere((item) => item.id == quest.id);
    final current = updatedQuests.firstWhere((item) => item.id == quest.id);

    var profile = state.profile;
    final previousLevel = profile.level;
    var completedDays = state.completedDays;
    var inventory = Map<String, int>.from(state.inventory);
    var xpBoostArmed = state.xpBoostArmed;
    var lastStreakCreditDate = state.lastStreakCreditDate;
    if (!previous.isCompleted && current.isCompleted) {
      final rewardXp = xpBoostArmed
          ? (current.rewardXp * 1.2).round()
          : current.rewardXp;
      final shouldCreditDay =
          state.quests.isNotEmpty &&
          quest.id == state.quests.first.id &&
          lastStreakCreditDate != _todayKey();
      profile = _applyQuestReward(
        profile,
        rewardXp,
        incrementStreak: shouldCreditDay,
      );
      if (xpBoostArmed) {
        xpBoostArmed = false;
        _showRewardNotice('XP Boost consumido: recompensa aumentada');
      }
      if (shouldCreditDay) {
        completedDays += 1;
        lastStreakCreditDate = _todayKey();
        final chestReward = _awardChestReward(completedDays, inventory);
        if (chestReward != null) {
          _showRewardNotice(chestReward);
        }
      }
      if (updatedQuests.every((item) => item.isCompleted)) {
        profile = _applyQuestReward(profile, 40);
        _showRewardNotice('Bonus diario completo: +40 XP');
      }
    }

    final nextState = state.copyWith(
      profile: profile,
      quests: updatedQuests,
      inventory: inventory,
      completedDays: completedDays,
      xpBoostArmed: xpBoostArmed,
      lastStreakCreditDate: lastStreakCreditDate,
    );

    await _updateState(nextState);
    if (profile.level > previousLevel) {
      _showLevelUp(profile.level);
    }
  }

  Future<void> _advanceSpecialQuest(DailyQuest quest) async {
    final state = _playerState!;
    final special = state.weeklySpecialQuest;
    if (special == null || state.weeklySpecialStatus != 'accepted') {
      return;
    }

    if (special.isCompleted) {
      return;
    }

    final nextProgress = math.min(
      special.progress + _questStep(special),
      special.target,
    );
    final updatedSpecial = special.copyWith(progress: nextProgress);

    var profile = state.profile;
    final previousLevel = profile.level;
    if (!special.isCompleted && updatedSpecial.isCompleted) {
      final rewardXp = state.xpBoostArmed
          ? (updatedSpecial.rewardXp * 1.2).round()
          : updatedSpecial.rewardXp;
      profile = _applyQuestReward(profile, rewardXp);
      _showRewardNotice('Quest especial completada: +$rewardXp XP');
    }

    final nextState = state.copyWith(
      profile: profile,
      weeklySpecialQuest: updatedSpecial,
      weeklySpecialStatus:
          updatedSpecial.isCompleted ? 'completed' : state.weeklySpecialStatus,
      xpBoostArmed:
          updatedSpecial.isCompleted ? false : state.xpBoostArmed,
    );

    await _updateState(nextState);
    if (profile.level > previousLevel) {
      _showLevelUp(profile.level);
    }
  }

  Future<void> _handleSpecialQuestDecision(bool accept) async {
    final state = _playerState!;
    final nextState = state.copyWith(
      weeklySpecialStatus: accept ? 'accepted' : 'rejected',
    );
    await _updateState(nextState);
    _showRewardNotice(
      accept
          ? 'Quest especial aceptada'
          : 'Quest especial rechazada: se mantiene la rutina comun',
    );
  }

  Future<void> _useXpBoost() async {
    final state = _playerState!;
    final count = state.inventory['xp_boost'] ?? 0;
    if (count <= 0 || state.xpBoostArmed) {
      return;
    }

    final inventory = Map<String, int>.from(state.inventory)
      ..['xp_boost'] = count - 1;
    await _updateState(
      state.copyWith(
        inventory: inventory,
        xpBoostArmed: true,
      ),
    );
    _showRewardNotice('XP Boost activado para la proxima mision completada');
  }

  Future<void> _useReroll() async {
    final state = _playerState!;
    final count = state.inventory['reroll'] ?? 0;
    if (count <= 0) {
      return;
    }

    final questIndex = state.quests.indexWhere((quest) => !quest.isCompleted);
    if (questIndex == -1) {
      _showRewardNotice('No hay misiones pendientes para recalibrar');
      return;
    }

    final current = state.quests[questIndex];
    final replacement = _rerollQuest(current);
    final quests = [...state.quests]..[questIndex] = replacement;
    final inventory = Map<String, int>.from(state.inventory)
      ..['reroll'] = count - 1;

    await _updateState(state.copyWith(quests: quests, inventory: inventory));
    _showRewardNotice('Mision recalibrada por el Sistema');
  }

  Future<void> _resetProgress() async {
    final resetState = _initialState();
    await _updateState(resetState);
    setState(() {
      _selectedIndex = 0;
      _previousIndex = 0;
      _levelUpNotice = null;
    });
    _showRewardNotice('Progreso reiniciado desde cero');
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

  Future<void> _updateState(PlayerState state) async {
    setState(() {
      _playerState = state;
    });
    await _storage.save(state);
  }

  PlayerState _initialState() {
    return PlayerState(
      profile: _profile,
      selectedStageIndex: 1,
      quests: _buildQuestsForStage(1),
      weeklySpecialQuest: _buildSpecialQuestForStage(1),
      weeklySpecialWeekKey: _weekKey(),
      weeklySpecialStatus: 'pending',
      playerAccepted: false,
      jobChanged: false,
      lastQuestRefresh: _todayKey(),
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

  PlayerState _refreshForNewDay(PlayerState state) {
    final today = _todayKey();
    final week = _weekKey();
    if (state.lastQuestRefresh == today && state.weeklySpecialWeekKey == week) {
      return state;
    }

    var profile = state.profile;
    final inventory = Map<String, int>.from(state.inventory);

    if (state.lastQuestRefresh != today &&
        state.quests.isNotEmpty &&
        !state.quests.first.isCompleted) {
      final freezeCount = inventory['freeze'] ?? 0;
      if (freezeCount > 0) {
        inventory['freeze'] = freezeCount - 1;
        _showRewardNotice('Freeze de racha usado para proteger tu progreso');
      } else {
        profile = profile.copyWith(streakDays: 0);
      }
    }

    return state.copyWith(
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
    );
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
          detail:
              'Aumenta el bloque base: 5 rondas asistidas y caminata mas larga para probar tu constancia.',
          rewardXp: 160,
          progress: 0,
          target: 5,
        );
      case 1:
        return const DailyQuest(
          id: 'special-stage1',
          title: 'Quest especial semanal',
          detail:
              'Escala la mision comun: 5 km de trote o caminata rapida y un bloque extra de fuerza base.',
          rewardXp: 220,
          progress: 0,
          target: 5,
        );
      case 2:
        return const DailyQuest(
          id: 'special-stage2',
          title: 'Quest especial semanal',
          detail:
              'Completa 6 rondas tecnicas con menos descanso y cierra una ventana extendida de handstand.',
          rewardXp: 260,
          progress: 0,
          target: 6,
        );
      case 3:
        return const DailyQuest(
          id: 'special-stage3',
          title: 'Quest especial semanal',
          detail:
              'Haz una sesion pesada de fuerza y termina con un bloque extra de skill avanzada.',
          rewardXp: 320,
          progress: 0,
          target: 5,
        );
      default:
        return const DailyQuest(
          id: 'special-stage4',
          title: 'Quest especial semanal',
          detail:
              'Sesion elite del sistema: bloque tecnico premium, densidad extra y control total del esfuerzo.',
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
      detail:
          'El Sistema ajusto tu objetivo: cambia de estimulo pero manten el compromiso del dia.',
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

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  String _weekKey() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final daysOffset = now.difference(startOfYear).inDays;
    final week = ((daysOffset + startOfYear.weekday - 1) / 7).floor() + 1;
    return '${now.year}-W$week';
  }

  void _showLevelUp(int level) {
    setState(() {
      _levelUpNotice = level;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _levelUpNotice = null;
      });
    });
  }

  void _showRewardNotice(String message) {
    setState(() {
      _rewardNotice = message;
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_rewardNotice == message) {
          _rewardNotice = null;
        }
      });
    });
  }

  List<WorkoutDay> _buildWeeklyPlan(int stageIndex) {
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
}

class _SystemBackdrop extends StatefulWidget {
  const _SystemBackdrop({required this.mode});

  final int mode;

  @override
  State<_SystemBackdrop> createState() => _SystemBackdropState();
}

class _SystemBackdropState extends State<_SystemBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    Color(0xFF10263A),
                    Color(0xFF050A12),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BackdropPainter(
                  phase: _controller.value,
                  mode: widget.mode,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.phase, required this.mode});

  final double phase;
  final int mode;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = switch (mode) {
      1 => const SectionPalette(
          primary: Color(0xFF4DF0FF),
          secondary: Color(0xFF24FFAE),
          highlight: Color(0xFFDCFFF6),
        ),
      2 => const SectionPalette(
          primary: Color(0xFF6DDCFF),
          secondary: Color(0xFF7AB8FF),
          highlight: Color(0xFFD7EEFF),
        ),
      3 => const SectionPalette(
          primary: Color(0xFF8ED8FF),
          secondary: Color(0xFF7AF0D4),
          highlight: Color(0xFFF3FBFF),
        ),
      _ => const SectionPalette(
          primary: Color(0xFF79E7FF),
          secondary: Color(0xFF25F3B4),
          highlight: Color(0xFFB7F2FF),
        ),
    };

    final linePaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.08)
      ..strokeWidth = 0.9;

    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.08 + (i * 0.11));
      canvas.drawLine(Offset(size.width * 0.06, y),
          Offset(size.width * 0.94, y), linePaint);
    }

    final glowPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawLine(
      Offset(size.width * 0.08, 26),
      Offset(size.width * 0.92, 26),
      glowPaint..strokeWidth = 6,
    );

    final intensity = switch (mode) {
      1 => 1.15,
      2 => 1.35,
      3 => 0.9,
      _ => 1.0,
    };

    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.primary,
      colorB: palette.secondary,
      opacity: 0.16 * intensity,
      strokeWidth: 2.6 + (mode == 2 ? 0.4 : 0),
      verticalOffset: size.height * 0.22,
      speed: 1.0 + (mode * 0.08),
    );
    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.secondary,
      colorB: palette.primary,
      opacity: 0.11 * intensity,
      strokeWidth: 1.9 + (mode == 1 ? 0.2 : 0),
      verticalOffset: size.height * 0.48,
      speed: 1.45 + (mode * 0.06),
    );
    _drawSmokeLayer(
      canvas,
      size,
      colorA: palette.highlight,
      colorB: palette.primary,
      opacity: 0.08 * intensity,
      strokeWidth: 1.5,
      verticalOffset: size.height * 0.72,
      speed: 1.9 + (mode * 0.05),
    );
  }

  void _drawSmokeLayer(
    Canvas canvas,
    Size size, {
    required Color colorA,
    required Color colorB,
    required double opacity,
    required double strokeWidth,
    required double verticalOffset,
    required double speed,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          colorA.withValues(alpha: 0.0),
          colorA.withValues(alpha: opacity),
          colorB.withValues(alpha: opacity * 0.72),
          colorA.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, verticalOffset - 80, size.width, 160))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    final shift = (phase * size.width * 0.9 * speed) % (size.width * 1.4);
    for (var i = -1; i < 3; i++) {
      final startX = -size.width * 0.35 + (i * size.width * 0.52) + shift;
      final laneDrift = math.sin((phase * math.pi * 2 * 0.55) + (i * 1.3)) * 18;
      final breeze = math.cos((phase * math.pi * 2 * 0.35) + (i * 0.9)) * 14;
      final a = 24 + (math.sin((phase * math.pi * 2) + i) * 12);
      final b = 38 + (math.cos((phase * math.pi * 2 * 0.8) + i) * 14);
      final c = 20 + (math.sin((phase * math.pi * 2 * 1.2) + i) * 10);
      final path = Path()
        ..moveTo(
            startX, verticalOffset + laneDrift + _wave(startX, size, speed))
        ..cubicTo(
          startX + size.width * 0.10,
          verticalOffset - a + laneDrift + _wave(startX + 20, size, speed),
          startX + size.width * 0.24,
          verticalOffset + b + breeze + _wave(startX + 80, size, speed),
          startX + size.width * 0.38,
          verticalOffset + laneDrift + _wave(startX + 140, size, speed),
        )
        ..cubicTo(
          startX + size.width * 0.50,
          verticalOffset - (a + 10) + breeze + _wave(startX + 180, size, speed),
          startX + size.width * 0.62,
          verticalOffset + c + laneDrift + _wave(startX + 240, size, speed),
          startX + size.width * 0.78,
          verticalOffset + breeze + _wave(startX + 320, size, speed),
        );

      canvas.drawPath(path, paint);

      final ghostPaint = Paint()
        ..color = colorA.withValues(alpha: opacity * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawPath(
        path.shift(Offset(-28 - (i * 6), 6 + (i * 2))),
        ghostPaint,
      );
    }
  }

  double _wave(double seed, Size size, double speed) {
    final t = (phase * math.pi * 2 * speed) + (seed / size.width * math.pi * 2);
    return (math.sin(t) * 8) +
        (math.cos(t * 0.63) * 6) +
        (math.sin((t * 1.7) + 1.2) * 3.5);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.mode != mode;
}

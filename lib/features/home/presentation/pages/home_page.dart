import 'package:flutter/material.dart';

import '../../data/local_player_state_repository.dart';
import '../../domain/daily_quest.dart';
import '../../domain/hunter_profile.dart';
import '../../domain/player_system_service.dart';
import '../../domain/training_path.dart';
import '../../domain/workout_day.dart';
import '../controllers/home_controller.dart';
import 'hunter_tab.dart';
import 'quest_tab.dart';
import 'stats_tab.dart';
import 'system_tab.dart';
import '../widgets/hud_navigation_bar.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/notification_panel.dart';
import '../widgets/reward_notice_banner.dart';
import '../widgets/section_palette.dart';
import '../widgets/system_backdrop.dart';

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
    HudNavItemData(label: 'Sistema', icon: Icons.home_rounded),
    HudNavItemData(
      label: 'Misiones',
      icon: Icons.assignment_turned_in_rounded,
    ),
    HudNavItemData(label: 'Atributos', icon: Icons.bolt_rounded),
    HudNavItemData(label: 'Jugador', icon: Icons.person_rounded),
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
  static const _system = PlayerSystemService(baseProfile: _profile);
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

  late final HomeController _controller;

  int get _selectedStageIndex => _controller.playerState?.selectedStageIndex ?? 1;
  HunterProfile get _profileState => _controller.playerState?.profile ?? _profile;
  List<DailyQuest> get _quests =>
      _controller.playerState?.quests ?? _system.initialState().quests;
  DailyQuest? get _weeklySpecialQuest => _controller.playerState?.weeklySpecialQuest;
  String get _weeklySpecialStatus =>
      _controller.playerState?.weeklySpecialStatus ?? 'pending';
  Map<String, int> get _inventory =>
      _controller.playerState?.inventory ?? const {};
  bool get _xpBoostArmed => _controller.playerState?.xpBoostArmed ?? false;
  bool get _playerAccepted => _controller.playerState?.playerAccepted ?? false;
  bool get _jobChanged => _controller.playerState?.jobChanged ?? false;
  List<WorkoutDay> get _weeklyPlan => _system.buildWeeklyPlan(_selectedStageIndex);

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      storage: _storage,
      system: _system,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final selectedIndex = _controller.selectedIndex;
        final previousIndex = _controller.previousIndex;

        return Scaffold(
          body: Stack(
            children: [
              SystemBackdrop(mode: selectedIndex),
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, animation) {
                    final key = child.key;
                    final isIncoming = key == ValueKey('tab-$selectedIndex');
                    final fromRight = selectedIndex >= previousIndex;
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
                    key: ValueKey('tab-$selectedIndex'),
                    child: _buildCurrentTab(),
                  ),
                ),
              ),
              if (!_playerAccepted || !_jobChanged)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xCC03080F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
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
                                  onAccept: _controller.acceptPlayer,
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
                                  onAccept: _controller.confirmJobChanged,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_controller.levelUpNotice != null && _playerAccepted && _jobChanged)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      color: const Color(0x2203080F),
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: LevelUpOverlay(
                          level: _controller.levelUpNotice!,
                          primary: _paletteForIndex(selectedIndex).primary,
                          secondary: _paletteForIndex(selectedIndex).secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_controller.rewardNotice != null && _playerAccepted && _jobChanged)
                Positioned(
                  left: 24,
                  right: 24,
                  top: 110,
                  child: IgnorePointer(
                    child: RewardNoticeBanner(
                      message: _controller.rewardNotice!,
                      secondary: _paletteForIndex(selectedIndex).secondary,
                      highlight: _paletteForIndex(selectedIndex).highlight,
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: HudNavigationBar(
            items: _navItems,
            currentIndex: selectedIndex,
            primary: _paletteForIndex(selectedIndex).primary,
            secondary: _paletteForIndex(selectedIndex).secondary,
            highlight: _paletteForIndex(selectedIndex).highlight,
            onTap: _controller.selectTab,
          ),
        );
      },
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
    switch (_controller.selectedIndex) {
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
          onQuestAdvance: _controller.advanceQuest,
          onSpecialAdvance: _controller.advanceSpecialQuest,
          onSpecialDecision: _controller.decideSpecialQuest,
          onUseXpBoost: _controller.useXpBoost,
          onUseReroll: _controller.useReroll,
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
          onStageSelected: _controller.changeStage,
          onUseXpBoost: _controller.useXpBoost,
          onResetProgress: _controller.resetProgress,
          palette: _playerPalette,
        );
      default:
        return SystemTab(
          profile: _profileState,
          quests: _quests,
          weeklyPlan: _weeklyPlan,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onQuestAdvance: _controller.advanceQuest,
          palette: _systemPalette,
        );
    }
  }
}

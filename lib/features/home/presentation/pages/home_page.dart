import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/home_api_client.dart';
import '../../data/local_player_state_repository.dart';
import '../../domain/daily_quest.dart';
import '../../domain/hunter_profile.dart';
import '../../domain/player_system_service.dart';
import '../../domain/training_path.dart';
import '../../domain/workout_day.dart';
import '../../../player/application/bootstrap_player_controller.dart';
import '../../../player/application/bootstrap_player_state.dart';
import '../../../player/domain/player_snapshot.dart';
import '../../../shadows/domain/shadow_catalog.dart';
import '../../../shadows/domain/shadow_entity.dart';
import '../../../shadows/presentation/widgets/shadow_unlock_overlay.dart';
import '../controllers/home_controller.dart';
import 'hunter_tab.dart';
import 'quest_tab.dart';
import 'stats_tab.dart';
import 'system_tab.dart';
import '../widgets/class_evolution_overlay.dart';
import '../widgets/chest_reward_overlay.dart';
import '../widgets/hud_navigation_bar.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/notification_panel.dart';
import '../widgets/reward_notice_banner.dart';
import '../widgets/section_palette.dart';
import '../widgets/system_backdrop.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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

  HomeController? _controller;
  late final AppLogger _logger;
  late final ProviderSubscription<BootstrapPlayerState> _bootstrapSubscription;
  String? _startupFailureMessage;

  int get _selectedStageIndex => _controller?.playerState?.selectedStageIndex ?? 1;
  HunterProfile get _profileState => _controller?.playerState?.profile ?? _profile;
  List<DailyQuest> get _quests =>
      _controller?.playerState?.quests ?? _system.initialState().quests;
  DailyQuest? get _weeklySpecialQuest => _controller?.playerState?.weeklySpecialQuest;
  String get _weeklySpecialStatus =>
      _controller?.playerState?.weeklySpecialStatus ?? 'pending';
  Map<String, int> get _inventory =>
      _controller?.playerState?.inventory ?? const {};
  List<String> get _unlockedShadowIds =>
      _controller?.playerState?.unlockedShadowIds ?? const <String>[];
  String get _lastUnlockedShadowId =>
      _controller?.playerState?.lastUnlockedShadowId ?? '';
  List<String>? get _pendingChestRewards => _controller?.pendingChestRewards;
  ShadowEntity? get _pendingUnlockedShadow {
    final shadowId = _controller?.pendingUnlockedShadowId;
    if (shadowId == null || shadowId.isEmpty) {
      return null;
    }

    for (final entry in ShadowCatalog.initialRoster) {
      if (entry.shadow.id == shadowId) {
        return entry.shadow;
      }
    }

    return null;
  }
  bool get _xpBoostArmed => _controller?.playerState?.xpBoostArmed ?? false;
  bool get _playerAccepted => _controller?.playerState?.playerAccepted ?? false;
  bool get _jobChanged => _controller?.playerState?.jobChanged ?? false;
  List<WorkoutDay> get _weeklyPlan => _system.buildWeeklyPlan(_selectedStageIndex);

  @override
  void initState() {
    super.initState();
    _logger = ref.read(appLoggerProvider);
    _bootstrapSubscription = ref.listenManual<BootstrapPlayerState>(
      bootstrapPlayerControllerProvider,
      _handleBootstrapStateChanged,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startBootstrapLoad(reason: 'initial');
    });
  }

  @override
  void dispose() {
    _bootstrapSubscription.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapState = ref.watch(bootstrapPlayerControllerProvider);

    if (_controller == null) {
      return _buildBootstrapScaffold(bootstrapState);
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, _) {
        if (_controller!.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final selectedIndex = _controller!.selectedIndex;
        final previousIndex = _controller!.previousIndex;
        final unlockedShadow = _pendingUnlockedShadow;
        final chestRewards = _pendingChestRewards;
        final pendingLevelUp = _controller!.pendingLevelUp;
        final pendingClassEvolution = _controller!.pendingClassEvolution;
        final hasCeremonialOverlay =
            pendingClassEvolution != null ||
            unlockedShadow != null ||
            chestRewards != null ||
            pendingLevelUp != null;

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
                                  onAccept: _controller!.acceptPlayer,
                                )
                              : NotificationPanel(
                                  key: const ValueKey('job-change'),
                                  title: 'Asignacion de clase',
                                  lines: const [
                                    'Clase inicial asignada por el Sistema.',
                                    '[ humano novato ]',
                                    'Tu progreso fisico y tu disciplina definiran tu proxima evolucion.',
                                  ],
                                  ctaLabel: '[ Continuar ]',
                                  emphasisColor: const Color(0xFF25F3B4),
                                  onAccept: _controller!.confirmJobChanged,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (pendingClassEvolution != null && _playerAccepted && _jobChanged)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xC4060A10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ClassEvolutionOverlay(
                        previousClass: pendingClassEvolution.previousClass,
                        nextClass: pendingClassEvolution.nextClass,
                        palette: _paletteForIndex(selectedIndex),
                        onDismiss: _controller!.clearClassEvolutionNotice,
                      ),
                    ),
                  ),
                ),
              if (_controller!.rewardNotice != null &&
                  _playerAccepted &&
                  _jobChanged &&
                  !hasCeremonialOverlay)
                Positioned(
                  left: 24,
                  right: 24,
                  top: 110,
                  child: IgnorePointer(
                    child: RewardNoticeBanner(
                      message: _controller!.rewardNotice!,
                      secondary: _paletteForIndex(selectedIndex).secondary,
                      highlight: _paletteForIndex(selectedIndex).highlight,
                    ),
                  ),
                ),
              if (chestRewards != null &&
                  pendingClassEvolution == null &&
                  unlockedShadow == null &&
                  _playerAccepted &&
                  _jobChanged)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xC4060A10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ChestRewardOverlay(
                        rewards: chestRewards,
                        palette: _paletteForIndex(selectedIndex),
                        onDismiss: _controller!.clearChestRewardNotice,
                      ),
                    ),
                  ),
                ),
              if (unlockedShadow != null &&
                  pendingClassEvolution == null &&
                  _playerAccepted &&
                  _jobChanged)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xC4060A10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ShadowUnlockOverlay(
                        shadow: unlockedShadow,
                        palette: _paletteForIndex(selectedIndex),
                        onDismiss: _controller!.clearUnlockedShadowNotice,
                      ),
                    ),
                  ),
                ),
              if (pendingLevelUp != null &&
                  pendingClassEvolution == null &&
                  unlockedShadow == null &&
                  chestRewards == null &&
                  _playerAccepted &&
                  _jobChanged)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: const Color(0xC4060A10),
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: LevelUpOverlay(
                        level: pendingLevelUp,
                        primary: _paletteForIndex(selectedIndex).primary,
                        secondary: _paletteForIndex(selectedIndex).secondary,
                        onDismiss: _controller!.clearLevelUpNotice,
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
            onTap: _controller!.selectTab,
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

  void _handleBootstrapStateChanged(
    BootstrapPlayerState? previous,
    BootstrapPlayerState next,
  ) {
    if (next.isLoading && previous?.isLoading != true) {
      _logger.info(
        event: 'bootstrap_loading_started',
        source: 'home.page',
      );
    }

    if (!next.isLoading &&
        next.snapshot != null &&
        previous?.snapshot != next.snapshot &&
        _controller == null) {
      _logger.info(
        event: 'bootstrap_loading_succeeded',
        source: 'home.page',
        context: <String, Object?>{
          'alias': next.snapshot!.alias,
          'completedDays': next.snapshot!.completedDays,
        },
      );
      unawaited(_initializeHomeController(next.snapshot!));
    }

    if (!next.isLoading &&
        next.errorMessage != null &&
        previous?.errorMessage != next.errorMessage) {
      _logger.warning(
        event: 'bootstrap_loading_failed',
        source: 'home.page',
        context: <String, Object?>{
          'message': next.errorMessage,
        },
      );
    }
  }

  void _startBootstrapLoad({required String reason}) {
    if (_startupFailureMessage != null) {
      setState(() {
        _startupFailureMessage = null;
      });
    }
    _logger.info(
      event: 'bootstrap_load_requested',
      source: 'home.page',
      context: <String, Object?>{
        'reason': reason,
      },
    );
    ref.read(bootstrapPlayerControllerProvider.notifier).load();
  }

  Future<void> _initializeHomeController(PlayerSnapshot snapshot) async {
    final controller = HomeController(
      storage: _storage,
      system: _system,
      apiClient: HomeApiClient(baseUrl: ref.read(apiBaseUrlProvider)),
      logger: _logger,
    );

    setState(() {
      _controller = controller;
    });

    try {
      await controller.load(bootstrapSnapshot: snapshot);
    } catch (error) {
      _logger.error(
        event: 'home_controller_load_failed',
        source: 'home.page',
        context: <String, Object?>{
          'error': error.toString(),
        },
      );
      controller.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _controller = null;
        _startupFailureMessage =
            'No se pudo preparar el progreso local del jugador. Reintenta la sincronizacion.';
      });
    }
  }

  Widget _buildBootstrapScaffold(BootstrapPlayerState bootstrapState) {
    final failureMessage = _startupFailureMessage ?? bootstrapState.errorMessage;
    if (failureMessage != null && !bootstrapState.isLoading) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sync_problem_rounded,
                    size: 54,
                    color: Color(0xFF79E7FF),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No se pudo iniciar el Sistema',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    failureMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Color(0xFFB7C7D9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _startBootstrapLoad(reason: 'retry'),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final message = bootstrapState.snapshot == null
        ? 'Iniciando enlace con el Sistema...'
        : 'Sincronizando progreso del jugador...';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_controller!.selectedIndex) {
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
          onQuestAdvance: _controller!.advanceQuest,
          onSpecialAdvance: _controller!.advanceSpecialQuest,
          onSpecialDecision: _controller!.decideSpecialQuest,
          onUseXpBoost: _controller!.useXpBoost,
          onUseReroll: _controller!.useReroll,
          palette: _questPalette,
        );
      case 2:
        return StatsTab(
            profile: _profileState,
            trainingPath: _trainingPath,
            selectedStageIndex: _selectedStageIndex,
            unlockedShadowIds: _unlockedShadowIds,
            lastUnlockedShadowId: _lastUnlockedShadowId,
            palette: _statsPalette,
          );
      case 3:
        return HunterTab(
          profile: _profileState,
          inventory: _inventory,
          xpBoostArmed: _xpBoostArmed,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onStageSelected: _controller!.changeStage,
          onUseXpBoost: _controller!.useXpBoost,
          onUpdateAvatar: _controller!.updateAvatarUrl,
          onUpdateLocalAvatar: _controller!.updateAvatarImageBase64,
          onResetProgress: _controller!.resetProgress,
          palette: _playerPalette,
        );
      default:
        return SystemTab(
          profile: _profileState,
          quests: _quests,
          weeklyPlan: _weeklyPlan,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onQuestAdvance: _controller!.advanceQuest,
          palette: _systemPalette,
        );
    }
  }
}

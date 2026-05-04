import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../home/data/home_api_client.dart';
import '../../../home/data/local_player_state_repository.dart';
import '../../../home/domain/daily_quest.dart';
import '../../../home/domain/hunter_profile.dart';
import '../../../home/domain/player_system_service.dart';
import '../../../home/domain/training_path.dart';
import '../../../home/domain/workout_day.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/pages/hunter_tab.dart';
import '../../../home/presentation/pages/stats_tab.dart';
import '../../../home/presentation/pages/system_tab.dart';
import '../../../home/presentation/widgets/hud_navigation_bar.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../../inventory/application/inventory_action_handler.dart';
import '../../../inventory/application/inventory_controller.dart';
import '../../../inventory/presentation/widgets/chest_reward_overlay.dart';
import '../../../player/application/bootstrap_player_controller.dart';
import '../../../player/application/bootstrap_player_state.dart';
import '../../../player/domain/player_snapshot.dart';
import '../../../shadows/domain/shadow_catalog.dart';
import '../../../shadows/domain/shadow_entity.dart';
import '../../../shadows/presentation/widgets/shadow_unlock_overlay.dart';
import '../../../system/application/system_overlay_controller.dart';
import '../../../system/application/system_overlay_state.dart';
import '../../../system/presentation/widgets/system_overlay_stack.dart';
import '../../../quests/application/quest_action_handler.dart';
import '../../../quests/application/quest_actions_controller.dart';
import '../../../quests/presentation/pages/quests_page.dart';
import '../../application/app_shell_controller.dart';
import '../../application/app_shell_state.dart';
import '../widgets/app_shell_frame.dart';

class AppShellPage extends ConsumerStatefulWidget {
  const AppShellPage({super.key});

  @override
  ConsumerState<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends ConsumerState<AppShellPage> {
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
    final shellState = ref.watch(appShellControllerProvider);
    final systemOverlayState = ref.watch(systemOverlayControllerProvider);

    if (_controller == null) {
      return _buildBootstrapScaffold(shellState, bootstrapState);
    }

      return ListenableBuilder(
        listenable: _controller!,
        builder: (context, _) {
          _syncSystemOverlayState();

          final selectedIndex = shellState.selectedTabIndex;
          final pendingLevelUp = _controller!.pendingLevelUp;
          final pendingClassEvolution = _controller!.pendingClassEvolution;
          final unlockedShadow = _pendingUnlockedShadow;

          return ProviderScope(
            overrides: [
              inventoryActionHandlerProvider.overrideWithValue(
                InventoryActionHandler(
                  useXpBoost: _controller!.useXpBoost,
                  useReroll: _controller!.useReroll,
                  clearChestRewards: _controller!.clearChestRewardNotice,
                ),
              ),
            ],
            child: Consumer(
              builder: (context, scopedRef, _) {
                _syncInventoryState(scopedRef);
                final inventoryState = scopedRef.watch(inventoryControllerProvider);
                final chestRewards = inventoryState.chestRewards;
                final hasSystemOverlay =
                    systemOverlayState.visibleOverlay != SystemOverlayKind.none;

                return Stack(
                  children: [
                    AppShellFrame(
                      selectedTabIndex: selectedIndex,
                      previousTabIndex: shellState.previousTabIndex,
                      currentTab: _buildCurrentTab(selectedIndex),
                      bottomNavigationBar: HudNavigationBar(
                        items: _navItems,
                        currentIndex: selectedIndex,
                        primary: _paletteForIndex(selectedIndex).primary,
                        secondary: _paletteForIndex(selectedIndex).secondary,
                        highlight: _paletteForIndex(selectedIndex).highlight,
                        onTap: (index) {
                          ref
                              .read(appShellControllerProvider.notifier)
                              .selectTab(index);
                        },
                      ),
                    ),
                    SystemOverlayStack(
                      state: systemOverlayState,
                      palette: _paletteForIndex(selectedIndex),
                      playerAccepted: _playerAccepted,
                      jobChanged: _jobChanged,
                      rewardNotice: _controller!.rewardNotice,
                      pendingLevelUp: pendingLevelUp,
                      pendingClassEvolution: pendingClassEvolution,
                      onAcceptPlayer: _controller!.acceptPlayer,
                      onConfirmJobChanged: _controller!.confirmJobChanged,
                      onDismissLevelUp: _controller!.clearLevelUpNotice,
                      onDismissClassEvolution:
                          _controller!.clearClassEvolutionNotice,
                    ),
                    if (!hasSystemOverlay && chestRewards != null)
                      _buildCeremonialOverlay(
                        child: ChestRewardOverlay(
                          rewards: chestRewards,
                          palette: _paletteForIndex(selectedIndex),
                          onDismiss: () => scopedRef
                              .read(inventoryControllerProvider.notifier)
                              .dismissChestRewards(),
                        ),
                      ),
                    if (!hasSystemOverlay &&
                        chestRewards == null &&
                        unlockedShadow != null)
                      _buildCeremonialOverlay(
                        child: ShadowUnlockOverlay(
                          shadow: unlockedShadow,
                          palette: _paletteForIndex(selectedIndex),
                          onDismiss: _controller!.clearUnlockedShadowNotice,
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      );
  }

  void _handleBootstrapStateChanged(
    BootstrapPlayerState? previous,
    BootstrapPlayerState next,
  ) {
    if (next.isLoading && previous?.isLoading != true) {
      _logger.info(
        event: 'bootstrap_loading_started',
        source: 'app_shell.page',
      );
      ref.read(appShellControllerProvider.notifier).markBootstrapping();
    }

    if (!next.isLoading &&
        next.snapshot != null &&
        previous?.snapshot != next.snapshot &&
        _controller == null) {
      _logger.info(
        event: 'bootstrap_loading_succeeded',
        source: 'app_shell.page',
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
        source: 'app_shell.page',
        context: <String, Object?>{
          'message': next.errorMessage,
        },
      );
      ref
          .read(appShellControllerProvider.notifier)
          .markFailed(next.errorMessage!);
    }
  }

  void _startBootstrapLoad({required String reason}) {
    ref.read(appShellControllerProvider.notifier).markBootstrapping();
    _logger.info(
      event: 'bootstrap_load_requested',
      source: 'app_shell.page',
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
      if (!mounted) {
        return;
      }
      ref.read(appShellControllerProvider.notifier).markReady();
    } catch (error) {
      _logger.error(
        event: 'home_controller_load_failed',
        source: 'app_shell.page',
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
      });
      ref.read(appShellControllerProvider.notifier).markFailed(
        'No se pudo preparar el progreso local del jugador. Reintenta la sincronizacion.',
      );
    }
  }

  void _syncSystemOverlayState() {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller == null) {
        return;
      }
      ref.read(systemOverlayControllerProvider.notifier).syncFromGame(
        playerAccepted: _playerAccepted,
        jobChanged: _jobChanged,
        hasPendingClassEvolution: controller.pendingClassEvolution != null,
        hasPendingLevelUp: controller.pendingLevelUp != null,
        hasRewardNotice: controller.rewardNotice != null,
      );
    });
  }

  void _syncInventoryState(WidgetRef providerRef) {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller == null) {
        return;
      }
      providerRef
          .read(inventoryControllerProvider.notifier)
          .syncChestRewards(controller.pendingChestRewards);
    });
  }

  Widget _buildBootstrapScaffold(
    AppShellState shellState,
    BootstrapPlayerState bootstrapState,
  ) {
    final failureMessage =
        shellState.startupErrorMessage ?? bootstrapState.errorMessage;
    if (failureMessage != null &&
        shellState.startupPhase == AppShellStartupPhase.failed &&
        !bootstrapState.isLoading) {
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

  Widget _buildCeremonialOverlay({required Widget child}) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xC4060A10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Center(child: child),
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

  Widget _buildCurrentTab(int selectedIndex) {
    switch (selectedIndex) {
      case 1:
        return ProviderScope(
          overrides: [
            questActionHandlerProvider.overrideWithValue(
              QuestActionHandler(
                advanceQuest: _controller!.advanceQuest,
                advanceSpecialQuest: _controller!.advanceSpecialQuest,
                decideSpecialQuest: _controller!.decideSpecialQuest,
              ),
            ),
          ],
          child: QuestsPage(
            profile: _profileState,
            quests: _quests,
            specialQuest: _weeklySpecialQuest,
            specialQuestStatus: _weeklySpecialStatus,
            inventory: _inventory,
            xpBoostArmed: _xpBoostArmed,
            trainingPath: _trainingPath,
            selectedStageIndex: _selectedStageIndex,
            palette: _questPalette,
          ),
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

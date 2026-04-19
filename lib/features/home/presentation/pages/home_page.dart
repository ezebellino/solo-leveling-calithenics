import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/daily_quest.dart';
import '../../domain/hunter_profile.dart';
import '../../domain/training_path.dart';
import '../../domain/workout_day.dart';
import '../widgets/holographic_panel.dart';
import '../widgets/notification_panel.dart';
import '../widgets/stat_hex_tile.dart';
import '../widgets/system_badge.dart';

class _SectionPalette {
  const _SectionPalette({
    required this.primary,
    required this.secondary,
    required this.highlight,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _systemPalette = _SectionPalette(
    primary: Color(0xFF79E7FF),
    secondary: Color(0xFF25F3B4),
    highlight: Color(0xFFB7F2FF),
  );
  static const _questPalette = _SectionPalette(
    primary: Color(0xFF4DF0FF),
    secondary: Color(0xFF24FFAE),
    highlight: Color(0xFFDCFFF6),
  );
  static const _statsPalette = _SectionPalette(
    primary: Color(0xFF6DDCFF),
    secondary: Color(0xFF7AB8FF),
    highlight: Color(0xFFD7EEFF),
  );
  static const _playerPalette = _SectionPalette(
    primary: Color(0xFF8ED8FF),
    secondary: Color(0xFF7AF0D4),
    highlight: Color(0xFFF3FBFF),
  );

  static const _profile = HunterProfile(
    alias: 'Eze Bellino',
    rank: 'E-Rank',
    title: 'Jugador de calistenia',
    level: 8,
    currentXp: 620,
    nextLevelXp: 1000,
    streakDays: 5,
    shadowArmy: 3,
    strength: 18,
    agility: 14,
    endurance: 16,
    discipline: 21,
  );

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

  static const _quests = [
    DailyQuest(
      title: 'Mision diaria: Entrenamiento de fuerza',
      detail:
          '50 flexiones, 50 sentadillas, 50 abdominales y 3 km de caminata.',
      rewardXp: 120,
      progress: 32,
      target: 50,
    ),
    DailyQuest(
      title: 'Disciplina de sombra',
      detail:
          'Sostene hollow hold y cadencia de respiracion durante 90 segundos.',
      rewardXp: 90,
      progress: 45,
      target: 90,
    ),
    DailyQuest(
      title: 'Registro de recuperacion',
      detail: 'Registra sueno, fatiga y peso corporal antes de la medianoche.',
      rewardXp: 60,
      progress: 1,
      target: 1,
    ),
  ];

  var _selectedIndex = 0;
  var _selectedStageIndex = 1;
  var _previousIndex = 0;
  var _playerAccepted = false;
  var _jobChanged = false;

  List<WorkoutDay> get _weeklyPlan => _buildWeeklyPlan(_selectedStageIndex);

  @override
  Widget build(BuildContext context) {
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
                                setState(() {
                                  _playerAccepted = true;
                                });
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
                                setState(() {
                                  _jobChanged = true;
                                });
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _previousIndex = _selectedIndex;
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Sistema',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_rounded),
              label: 'Misiones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_rounded),
              label: 'Atributos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Jugador',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 1:
        return _QuestTab(
          profile: _profile,
          quests: _quests,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          palette: _questPalette,
        );
      case 2:
        return _StatsTab(
          profile: _profile,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          palette: _statsPalette,
        );
      case 3:
        return _HunterTab(
          profile: _profile,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          onStageSelected: _handleStageSelected,
          palette: _playerPalette,
        );
      default:
        return _SystemTab(
          profile: _profile,
          quests: _quests,
          weeklyPlan: _weeklyPlan,
          trainingPath: _trainingPath,
          selectedStageIndex: _selectedStageIndex,
          palette: _systemPalette,
        );
    }
  }

  void _handleStageSelected(int index) {
    setState(() {
      _selectedStageIndex = index;
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

class _SystemTab extends StatelessWidget {
  const _SystemTab({
    required this.profile,
    required this.quests,
    required this.weeklyPlan,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.palette,
  });

  final HunterProfile profile;
  final List<DailyQuest> quests;
  final List<WorkoutDay> weeklyPlan;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ScreenFrame(
      palette: palette,
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
                  Shadow(
                    color: Color(0xCC02070D),
                    blurRadius: 10,
                  ),
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
                    Shadow(
                      color: Color(0xCC02070D),
                      blurRadius: 10,
                    ),
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
                    Shadow(
                      color: Color(0xCC02070D),
                      blurRadius: 12,
                    ),
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
                          colors: [
                            palette.primary,
                            palette.secondary,
                          ],
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
        ...quests
            .take(2)
            .map((quest) => _QuestCard(quest: quest, palette: palette)),
        const SizedBox(height: 18),
        Text(
          'CICLO DE ENTRENAMIENTO',
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
            children: weeklyPlan
                .map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            day.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            day.focus,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          day.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: day.isCompleted
                              ? palette.secondary
                              : Colors.white38,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'CAMINO DEL CAZADOR',
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
                trainingPath.currentBlock.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.secondary,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trainingPath.summary,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ...trainingPath.stages.take(3).map(
                (stage) => _TrainingStageTile(
                  stage: stage,
                  palette: palette,
                  isActive: trainingPath.stages[selectedStageIndex].title ==
                      stage.title,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestTab extends StatelessWidget {
  const _QuestTab({
    required this.profile,
    required this.quests,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.palette,
  });

  final HunterProfile profile;
  final List<DailyQuest> quests;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ScreenFrame(
      palette: palette,
      children: [
        SystemBadge(label: 'Notificacion', glowColor: palette.primary),
        const SizedBox(height: 18),
        NotificationPanel(
          title: 'Notificacion',
          lines: const [
            '[ Ha llegado la mision diaria: Entrenamiento de fuerza. ]',
            'Fallar reducira tu racha y tu impulso.',
          ],
          ctaLabel: '[ Comenzar mision ]',
          emphasisColor: palette.secondary,
          onAccept: () {},
        ),
        const SizedBox(height: 18),
        Text(
          'REGISTRO DE MISIONES',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 2.4,
            color: palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...quests.map((quest) => _QuestCard(quest: quest, palette: palette)),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decorate: false,
          showCorners: false,
          child: Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Botin XP',
                  value:
                      '${quests.fold<int>(0, (sum, q) => sum + q.rewardXp)} XP',
                  accent: palette.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MiniMetric(
                  label: 'Racha actual',
                  value: '${profile.streakDays} dias',
                  accent: palette.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'BLOQUE OPTIMO ACTUAL',
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
                'Rutina base para crecimiento constante',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _stagePrescription(trainingPath.stages[selectedStageIndex]),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _TrainingBullet(
                accent: palette.secondary,
                text:
                    'Dia A: dominada asistida, flexion inclinada, remo australiano, sentadilla y hollow hold.',
              ),
              _TrainingBullet(
                accent: palette.primary,
                text:
                    'Dia B: repetir patron con un poco menos de asistencia o mas rango de movimiento.',
              ),
              _TrainingBullet(
                accent: palette.secondary,
                text:
                    'Dia C: consolidar tecnica, registrar reps y decidir si toca subir ejercicio o mantener bloque.',
              ),
              const SizedBox(height: 14),
              Text(
                trainingPath.rules.first.detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _stagePrescription(TrainingStage stage) {
    switch (stage.title) {
      case 'Pre Beginner':
        return 'En esta etapa la guia recomienda 2 o 3 sesiones con ejercicios asistidos y faciles, priorizando fuerza minima y adaptacion articular antes de buscar volumen.';
      case 'Intermediate':
        return 'En intermedio conviene pasar a 4 sesiones con variantes mas desafiantes, manteniendo tecnica limpia y una base de movilidad para hombros y escápulas.';
      case 'Advanced':
        return 'En avanzado ya se justifica separar fuerza, skill y resistencia, pero sin perder una sesion de movilidad ni reforzar progresiones antes de cada truco.';
      case 'Expert / Pro':
        return 'En experto la progresion deja de ser lineal: la semana se organiza por bloques especificos y necesita descarga planificada para sostener rendimiento.';
      default:
        return 'La guia apunta a una base full body de 3 dias cuando el objetivo es progresar de forma sostenida sin quemar articulaciones ni saltarse adaptaciones.';
    }
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({
    required this.profile,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.palette,
  });

  final HunterProfile profile;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ScreenFrame(
      palette: palette,
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
              _StatBar(
                  label: 'Fuerza',
                  value: profile.strength,
                  max: 30,
                  palette: palette),
              _StatBar(
                  label: 'Agilidad',
                  value: profile.agility,
                  max: 30,
                  palette: palette),
              _StatBar(
                  label: 'Resistencia',
                  value: profile.endurance,
                  max: 30,
                  palette: palette),
              _StatBar(
                  label: 'Disciplina',
                  value: profile.discipline,
                  max: 30,
                  palette: palette),
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
                  child: _ProgressRuleTile(rule: rule, palette: palette),
                ),
              ),
              _ProgressRuleTile(
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
      ],
    );
  }
}

class _HunterTab extends StatelessWidget {
  const _HunterTab({
    required this.profile,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.onStageSelected,
    required this.palette,
  });

  final HunterProfile profile;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final ValueChanged<int> onStageSelected;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ScreenFrame(
      palette: palette,
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
                  _HunterAvatar(alias: profile.alias, accent: palette.primary),
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
              _ProfileLine(
                label: 'Clase',
                value: 'Jugador progresivo de calistenia',
                accent: palette.primary,
              ),
              SizedBox(height: 12),
              _ProfileLine(
                label: 'Especializacion',
                value: 'Fuerza con peso corporal + disciplina de habito',
                accent: palette.secondary,
              ),
              SizedBox(height: 12),
              _ProfileLine(
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  trainingPath.stages.length,
                  (index) => _StageChip(
                    label: trainingPath.stages[index].title,
                    isSelected: index == selectedStageIndex,
                    accent: index == selectedStageIndex
                        ? palette.secondary
                        : palette.primary,
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
                (stage) => _TrainingStageTile(
                  stage: stage,
                  palette: palette,
                  isActive: trainingPath.stages[selectedStageIndex].title ==
                      stage.title,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrainingStageTile extends StatelessWidget {
  const _TrainingStageTile({
    required this.stage,
    required this.palette,
    this.isActive = false,
    this.compact = false,
  });

  final TrainingStage stage;
  final _SectionPalette palette;
  final bool isActive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isActive
        ? palette.secondary
        : (stage.isCurrent ? palette.secondary : palette.primary);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      padding: EdgeInsets.fromLTRB(16, compact ? 14 : 16, 16, compact ? 14 : 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isActive ? 0.08 : 0.03),
        border: Border.all(color: accent.withValues(alpha: isActive ? 0.42 : 0.26)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${stage.tier} · ${stage.title}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (stage.isCurrent || isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    isActive ? 'Seleccionado' : 'Actual',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stage.goal,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Frecuencia: ${stage.frequency}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Foco: ${stage.focus}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              'Salida: ${stage.exitRule}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({
    required this.palette,
    required this.children,
  });

  final _SectionPalette palette;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 420 ? 10.0 : 18.0;
        final innerPadding = width < 420 ? 14.0 : 18.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            110,
          ),
          children: [
            CustomPaint(
              painter: _FramePainter(palette: palette),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  innerPadding,
                  22,
                  innerPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter({required this.palette});

  final _SectionPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final innerRect = Rect.fromLTWH(15, 44, size.width - 30, size.height - 58);

    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.secondary.withValues(alpha: 0.58),
          palette.primary,
          palette.secondary.withValues(alpha: 0.52),
        ],
      ).createShader(outerRect)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(outerRect.inflate(1.5), glowPaint);
    canvas.drawRect(outerRect, borderPaint);

    final innerPaint = Paint()
      ..color = palette.primary.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(innerRect, innerPaint);

    final topBarPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.secondary.withValues(alpha: 0.0),
          palette.primary.withValues(alpha: 0.75),
          palette.highlight.withValues(alpha: 0.95),
          palette.primary.withValues(alpha: 0.75),
          palette.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.14, 0, size.width * 0.72, 10))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;

    canvas.drawLine(
      Offset(size.width * 0.16, 8),
      Offset(size.width * 0.84, 8),
      topBarPaint,
    );

    final topGlowPaint = Paint()
      ..color = palette.highlight.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
    canvas.drawLine(
      Offset(size.width * 0.22, 10),
      Offset(size.width * 0.78, 10),
      topGlowPaint,
    );

    _drawFrameCorner(canvas, const Offset(6, 10), top: true, left: true);
    _drawFrameCorner(
      canvas,
      Offset(size.width - 42, 10),
      top: true,
      left: false,
    );
    _drawFrameCorner(
      canvas,
      Offset(6, size.height - 42),
      top: false,
      left: true,
    );
    _drawFrameCorner(
      canvas,
      Offset(size.width - 42, size.height - 42),
      top: false,
      left: false,
    );

    final sideGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.primary.withValues(alpha: 0.0),
          palette.primary.withValues(alpha: 0.18),
          palette.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.16, 8, size.height * 0.68));
    canvas.drawRect(
      Rect.fromLTWH(4, size.height * 0.16, 3, size.height * 0.68),
      sideGlow,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 7, size.height * 0.16, 3, size.height * 0.68),
      sideGlow,
    );
  }

  void _drawFrameCorner(
    Canvas canvas,
    Offset origin, {
    required bool top,
    required bool left,
  }) {
    final width = 36.0;
    final height = 30.0;
    final path = Path()
      ..moveTo(origin.dx + (left ? 0 : width), origin.dy + (top ? height * 0.55 : 0))
      ..lineTo(origin.dx + (left ? 0 : width), origin.dy + (top ? 0 : height))
      ..lineTo(origin.dx + (left ? width * 0.62 : width * 0.38), origin.dy + (top ? 0 : height))
      ..moveTo(origin.dx + (left ? 0 : width), origin.dy + (top ? height * 0.82 : height * 0.18))
      ..lineTo(origin.dx + (left ? width * 0.22 : width * 0.78), origin.dy + (top ? height * 0.82 : height * 0.18))
      ..lineTo(origin.dx + (left ? width * 0.22 : width * 0.78), origin.dy + (top ? height : 0))
      ..moveTo(origin.dx + (left ? width * 0.82 : width * 0.18), origin.dy + (top ? 0 : height))
      ..lineTo(origin.dx + (left ? width * 0.82 : width * 0.18), origin.dy + (top ? height * 0.22 : height * 0.78))
      ..lineTo(origin.dx + (left ? width : 0), origin.dy + (top ? height * 0.22 : height * 0.78));

    final glow = Paint()
      ..color = palette.primary.withValues(alpha: 0.24)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final paint = Paint()
      ..color = palette.primary.withValues(alpha: 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isSelected ? 0.16 : 0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: accent.withValues(alpha: isSelected ? 0.48 : 0.22),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? accent : Colors.white70,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _ProgressRuleTile extends StatelessWidget {
  const _ProgressRuleTile({
    required this.rule,
    required this.palette,
  });

  final TrainingRule rule;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: palette.primary.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rule.title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.primary,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rule.detail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingBullet extends StatelessWidget {
  const _TrainingBullet({
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatefulWidget {
  const _QuestCard({required this.quest, required this.palette});

  final DailyQuest quest;
  final _SectionPalette palette;

  @override
  State<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<_QuestCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.99 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _pressed ? 0.94 : 1,
            child: HolographicPanel(
              glowColor: widget.palette.primary,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
              borderRadius: 22,
              cornerInset: 8,
              cornerSize: 16,
              decorate: false,
              showCorners: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.quest.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0xCC02070D),
                          blurRadius: 14,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.quest.detail,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.45,
                      shadows: const [
                        Shadow(
                          color: Color(0xCC02070D),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x6679E7FF)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor:
                                  widget.quest.completionRate.clamp(0, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.palette.primary,
                                      widget.palette.secondary,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.quest.rewardXp} XP',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: widget.palette.secondary,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.quest.progress}/${widget.quest.target} completado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.max,
    required this.palette,
  });

  final String label;
  final int value;
  final int max;
  final _SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              Text(
                '$value',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 11,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x5579E7FF)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value / max,
                child: Container(color: palette.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    this.accent = const Color(0xFF79E7FF),
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: accent.withValues(alpha: 0.90),
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({
    required this.label,
    required this.value,
    this.accent = const Color(0xFF79E7FF),
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: accent,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _HunterAvatar extends StatelessWidget {
  const _HunterAvatar({required this.alias, required this.accent});

  final String alias;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3379E7FF),
            blurRadius: 18,
          ),
        ],
      ),
      child: Text(
        alias.substring(0, 1),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
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
      1 => const _SectionPalette(
          primary: Color(0xFF4DF0FF),
          secondary: Color(0xFF24FFAE),
          highlight: Color(0xFFDCFFF6),
        ),
      2 => const _SectionPalette(
          primary: Color(0xFF6DDCFF),
          secondary: Color(0xFF7AB8FF),
          highlight: Color(0xFFD7EEFF),
        ),
      3 => const _SectionPalette(
          primary: Color(0xFF8ED8FF),
          secondary: Color(0xFF7AF0D4),
          highlight: Color(0xFFF3FBFF),
        ),
      _ => const _SectionPalette(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/domain/daily_quest.dart';
import '../../../home/domain/hunter_profile.dart';
import '../../../home/domain/training_path.dart';
import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/screen_frame.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../../home/presentation/widgets/system_badge.dart';
import '../../../home/presentation/widgets/training_widgets.dart';
import '../../../inventory/presentation/widgets/inventory_panel.dart';
import '../../../system/presentation/widgets/system_notification_panel.dart';
import '../../application/quest_actions_controller.dart';
import '../widgets/quest_card.dart';

class QuestsPage extends ConsumerStatefulWidget {
  const QuestsPage({
    required this.profile,
    required this.quests,
    required this.specialQuest,
    required this.specialQuestStatus,
    required this.inventory,
    required this.xpBoostArmed,
    required this.trainingPath,
    required this.selectedStageIndex,
    required this.palette,
    super.key,
  });

  final HunterProfile profile;
  final List<DailyQuest> quests;
  final DailyQuest? specialQuest;
  final String specialQuestStatus;
  final Map<String, int> inventory;
  final bool xpBoostArmed;
  final TrainingPath trainingPath;
  final int selectedStageIndex;
  final SectionPalette palette;

  @override
  ConsumerState<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends ConsumerState<QuestsPage> {
  var _dailyNotificationDismissed = false;
  String? _specialQuestStatusOverride;
  String? _specialQuestFeedback;

  @override
  void didUpdateWidget(covariant QuestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPrimaryQuest = oldWidget.quests.isEmpty ? null : oldWidget.quests.first;
    final newPrimaryQuest = widget.quests.isEmpty ? null : widget.quests.first;
    if (newPrimaryQuest != null &&
        (oldPrimaryQuest == null ||
            newPrimaryQuest.id != oldPrimaryQuest.id ||
            newPrimaryQuest.progress < oldPrimaryQuest.progress)) {
      _dailyNotificationDismissed = false;
    }
    if (widget.specialQuestStatus != oldWidget.specialQuestStatus) {
      _specialQuestStatusOverride = null;
      _specialQuestFeedback = null;
      ref.read(questActionsControllerProvider.notifier).clearFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSpecialQuestStatus =
        _specialQuestStatusOverride ?? widget.specialQuestStatus;
    final questActionState = ref.watch(questActionsControllerProvider);
    final questActionController = ref.read(
      questActionsControllerProvider.notifier,
    );

    return ScreenFrame(
      primary: widget.palette.primary,
      secondary: widget.palette.secondary,
      highlight: widget.palette.highlight,
      children: [
        if (!_dailyNotificationDismissed) ...[
          SystemBadge(
            label: 'Notificacion',
            glowColor: widget.palette.primary,
          ),
          const SizedBox(height: 18),
          SystemNotificationPanel(
            title: 'Notificacion',
            lines: const [
              '[ Ha llegado la mision diaria: Entrenamiento de fuerza. ]',
              'Fallar reducira tu racha y tu impulso.',
            ],
            ctaLabel: '[ Comenzar mision ]',
            emphasisColor: widget.palette.secondary,
            onAccept: () {
              setState(() {
                _dailyNotificationDismissed = true;
              });
            },
          ),
        ],
        if (widget.specialQuest != null) ...[
          const SizedBox(height: 18),
          Text(
            'QUEST ESPECIAL SEMANAL',
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2.4,
              color: widget.palette.secondary,
            ),
          ),
          const SizedBox(height: 12),
          if (effectiveSpecialQuestStatus == 'pending')
            _PendingSpecialQuestPanel(
              specialQuest: widget.specialQuest!,
              palette: widget.palette,
              isSubmitting: questActionState.isSubmitting,
              onDecision: (accept) async {
                setState(() {
                  _specialQuestStatusOverride = accept ? 'accepted' : 'rejected';
                  _specialQuestFeedback = null;
                });
                final success = await questActionController.decideSpecialQuest(
                  accept,
                );
                if (!mounted) {
                  return;
                }
                if (!success) {
                  final latestState = ref.read(questActionsControllerProvider);
                  setState(() {
                    _specialQuestStatusOverride = null;
                    _specialQuestFeedback =
                        latestState.lastErrorMessage ??
                        'El Sistema no pudo registrar tu decision. Intentalo nuevamente.';
                  });
                }
              },
            )
          else if (effectiveSpecialQuestStatus == 'accepted' ||
              effectiveSpecialQuestStatus == 'completed')
            QuestCard(
              quest: widget.specialQuest!,
              primary: widget.palette.primary,
              secondary: widget.palette.secondary,
              highlight: widget.palette.highlight,
              isSpecial: true,
              isSubmitting: questActionState.isSubmitting &&
                  questActionState.activeActionKey ==
                      'special:${widget.specialQuest!.id}',
              onAdvance: () => _runAction(
                operation: () => questActionController.advanceSpecialQuest(
                  widget.specialQuest!,
                ),
              ),
            )
          else
            HolographicPanel(
              glowColor: widget.palette.primary,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decorate: false,
              showCorners: false,
              child: Text(
                'Quest especial rechazada. El Sistema mantiene la rutina comun de esta semana.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
            ),
        ],
        if (_specialQuestFeedback != null) ...[
          const SizedBox(height: 12),
          HolographicPanel(
            glowColor: widget.palette.primary,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decorate: false,
            showCorners: false,
            child: Text(
              _specialQuestFeedback!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
            'REGISTRO DE MISIONES',
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2.4,
              color: widget.palette.primary,
            ),
          ),
        const SizedBox(height: 12),
        ...widget.quests.map(
          (quest) => QuestCard(
            quest: quest,
            primary: widget.palette.primary,
            secondary: widget.palette.secondary,
            highlight: widget.palette.highlight,
            isSubmitting: questActionState.isSubmitting &&
                questActionState.activeActionKey == 'quest:${quest.id}',
            onAdvance: () => _runAction(
              operation: () => questActionController.advanceQuest(quest),
            ),
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: widget.palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decorate: false,
          showCorners: false,
          child: Row(
            children: [
              Expanded(
                child: MiniMetric(
                  label: 'Botin XP',
                  value:
                      '${widget.quests.fold<int>(0, (sum, q) => sum + q.rewardXp)} XP',
                  accent: widget.palette.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MiniMetric(
                  label: 'Racha actual',
                  value: '${widget.profile.streakDays} dias',
                  accent: widget.palette.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InventoryPanel(
          title: 'INVENTARIO DEL SISTEMA',
          inventory: widget.inventory,
          xpBoostArmed: widget.xpBoostArmed,
          palette: widget.palette,
          showRerollAction: true,
        ),
        const SizedBox(height: 18),
        Text(
            'BLOQUE OPTIMO ACTUAL',
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2.4,
              color: widget.palette.primary,
            ),
          ),
        const SizedBox(height: 12),
        HolographicPanel(
          glowColor: widget.palette.primary,
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
                _stagePrescription(
                  widget.trainingPath.stages[widget.selectedStageIndex],
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              TrainingBullet(
                accent: widget.palette.secondary,
                text:
                    'Dia A: dominada asistida, flexion inclinada, remo australiano, sentadilla y hollow hold.',
              ),
              TrainingBullet(
                accent: widget.palette.primary,
                text:
                    'Dia B: repetir patron con un poco menos de asistencia o mas rango de movimiento.',
              ),
              TrainingBullet(
                accent: widget.palette.secondary,
                text:
                    'Dia C: consolidar tecnica, registrar reps y decidir si toca subir ejercicio o mantener bloque.',
              ),
              const SizedBox(height: 14),
              Text(
                widget.trainingPath.rules.first.detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: widget.palette.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.palette.secondary.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  'Etapa activa: ${widget.trainingPath.stages[widget.selectedStageIndex].title}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
        return 'En intermedio conviene pasar a 4 sesiones con variantes mas desafiantes, manteniendo tecnica limpia y una base de movilidad para hombros y escapulas.';
      case 'Advanced':
        return 'En avanzado ya se justifica separar fuerza, skill y resistencia, pero sin perder una sesion de movilidad ni reforzar progresiones antes de cada truco.';
      case 'Expert / Pro':
        return 'En experto la progresion deja de ser lineal: la semana se organiza por bloques especificos y necesita descarga planificada para sostener rendimiento.';
      default:
        return 'La guia apunta a una base full body de 3 dias cuando el objetivo es progresar de forma sostenida sin quemar articulaciones ni saltarse adaptaciones.';
    }
  }

  Future<void> _runAction({
    required Future<bool> Function() operation,
  }) async {
    final state = ref.read(questActionsControllerProvider);
    if (state.isSubmitting) {
      return;
    }
    final success = await operation();
    if (!mounted) {
      return;
    }
    final nextState = ref.read(questActionsControllerProvider);
    if (!success && nextState.lastErrorMessage != null) {
      setState(() {
        _specialQuestFeedback = nextState.lastErrorMessage;
      });
    }
  }
}

class _PendingSpecialQuestPanel extends StatelessWidget {
  const _PendingSpecialQuestPanel({
    required this.specialQuest,
    required this.palette,
    required this.isSubmitting,
    required this.onDecision,
  });

  final DailyQuest specialQuest;
  final SectionPalette palette;
  final bool isSubmitting;
  final Future<void> Function(bool accept) onDecision;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HolographicPanel(
      glowColor: palette.secondary,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decorate: false,
      showCorners: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            specialQuest.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            specialQuest.detail,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : () => onDecision(false),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isSubmitting ? null : () => onDecision(true),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

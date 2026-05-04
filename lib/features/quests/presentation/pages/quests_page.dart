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
import '../../application/quest_actions_state.dart';
import '../widgets/quest_card.dart';

class QuestsPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actionState = ref.watch(questActionsControllerProvider);
    final actions = ref.read(questActionsControllerProvider.notifier);

    return ScreenFrame(
      primary: palette.primary,
      secondary: palette.secondary,
      highlight: palette.highlight,
      children: [
        SystemBadge(label: 'Notificacion', glowColor: palette.primary),
        const SizedBox(height: 18),
        SystemNotificationPanel(
          title: 'Notificacion',
          lines: const [
            '[ Ha llegado la mision diaria: Entrenamiento de fuerza. ]',
            'Fallar reducira tu racha y tu impulso.',
          ],
          ctaLabel: '[ Comenzar mision ]',
          emphasisColor: palette.secondary,
          onAccept: () {},
        ),
        if (specialQuest != null) ...[
          const SizedBox(height: 18),
          Text(
            'QUEST ESPECIAL SEMANAL',
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2.4,
              color: palette.secondary,
            ),
          ),
          const SizedBox(height: 12),
          if (specialQuestStatus == 'pending')
            _PendingSpecialQuestPanel(
              specialQuest: specialQuest!,
              palette: palette,
              state: actionState,
              onDecision: actions.decideSpecialQuest,
            )
          else if (specialQuestStatus == 'accepted' ||
              specialQuestStatus == 'completed')
            QuestCard(
              quest: specialQuest!,
              primary: palette.primary,
              secondary: palette.secondary,
              highlight: palette.highlight,
              isSpecial: true,
              isSubmitting:
                  actionState.isSubmitting &&
                  actionState.activeActionKey == 'special:${specialQuest!.id}',
              onAdvance: () => actions.advanceSpecialQuest(specialQuest!),
            )
          else
            HolographicPanel(
              glowColor: palette.primary,
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
        const SizedBox(height: 18),
        Text(
          'REGISTRO DE MISIONES',
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 2.4,
            color: palette.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...quests.map(
          (quest) => QuestCard(
            quest: quest,
            primary: palette.primary,
            secondary: palette.secondary,
            highlight: palette.highlight,
            isSubmitting:
                actionState.isSubmitting &&
                actionState.activeActionKey == 'quest:${quest.id}',
            onAdvance: () => actions.advanceQuest(quest),
          ),
        ),
        const SizedBox(height: 18),
        HolographicPanel(
          glowColor: palette.primary,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decorate: false,
          showCorners: false,
          child: Row(
            children: [
              Expanded(
                child: MiniMetric(
                  label: 'Botin XP',
                  value:
                      '${quests.fold<int>(0, (sum, q) => sum + q.rewardXp)} XP',
                  accent: palette.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MiniMetric(
                  label: 'Racha actual',
                  value: '${profile.streakDays} dias',
                  accent: palette.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InventoryPanel(
          title: 'INVENTARIO DEL SISTEMA',
          inventory: inventory,
          xpBoostArmed: xpBoostArmed,
          palette: palette,
          showRerollAction: true,
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
              TrainingBullet(
                accent: palette.secondary,
                text:
                    'Dia A: dominada asistida, flexion inclinada, remo australiano, sentadilla y hollow hold.',
              ),
              TrainingBullet(
                accent: palette.primary,
                text:
                    'Dia B: repetir patron con un poco menos de asistencia o mas rango de movimiento.',
              ),
              TrainingBullet(
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
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: palette.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: palette.secondary.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  'Etapa activa: ${trainingPath.stages[selectedStageIndex].title}',
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
}

class _PendingSpecialQuestPanel extends StatelessWidget {
  const _PendingSpecialQuestPanel({
    required this.specialQuest,
    required this.palette,
    required this.state,
    required this.onDecision,
  });

  final DailyQuest specialQuest;
  final SectionPalette palette;
  final QuestActionsState state;
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
                  onPressed: state.isSubmitting ? null : () => onDecision(false),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : () => onDecision(true),
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

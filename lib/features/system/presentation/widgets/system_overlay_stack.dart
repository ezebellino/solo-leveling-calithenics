import 'package:flutter/material.dart';

import '../../../home/domain/player_system_service.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import '../../application/system_overlay_state.dart';
import 'system_class_evolution_overlay.dart';
import 'system_level_up_overlay.dart';
import 'system_notification_panel.dart';
import 'system_reward_notice_banner.dart';

class SystemOverlayStack extends StatelessWidget {
  const SystemOverlayStack({
    required this.state,
    required this.palette,
    required this.playerAccepted,
    required this.jobChanged,
    required this.rewardNotice,
    required this.pendingLevelUp,
    required this.pendingClassEvolution,
    required this.onAcceptPlayer,
    required this.onConfirmJobChanged,
    required this.onDismissLevelUp,
    required this.onDismissClassEvolution,
    super.key,
  });

  final SystemOverlayState state;
  final SectionPalette palette;
  final bool playerAccepted;
  final bool jobChanged;
  final String? rewardNotice;
  final int? pendingLevelUp;
  final ClassEvolutionNotice? pendingClassEvolution;
  final VoidCallback onAcceptPlayer;
  final VoidCallback onConfirmJobChanged;
  final VoidCallback onDismissLevelUp;
  final VoidCallback onDismissClassEvolution;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (state.visibleOverlay == SystemOverlayKind.onboarding)
          Positioned.fill(child: _buildOnboardingOverlay()),
        if (state.visibleOverlay == SystemOverlayKind.classEvolution &&
            pendingClassEvolution != null)
          _buildCeremonialOverlay(
            child: SystemClassEvolutionOverlay(
              previousClass: pendingClassEvolution!.previousClass,
              nextClass: pendingClassEvolution!.nextClass,
              palette: palette,
              onDismiss: onDismissClassEvolution,
            ),
          ),
        if (state.visibleOverlay == SystemOverlayKind.rewardNotice &&
            rewardNotice != null)
          Positioned(
            left: 24,
            right: 24,
            top: 110,
            child: IgnorePointer(
              child: SystemRewardNoticeBanner(
                message: rewardNotice!,
                secondary: palette.secondary,
                highlight: palette.highlight,
              ),
            ),
          ),
        if (state.visibleOverlay == SystemOverlayKind.levelUp &&
            pendingLevelUp != null)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: const Color(0xC4060A10),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: SystemLevelUpOverlay(
                level: pendingLevelUp!,
                primary: palette.primary,
                secondary: palette.secondary,
                onDismiss: onDismissLevelUp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOnboardingOverlay() {
    return Container(
      color: const Color(0xCC03080F),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !playerAccepted
                ? SystemNotificationPanel(
                    key: const ValueKey('accept-player'),
                    title: 'Notificacion',
                    lines: const [
                      'Has adquirido las condiciones para convertirte en un Jugador.',
                      'Acepta el Sistema y comienza tu progresion diaria.',
                    ],
                    secondaryLabel: '[ Rechazar ]',
                    ctaLabel: '[ Aceptar ]',
                    onSecondary: () {},
                    onAccept: onAcceptPlayer,
                  )
                : SystemNotificationPanel(
                    key: const ValueKey('job-change'),
                    title: 'Asignacion de clase',
                    lines: const [
                      'Clase inicial asignada por el Sistema.',
                      '[ humano novato ]',
                      'Tu progreso fisico y tu disciplina definiran tu proxima evolucion.',
                    ],
                    ctaLabel: '[ Continuar ]',
                    emphasisColor: const Color(0xFF25F3B4),
                    onAccept: onConfirmJobChanged,
                  ),
          ),
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
}

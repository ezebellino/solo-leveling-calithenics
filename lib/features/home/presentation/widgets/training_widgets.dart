import 'package:flutter/material.dart';

import '../../domain/training_path.dart';
import 'section_palette.dart';

class TrainingStageTile extends StatelessWidget {
  const TrainingStageTile({
    required this.stage,
    required this.palette,
    this.isActive = false,
    this.compact = false,
    super.key,
  });

  final TrainingStage stage;
  final SectionPalette palette;
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class StageChip extends StatelessWidget {
  const StageChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
    super.key,
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

class ProgressRuleTile extends StatelessWidget {
  const ProgressRuleTile({
    required this.rule,
    required this.palette,
    super.key,
  });

  final TrainingRule rule;
  final SectionPalette palette;

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

class TrainingBullet extends StatelessWidget {
  const TrainingBullet({
    required this.text,
    required this.accent,
    super.key,
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

class StatBar extends StatelessWidget {
  const StatBar({
    required this.label,
    required this.value,
    required this.max,
    required this.palette,
    super.key,
  });

  final String label;
  final int value;
  final int max;
  final SectionPalette palette;

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

class MiniMetric extends StatelessWidget {
  const MiniMetric({
    required this.label,
    required this.value,
    this.accent = const Color(0xFF79E7FF),
    super.key,
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

class ProfileLine extends StatelessWidget {
  const ProfileLine({
    required this.label,
    required this.value,
    this.accent = const Color(0xFF79E7FF),
    super.key,
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

class HunterAvatar extends StatelessWidget {
  const HunterAvatar({
    required this.alias,
    required this.accent,
    super.key,
  });

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

import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/section_palette.dart';
import 'system_muscle_map_models.dart';

class SystemExerciseFocusCard extends StatelessWidget {
  const SystemExerciseFocusCard({
    required this.exercise,
    required this.palette,
    super.key,
  });

  final SystemExerciseCardModel exercise;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HolographicPanel(
      glowColor: palette.secondary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      borderRadius: 20,
      decorate: false,
      showCorners: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: palette.secondary.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  exercise.category.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.secondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: palette.primary.withValues(alpha: 0.88),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'MUSCULOS INVOLUCRADOS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white60,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            exercise.muscles.join(' \u00b7 '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

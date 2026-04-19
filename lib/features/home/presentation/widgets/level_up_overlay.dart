import 'package:flutter/material.dart';

import 'holographic_panel.dart';

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    required this.level,
    required this.primary,
    required this.secondary,
    super.key,
  });

  final int level;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HolographicPanel(
      glowColor: primary,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decorate: false,
      showCorners: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NOTIFICACION',
            style: theme.textTheme.labelLarge?.copyWith(
              color: primary,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subiste de nivel',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              shadows: const [
                Shadow(
                  color: Color(0xCC02070D),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Lv.$level',
            style: theme.textTheme.displaySmall?.copyWith(
              color: secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

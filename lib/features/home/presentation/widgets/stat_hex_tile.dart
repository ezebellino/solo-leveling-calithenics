import 'package:flutter/material.dart';

import 'holographic_panel.dart';

class StatHexTile extends StatefulWidget {
  const StatHexTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accent = const Color(0xFF79E7FF),
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  State<StatHexTile> createState() => _StatHexTileState();
}

class _StatHexTileState extends State<StatHexTile> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.98 : 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          opacity: _pressed ? 0.92 : 1,
          child: SizedBox(
            height: 138,
            child: HolographicPanel(
              glowColor: widget.accent,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              borderRadius: 24,
              cornerInset: 6,
              cornerSize: 16,
              decorate: false,
              showCorners: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.accent, size: 22),
                    const SizedBox(height: 14),
                    Text(
                      widget.value,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

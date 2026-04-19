import 'package:flutter/material.dart';

class SystemBadge extends StatelessWidget {
  const SystemBadge({
    required this.label,
    this.glowColor = const Color(0xFF79E7FF),
    super.key,
  });

  final String label;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: glowColor.withValues(alpha: 0.70)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.18),
            blurRadius: 18,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 2.2,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

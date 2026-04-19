import 'package:flutter/material.dart';

import 'holographic_panel.dart';

class RewardNoticeBanner extends StatelessWidget {
  const RewardNoticeBanner({
    required this.message,
    required this.secondary,
    required this.highlight,
    super.key,
  });

  final String message;
  final Color secondary;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return HolographicPanel(
      glowColor: secondary,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decorate: false,
      showCorners: false,
      borderRadius: 18,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: highlight,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

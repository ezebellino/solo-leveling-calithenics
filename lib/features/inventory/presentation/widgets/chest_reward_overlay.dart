import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/holographic_panel.dart';
import '../../../home/presentation/widgets/section_palette.dart';

class ChestRewardOverlay extends StatefulWidget {
  const ChestRewardOverlay({
    required this.rewards,
    required this.palette,
    this.onDismiss,
    super.key,
  });

  final List<String> rewards;
  final SectionPalette palette;
  final VoidCallback? onDismiss;

  @override
  State<ChestRewardOverlay> createState() => _ChestRewardOverlayState();
}

class _ChestRewardOverlayState extends State<ChestRewardOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _ambientController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: HolographicPanel(
            glowColor: palette.primary,
            padding: EdgeInsets.zero,
            showCorners: true,
            borderRadius: 30,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.25, -0.85),
                          radius: 1.15,
                          colors: [
                            palette.primary.withValues(alpha: 0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            palette.secondary.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.52, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _ambientController,
                      builder: (context, child) {
                        return FractionalTranslation(
                          translation: Offset(
                            -1.4 + (_ambientController.value * 2.8),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 92,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                palette.highlight.withValues(alpha: 0.16),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: palette.highlight.withValues(alpha: 0.58),
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    palette.highlight.withValues(alpha: 0.26),
                                    palette.primary.withValues(alpha: 0.16),
                                    Colors.black.withValues(alpha: 0.30),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primary.withValues(alpha: 0.24),
                                    blurRadius: 22,
                                    spreadRadius: -8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.inventory_2_rounded,
                                color: palette.highlight,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: palette.secondary.withValues(alpha: 0.42),
                                    ),
                                    color: Colors.black.withValues(alpha: 0.20),
                                  ),
                                  child: Text(
                                    'SYSTEM REWARD',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: palette.highlight,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Cofre recibido',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                    shadows: [
                                      Shadow(
                                        color: palette.primary.withValues(alpha: 0.34),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'RECOMPENSAS',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: palette.secondary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: palette.highlight.withValues(alpha: 0.20),
                          ),
                          color: Colors.black.withValues(alpha: 0.18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < widget.rewards.length; i++) ...[
                                _RewardLine(
                                  text: widget.rewards[i],
                                  palette: palette,
                                ),
                                if (i != widget.rewards.length - 1)
                                  Divider(
                                    color: palette.secondary.withValues(alpha: 0.16),
                                    height: 18,
                                  ),
                              ],
                              if (widget.rewards.isEmpty)
                                _RewardLine(
                                  text: 'Sin recompensas registradas',
                                  palette: palette,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.onDismiss != null) ...[
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: widget.onDismiss,
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary.withValues(alpha: 0.16),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: palette.highlight.withValues(alpha: 0.36),
                                ),
                              ),
                            ),
                            child: Text(
                              'CONTINUAR',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardLine extends StatelessWidget {
  const _RewardLine({
    required this.text,
    required this.palette,
  });

  final String text;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.highlight,
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.26),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'holographic_panel.dart';
import 'system_badge.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({
    required this.title,
    required this.lines,
    this.ctaLabel,
    this.secondaryLabel,
    this.onAccept,
    this.onSecondary,
    this.emphasisColor = const Color(0xFF79E7FF),
    super.key,
  });

  final String title;
  final List<String> lines;
  final String? ctaLabel;
  final String? secondaryLabel;
  final VoidCallback? onAccept;
  final VoidCallback? onSecondary;
  final Color emphasisColor;

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = 0.92 + (_controller.value * 0.08);

        return HolographicPanel(
          glowColor: widget.emphasisColor,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Transform.translate(
                    offset: Offset(-220 + (_controller.value * 520), 0),
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              widget.emphasisColor.withValues(alpha: 0.0),
                              widget.emphasisColor.withValues(alpha: 0.18),
                              widget.emphasisColor.withValues(alpha: 0.0),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: pulse,
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  widget.emphasisColor.withValues(alpha: 0.85),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.emphasisColor
                                    .withValues(alpha: 0.22),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Text(
                            '!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SystemBadge(
                          label: widget.title,
                          glowColor: widget.emphasisColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ...widget.lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        line,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.96),
                          height: 1.45,
                          letterSpacing: 0.4,
                          shadows: const [
                            Shadow(
                              color: Color(0xCC02070D),
                              blurRadius: 14,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.ctaLabel != null ||
                      widget.secondaryLabel != null) ...[
                    const SizedBox(height: 10),
                    if (widget.secondaryLabel != null)
                      _NotificationButton(
                        label: widget.secondaryLabel!,
                        onTap: widget.onSecondary,
                        outlined: true,
                      ),
                    if (widget.secondaryLabel != null &&
                        widget.ctaLabel != null)
                      const SizedBox(height: 12),
                    if (widget.ctaLabel != null)
                      _NotificationButton(
                        label: widget.ctaLabel!,
                        onTap: widget.onAccept,
                      ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.outlined ? const Color(0xFF79E7FF) : const Color(0xFF25F3B4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.985 : 1,
            child: ClipRect(
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _pressed ? 0.90 : 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: accent.withValues(alpha: 0.80)),
                        gradient: widget.outlined
                            ? null
                            : LinearGradient(
                                colors: [
                                  accent.withValues(alpha: 0.08),
                                  accent.withValues(alpha: 0.24),
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.22),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Transform.translate(
                        offset: Offset(-180 + (_controller.value * 420), 0),
                        child: Transform.rotate(
                          angle: -0.18,
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  accent.withValues(alpha: 0.0),
                                  accent.withValues(alpha: 0.22),
                                  accent.withValues(alpha: 0.0),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

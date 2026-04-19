import 'package:flutter/material.dart';

class HudNavItemData {
  const HudNavItemData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class HudNavigationBar extends StatelessWidget {
  const HudNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.onTap,
    super.key,
  });

  final List<HudNavItemData> items;
  final int currentIndex;
  final Color primary;
  final Color secondary;
  final Color highlight;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, bottomInset > 0 ? 8 : 10),
        child: CustomPaint(
          painter: _HudNavigationPainter(
            primary: primary,
            secondary: secondary,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A131D).withValues(alpha: 0.94),
                  const Color(0xFF09111A).withValues(alpha: 0.90),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                items.length,
                (index) => Expanded(
                  child: _HudNavButton(
                    item: items[index],
                    isActive: index == currentIndex,
                    primary: primary,
                    secondary: secondary,
                    highlight: highlight,
                    onTap: () => onTap(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HudNavButton extends StatefulWidget {
  const _HudNavButton({
    required this.item,
    required this.isActive,
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.onTap,
  });

  final HudNavItemData item;
  final bool isActive;
  final Color primary;
  final Color secondary;
  final Color highlight;
  final VoidCallback onTap;

  @override
  State<_HudNavButton> createState() => _HudNavButtonState();
}

class _HudNavButtonState extends State<_HudNavButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.isActive ? widget.secondary : widget.primary;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withValues(alpha: widget.isActive ? 0.42 : 0.12),
            ),
            gradient: widget.isActive
                ? LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      widget.primary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isActive)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          widget.highlight,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.highlight.withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.item.icon,
                      color: widget.isActive ? accent : Colors.white60,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: widget.isActive ? accent : Colors.white60,
                        letterSpacing: widget.isActive ? 0.9 : 0.4,
                        fontWeight:
                            widget.isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudNavigationPainter extends CustomPainter {
  const _HudNavigationPainter({
    required this.primary,
    required this.secondary,
  });

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final border = Paint()
      ..shader = LinearGradient(
        colors: [
          secondary.withValues(alpha: 0.34),
          primary.withValues(alpha: 0.75),
          secondary.withValues(alpha: 0.34),
        ],
      ).createShader(rect)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(22, 0)
      ..lineTo(size.width - 22, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 22)
      ..lineTo(size.width, size.height - 22)
      ..quadraticBezierTo(size.width, size.height, size.width - 22, size.height)
      ..lineTo(22, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 22)
      ..lineTo(0, 22)
      ..quadraticBezierTo(0, 0, 22, 0);

    final glow = Paint()
      ..color = primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawPath(path, glow);
    canvas.drawPath(path, border);

    final linePaint = Paint()
      ..color = primary.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(26, 10),
      Offset(size.width - 26, 10),
      linePaint,
    );

    final sideGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primary.withValues(alpha: 0.0),
          primary.withValues(alpha: 0.24),
          primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.18, 4, size.height * 0.48));
    canvas.drawRect(Rect.fromLTWH(6, size.height * 0.20, 2, size.height * 0.42), sideGlow);
    canvas.drawRect(
      Rect.fromLTWH(size.width - 8, size.height * 0.20, 2, size.height * 0.42),
      sideGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _HudNavigationPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary;
}

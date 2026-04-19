import 'package:flutter/material.dart';

import '../../domain/daily_quest.dart';
import 'holographic_panel.dart';

class QuestCard extends StatefulWidget {
  const QuestCard({
    required this.quest,
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.onAdvance,
    this.isSpecial = false,
    super.key,
  });

  final DailyQuest quest;
  final Color primary;
  final Color secondary;
  final Color highlight;
  final VoidCallback onAdvance;
  final bool isSpecial;

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.99 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _pressed ? 0.94 : 1,
            child: HolographicPanel(
              glowColor: widget.primary,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
              borderRadius: 22,
              cornerInset: 8,
              cornerSize: 16,
              decorate: false,
              showCorners: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.quest.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0xCC02070D),
                          blurRadius: 14,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.quest.detail,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.45,
                      shadows: const [
                        Shadow(
                          color: Color(0xCC02070D),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x6679E7FF)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: widget.quest.completionRate.clamp(0, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      widget.primary,
                                      widget.secondary,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.quest.rewardXp} XP',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: widget.isSpecial ? widget.highlight : widget.secondary,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.quest.progress}/${widget.quest.target} completado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.quest.isCompleted ? null : widget.onAdvance,
                      style: TextButton.styleFrom(
                        foregroundColor: widget.quest.isCompleted
                            ? Colors.white38
                            : widget.secondary,
                        side: BorderSide(
                          color: widget.quest.isCompleted
                              ? Colors.white24
                              : widget.secondary.withValues(alpha: 0.45),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        widget.quest.isCompleted
                            ? '[ Mision completa ]'
                            : '[ Avanzar mision ]',
                        style: theme.textTheme.labelLarge?.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: widget.quest.isCompleted
                              ? Colors.white38
                              : (widget.isSpecial ? widget.highlight : widget.secondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

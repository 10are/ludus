import 'package:flutter/material.dart';
import '../one_more_jump_game.dart';
import '../constants.dart';

class HUD extends StatelessWidget {
  final OneMoreJumpGame game;

  const HUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreDisplay(game: game),
                _HighScoreDisplay(game: game),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreDisplay extends StatefulWidget {
  final OneMoreJumpGame game;

  const _ScoreDisplay({required this.game});

  @override
  State<_ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<_ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HEIGHT',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${widget.game.currentScore}m',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: GameConstants.textColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HighScoreDisplay extends StatelessWidget {
  final OneMoreJumpGame game;

  const _HighScoreDisplay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'BEST',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        Text(
          '${game.highScore}m',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: GameConstants.playerColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

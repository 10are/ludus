import 'package:flutter/material.dart';
import '../one_more_jump_game.dart';
import '../constants.dart';

class GameOver extends StatelessWidget {
  final OneMoreJumpGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = game.currentScore >= game.highScore && game.currentScore > 0;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Over text
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: GameConstants.textColor,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),

            // Score
            Text(
              '${game.currentScore}m',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: isNewHighScore
                    ? GameConstants.bouncyPlatformColor
                    : GameConstants.playerColor,
              ),
            ),

            // New high score indicator
            if (isNewHighScore)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: GameConstants.bouncyPlatformColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEW BEST!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

            const SizedBox(height: 60),

            // Buttons
            _GameOverButton(
              text: 'ONE MORE JUMP',
              color: GameConstants.playerColor,
              onTap: () => game.restart(),
            ),
            const SizedBox(height: 16),
            _GameOverButton(
              text: 'MAIN MENU',
              color: GameConstants.normalPlatformColor,
              onTap: () => game.returnToMenu(),
            ),

            const SizedBox(height: 40),

            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameConstants.hudBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StatRow('Best Height', '${game.highScore}m'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _GameOverButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GameConstants.textColor,
          ),
        ),
      ],
    );
  }
}

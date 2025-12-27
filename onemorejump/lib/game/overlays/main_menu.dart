import 'package:flutter/material.dart';
import '../one_more_jump_game.dart';
import '../constants.dart';

class MainMenu extends StatelessWidget {
  final OneMoreJumpGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => game.startGame(),
      child: Material(
        color: Colors.transparent,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'ONE MORE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: GameConstants.textColor,
                letterSpacing: 4,
              ),
            ),
            Text(
              'JUMP',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: GameConstants.playerColor,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    color: GameConstants.playerColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // High score
            if (game.highScore > 0)
              Text(
                'BEST: ${game.highScore}m',
                style: const TextStyle(
                  fontSize: 24,
                  color: GameConstants.textColor,
                  letterSpacing: 2,
                ),
              ),
            const SizedBox(height: 40),

            // Tap to start
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              onEnd: () {},
              child: const Text(
                'TAP TO START',
                style: TextStyle(
                  fontSize: 20,
                  color: GameConstants.textColor,
                  letterSpacing: 4,
                ),
              ),
            ),

            const SizedBox(height: 100),

            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameConstants.hudBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInstruction(Icons.touch_app, 'HOLD to charge'),
                  const SizedBox(height: 8),
                  _buildInstruction(Icons.swipe, 'DRAG to aim'),
                  const SizedBox(height: 8),
                  _buildInstruction(Icons.publish, 'RELEASE to jump'),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: GameConstants.textColor, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: GameConstants.textColor,
          ),
        ),
      ],
    );
  }
}

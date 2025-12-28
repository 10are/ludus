import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: GameConstants.primaryDark,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ölüm ikonu
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: GameConstants.danger.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(color: GameConstants.danger, width: 3),
                      ),
                      child: Icon(Icons.dangerous, size: 50, color: GameConstants.danger),
                    ),

                    const SizedBox(height: 32),

                    // Oyun bitti
                    Text(
                      'LUDUS ÇÖKTÜ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: GameConstants.danger,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Gladyatör okulun tarihe karıştı...',
                      style: TextStyle(fontSize: 14, color: GameConstants.textMuted),
                    ),

                    const SizedBox(height: 32),

                    // İstatistikler
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: GameConstants.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameConstants.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow('Hayatta Kalınan Hafta', '${game.state.week}'),
                          Divider(color: GameConstants.cardBorder),
                          _buildStatRow('Kazanılan İtibar', '${game.state.reputation}'),
                          Divider(color: GameConstants.cardBorder),
                          _buildStatRow(
                            'Toplam Zafer',
                            '${game.state.gladiators.fold<int>(0, (sum, g) => sum + g.wins)}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tekrar dene
                    GestureDetector(
                      onTap: () => game.startGame(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: GameConstants.buttonPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GameConstants.gold.withAlpha(100)),
                        ),
                        child: Center(
                          child: Text(
                            'TEKRAR DENE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: GameConstants.textLight,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Ana menü
                    GestureDetector(
                      onTap: () => game.returnToMenu(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: GameConstants.buttonSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'ANA MENÜ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: GameConstants.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: GameConstants.textMuted)),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameConstants.gold),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Arka plan resmi
              Positioned.fill(
                child: Image.asset(
                  'assets/unnamed.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Karartma
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(100),
                        GameConstants.primaryDark.withAlpha(230),
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: GameConstants.primaryDark.withAlpha(200),
                            shape: BoxShape.circle,
                            border: Border.all(color: GameConstants.gold, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: GameConstants.gold.withAlpha(50),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.gavel,
                            size: 50,
                            color: GameConstants.gold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Başlık
                        Text(
                          'GLADYATÖR',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: GameConstants.textLight,
                            letterSpacing: 6,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              GameConstants.gold,
                              GameConstants.warmOrange,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'LUDUS',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 10,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Kendi gladyatör okulunu yönet',
                          style: TextStyle(
                            fontSize: 14,
                            color: GameConstants.textMuted,
                            letterSpacing: 1,
                          ),
                        ),

                        const Spacer(),

                        // Başla butonu
                        GestureDetector(
                          onTap: () => game.startGame(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  GameConstants.bloodRed,
                                  GameConstants.buttonPrimary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: GameConstants.gold.withAlpha(100)),
                              boxShadow: [
                                BoxShadow(
                                  color: GameConstants.bloodRed.withAlpha(100),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'OYUNA BAŞLA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: GameConstants.textLight,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

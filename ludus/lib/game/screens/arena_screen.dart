import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';
import 'fight_selection_screen.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Arka plan - Arena görseli
              Positioned.fill(
                child: Image.asset(
                  'assets/arena.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          GameConstants.warmOrange.withAlpha(100),
                          GameConstants.primaryDark,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Güneş efekti
              Positioned(
                top: -80,
                right: -30,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withAlpha(60),
                        const Color(0xFFFF8C00).withAlpha(30),
                        Colors.transparent,
                      ],
                    ),
                  ),
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
                        Colors.black.withAlpha(180),
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              SafeArea(
                child: Column(
                  children: [
                    // Üst bar
                    _buildTopBar(context),

                    const SizedBox(height: 20),

                    // Başlık
                    Text(
                      'ARENA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: GameConstants.gold,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    Text(
                      'Roma\'nın görkemli arenasında savaş',
                      style: TextStyle(
                        fontSize: 14,
                        color: GameConstants.textMuted,
                      ),
                    ),

                    const Spacer(),

                    // İki büyük seçenek kartı
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Arena kartı
                          _ArenaOptionCard(
                            title: 'ARENA DÖVÜŞÜ',
                            subtitle: 'Şeref ve itibar için savaş',
                            icon: Icons.stadium,
                            color: GameConstants.gold,
                            description: '6 güçlü rakip seni bekliyor',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: game,
                                  child: const FightSelectionScreen(isArena: true),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Yeraltı kartı
                          _ArenaOptionCard(
                            title: 'YERALTI DÖVÜŞÜ',
                            subtitle: 'Karanlıkta altın kazan',
                            icon: Icons.nights_stay,
                            color: GameConstants.bloodRed,
                            description: 'Yasadışı ama karlı',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: game,
                                  child: const FightSelectionScreen(isArena: false),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Alt bilgi
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GameConstants.cardBg.withAlpha(200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Gladyatör', '${game.state.gladiators.length}'),
                          _buildStatColumn('Savaşabilir', '${game.state.availableForFight.length}'),
                          _buildStatColumn('İtibar', '${game.state.reputation}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GameConstants.primaryDark.withAlpha(200),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameConstants.gold.withAlpha(60)),
              ),
              child: Icon(Icons.arrow_back, color: GameConstants.textLight, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GameConstants.gold,
          ),
        ),
      ],
    );
  }
}

class _ArenaOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ArenaOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameConstants.cardBg.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GameConstants.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: GameConstants.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 30),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';

class DiplomacyScreen extends StatelessWidget {
  const DiplomacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: GameConstants.primaryDark,
          appBar: AppBar(
            backgroundColor: GameConstants.primaryBrown,
            title: Text('DİPLOMASİ', style: TextStyle(color: GameConstants.gold, letterSpacing: 2)),
            iconTheme: IconThemeData(color: GameConstants.textLight),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('EV SAHİPLERİ & KOMUTANLAR'),
                const SizedBox(height: 12),
                ...game.state.rivals.map((r) => _RivalCard(rival: r, game: game)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.people, color: GameConstants.gold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: GameConstants.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _RivalCard extends StatelessWidget {
  final dynamic rival;
  final GladiatorGame game;

  const _RivalCard({required this.rival, required this.game});

  @override
  Widget build(BuildContext context) {
    final relationshipColor = rival.relationship > 20
        ? GameConstants.success
        : rival.relationship < -20
            ? GameConstants.danger
            : GameConstants.textMuted;

    return GestureDetector(
      onTap: () => _showNegotiateDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GameConstants.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GameConstants.bronze.withAlpha(100)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: GameConstants.bronze.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  rival.name[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.bronze,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rival.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GameConstants.textLight,
                    ),
                  ),
                  Text(
                    rival.title,
                    style: TextStyle(fontSize: 12, color: GameConstants.gold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance, size: 14, color: GameConstants.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Etki: ${rival.influence}',
                        style: TextStyle(fontSize: 12, color: GameConstants.textMuted),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 14, color: relationshipColor),
                      const SizedBox(width: 4),
                      Text(
                        '${rival.relationship > 0 ? '+' : ''}${rival.relationship}',
                        style: TextStyle(fontSize: 12, color: relationshipColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: GameConstants.bronze),
          ],
        ),
      ),
    );
  }

  void _showNegotiateDialog(BuildContext context) {
    int betAmount = 100;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: GameConstants.primaryBrown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            rival.name,
            style: TextStyle(color: GameConstants.gold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pazarlık için ne kadar yatırım yapacaksın?',
                style: TextStyle(color: GameConstants.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => betAmount = (betAmount - 50).clamp(50, 500)),
                    icon: Icon(Icons.remove_circle, color: GameConstants.danger),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameConstants.cardBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$betAmount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GameConstants.gold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => betAmount = (betAmount + 50).clamp(50, 500)),
                    icon: Icon(Icons.add_circle, color: GameConstants.success),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Altının: ${game.state.gold}',
                style: TextStyle(color: GameConstants.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('İPTAL', style: TextStyle(color: GameConstants.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GameConstants.bronze),
              onPressed: () {
                Navigator.pop(ctx);
                _negotiate(context, betAmount);
              },
              child: const Text('PAZARLIK YAP'),
            ),
          ],
        ),
      ),
    );
  }

  void _negotiate(BuildContext context, int betAmount) {
    final result = game.negotiate(rival.id, betAmount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? GameConstants.success : GameConstants.danger,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

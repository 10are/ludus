import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';

class HouseScreen extends StatelessWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: GameConstants.primaryDark,
          appBar: AppBar(
            backgroundColor: GameConstants.primaryBrown,
            title: Text('EV', style: TextStyle(color: GameConstants.gold, letterSpacing: 2)),
            iconTheme: IconThemeData(color: GameConstants.textLight),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eş
                if (game.state.hasWife) ...[
                  _buildSectionTitle('AİLE', Icons.favorite),
                  const SizedBox(height: 12),
                  _WifeCard(name: game.state.wifeName),
                  const SizedBox(height: 24),
                ],

                // Gladyatörler
                _buildSectionTitle('GLADYATÖRLER', Icons.sports_mma),
                const SizedBox(height: 12),
                ...game.state.gladiators.map((g) => _GladiatorManageCard(gladiator: g, game: game)),

                const SizedBox(height: 24),

                // Personel
                _buildSectionTitle('PERSONEL', Icons.people),
                const SizedBox(height: 12),
                if (game.state.staff.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GameConstants.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Henüz personel yok.\nPazardan işe alabilirsin.',
                        style: TextStyle(color: GameConstants.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...game.state.staff.map((s) => _StaffCard(staff: s, game: game)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: GameConstants.gold, size: 20),
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

class _WifeCard extends StatelessWidget {
  final String name;

  const _WifeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameConstants.copper.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: GameConstants.copper.withAlpha(50),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.person, color: GameConstants.copper, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.textLight,
                  ),
                ),
                Text(
                  'Domina - Evin Hanımı',
                  style: TextStyle(fontSize: 12, color: GameConstants.copper),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GladiatorManageCard extends StatelessWidget {
  final dynamic gladiator;
  final GladiatorGame game;

  const _GladiatorManageCard({required this.gladiator, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gladiator.isInjured ? GameConstants.danger.withAlpha(150) : GameConstants.cardBorder,
        ),
      ),
      child: Column(
        children: [
          // Üst kısım - İsim ve bilgiler
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: GameConstants.bloodRed.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: gladiator.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(gladiator.imagePath!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          gladiator.name[0],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: GameConstants.bloodRed,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          gladiator.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GameConstants.textLight,
                          ),
                        ),
                        if (gladiator.isInjured) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.healing, color: GameConstants.danger, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      '${gladiator.origin} | ${gladiator.age} yaş',
                      style: TextStyle(fontSize: 12, color: GameConstants.textMuted),
                    ),
                  ],
                ),
              ),

              // Maaş
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('MAAŞ', style: TextStyle(fontSize: 10, color: GameConstants.textMuted)),
                  GestureDetector(
                    onTap: () => _showSalaryDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GameConstants.gold.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${gladiator.salary}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: GameConstants.gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stat barları
          _buildStatBar('SAĞLIK', gladiator.health, GameConstants.healthColor),
          _buildStatBar('GÜÇ', gladiator.strength, GameConstants.strengthColor),
          _buildStatBar('ZEKA', gladiator.intelligence, GameConstants.intelligenceColor),
          _buildStatBar('KONDİSYON', gladiator.stamina, GameConstants.staminaColor),
          _buildStatBar('MORAL', gladiator.morale, GameConstants.gold),

          const SizedBox(height: 12),

          // Aksiyonlar
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.fitness_center,
                  label: 'EĞİT',
                  color: GameConstants.strengthColor,
                  onTap: gladiator.canTrain ? () => _showTrainDialog(context) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.healing,
                  label: 'TEDAVİ',
                  color: GameConstants.healthColor,
                  onTap: gladiator.health < 100 ? () => _heal(context) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.exit_to_app,
                  label: 'KOV',
                  color: GameConstants.danger,
                  onTap: () => _showFireDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(fontSize: 10, color: GameConstants.textMuted)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25,
            child: Text(
              '$value',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDialog(BuildContext context) {
    int newSalary = gladiator.salary;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: GameConstants.primaryBrown,
          title: Text('MAAŞ AYARLA', style: TextStyle(color: GameConstants.gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gladiator.name, style: TextStyle(color: GameConstants.textLight, fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => newSalary = (newSalary - 10).clamp(10, 500)),
                    icon: Icon(Icons.remove_circle, color: GameConstants.danger),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameConstants.cardBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$newSalary',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GameConstants.gold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => newSalary = (newSalary + 10).clamp(10, 500)),
                    icon: Icon(Icons.add_circle, color: GameConstants.success),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                newSalary > gladiator.salary
                    ? 'Zam = Moral artışı'
                    : newSalary < gladiator.salary
                        ? 'Düşürme = Moral kaybı'
                        : '',
                style: TextStyle(fontSize: 12, color: GameConstants.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('İPTAL', style: TextStyle(color: GameConstants.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GameConstants.gold),
              onPressed: () {
                game.setGladiatorSalary(gladiator.id, newSalary);
                Navigator.pop(ctx);
              },
              child: const Text('KAYDET', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GameConstants.primaryBrown,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EĞİTİM SEÇ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameConstants.gold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.fitness_center, color: GameConstants.strengthColor),
              title: Text('Güç Eğitimi', style: TextStyle(color: GameConstants.textLight)),
              subtitle: Text('+${GameConstants.trainingStatGain} Güç | ${GameConstants.trainingCostBase} altın', style: TextStyle(color: GameConstants.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _train(context, 'strength');
              },
            ),
            ListTile(
              leading: Icon(Icons.psychology, color: GameConstants.intelligenceColor),
              title: Text('Zeka Eğitimi', style: TextStyle(color: GameConstants.textLight)),
              subtitle: Text('+${GameConstants.trainingStatGain} Zeka | ${GameConstants.trainingCostBase} altın', style: TextStyle(color: GameConstants.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _train(context, 'intelligence');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run, color: GameConstants.staminaColor),
              title: Text('Kondisyon Eğitimi', style: TextStyle(color: GameConstants.textLight)),
              subtitle: Text('+${GameConstants.trainingStatGain} Kondisyon | ${GameConstants.trainingCostBase} altın', style: TextStyle(color: GameConstants.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _train(context, 'stamina');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _train(BuildContext context, String stat) {
    final success = game.trainGladiator(gladiator.id, stat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Eğitim tamamlandı!' : 'Eğitim yapılamadı!'),
        backgroundColor: success ? GameConstants.success : GameConstants.danger,
      ),
    );
  }

  void _heal(BuildContext context) {
    final success = game.healGladiator(gladiator.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Tedavi uygulandı!' : 'Tedavi yapılamadı!'),
        backgroundColor: success ? GameConstants.success : GameConstants.danger,
      ),
    );
  }

  void _showFireDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.primaryBrown,
        title: Text('GLADYATÖRÜ KOV', style: TextStyle(color: GameConstants.danger)),
        content: Text(
          '${gladiator.name} kovulacak. Emin misin?',
          style: TextStyle(color: GameConstants.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İPTAL', style: TextStyle(color: GameConstants.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GameConstants.danger),
            onPressed: () {
              game.sellGladiator(gladiator.id, 0);
              Navigator.pop(ctx);
            },
            child: const Text('KOV'),
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final dynamic staff;
  final GladiatorGame game;

  const _StaffCard({required this.staff, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameConstants.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            staff.role == 'doctor' ? Icons.local_hospital : Icons.fitness_center,
            color: GameConstants.copper,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GameConstants.textLight)),
                Text(
                  staff.role == 'doctor' ? 'Doktor' : 'Eğitmen',
                  style: TextStyle(fontSize: 12, color: GameConstants.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${staff.salary}/hafta', style: TextStyle(color: GameConstants.gold)),
              GestureDetector(
                onTap: () => game.fireStaff(staff.id),
                child: Text('KOV', style: TextStyle(color: GameConstants.danger, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null ? color.withAlpha(30) : Colors.black12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: onTap != null ? color.withAlpha(100) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: onTap != null ? color : GameConstants.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: onTap != null ? color : GameConstants.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

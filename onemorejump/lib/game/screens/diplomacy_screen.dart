import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';
import '../models/game_state.dart';

class DiplomacyScreen extends StatefulWidget {
  const DiplomacyScreen({super.key});

  @override
  State<DiplomacyScreen> createState() => _DiplomacyScreenState();
}

class _DiplomacyScreenState extends State<DiplomacyScreen> {
  Map<String, dynamic>? diplomacyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiplomacyData();
  }

  Future<void> _loadDiplomacyData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/diplomacy_data.json');
      setState(() {
        diplomacyData = json.decode(jsonString);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        if (isLoading) {
          return Scaffold(
            backgroundColor: GameConstants.primaryDark,
            body: Center(child: CircularProgressIndicator(color: GameConstants.gold)),
          );
        }

        final caesar = diplomacyData?['caesar'];
        final characters = diplomacyData?['characters'] as List? ?? [];
        final missions = diplomacyData?['missions'] as List? ?? [];
        final canTalkToCaesar = game.state.reputation >= (caesar?['required_reputation'] ?? 500);

        return Scaffold(
          body: Stack(
            children: [
              // Arka plan
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2C1810),
                        GameConstants.primaryDark,
                        const Color(0xFF1A0A05),
                      ],
                    ),
                  ),
                ),
              ),

              // Altın parıltı efekti
              Positioned(
                top: -100,
                left: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GameConstants.gold.withAlpha(30),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context, game),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Caesar kartı
                            if (caesar != null) _CaesarCard(
                              caesar: caesar,
                              canTalk: canTalkToCaesar,
                              currentReputation: game.state.reputation,
                              onTap: canTalkToCaesar ? () => _showCaesarDialog(context, caesar, game) : null,
                            ),

                            const SizedBox(height: 24),

                            // Aktif görevler
                            if (game.state.activeMissions.isNotEmpty) ...[
                              _buildSectionHeader('AKTİF GÖREVLER', Icons.assignment_turned_in),
                              const SizedBox(height: 12),
                              ...game.state.activeMissions.map((m) => _ActiveMissionCard(
                                mission: m,
                                game: game,
                              )),
                              const SizedBox(height: 24),
                            ],

                            // Karakterler ve görevler
                            _buildSectionHeader('ROMA\'NIN ÖNEMLİ İSİMLERİ', Icons.people_alt),
                            const SizedBox(height: 12),

                            ...characters.map((char) {
                              final charMissions = missions.where((m) => m['giver'] == char['id']).toList();
                              final isUnlocked = game.state.reputation >= (char['required_reputation'] ?? 0);
                              return _CharacterCard(
                                character: char,
                                missions: charMissions,
                                isUnlocked: isUnlocked,
                                game: game,
                                onMissionAccept: (mission) => _acceptMission(context, mission, char, game),
                              );
                            }),

                            const SizedBox(height: 100),
                          ],
                        ),
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

  Widget _buildTopBar(BuildContext context, GladiatorGame game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GameConstants.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameConstants.gold.withAlpha(60)),
              ),
              child: Icon(Icons.arrow_back, color: GameConstants.textLight, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DİPLOMASİ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.gold,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  'Roma\'nın güçlüleriyle ilişkiler',
                  style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: GameConstants.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameConstants.gold.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: GameConstants.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${game.state.reputation}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GameConstants.gold.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: GameConstants.gold, size: 18),
        ),
        const SizedBox(width: 12),
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

  void _showCaesarDialog(BuildContext context, Map<String, dynamic> caesar, GladiatorGame game) {
    final dialogues = caesar['dialogues'] as List? ?? [];
    final dialogueIndex = game.state.dialogueIndex % dialogues.length;
    final currentDialogue = dialogues.isNotEmpty ? dialogues[dialogueIndex] : null;
    final rewards = caesar['rewards'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C1810),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GameConstants.gold.withAlpha(150), width: 2),
        ),
        title: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: GameConstants.gold, width: 3),
                image: const DecorationImage(
                  image: AssetImage('assets/defaultasker.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              caesar['name'] ?? 'Caesar',
              style: TextStyle(
                color: GameConstants.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              caesar['title'] ?? 'İmparator',
              style: TextStyle(color: GameConstants.textMuted, fontSize: 12),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameConstants.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentDialogue?['text'] ?? 'Selamlar, Lanista.',
                style: TextStyle(
                  color: GameConstants.textLight,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (rewards != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GameConstants.gold.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GameConstants.gold.withAlpha(80)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: GameConstants.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Ödül: ${rewards['gold']} Altın, +${rewards['reputation']} İtibar',
                      style: TextStyle(color: GameConstants.gold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('KAPAT', style: TextStyle(color: GameConstants.textMuted)),
          ),
        ],
      ),
    );
  }

  void _acceptMission(BuildContext context, Map<String, dynamic> mission, Map<String, dynamic> giver, GladiatorGame game) {
    final missionType = _getMissionType(mission['type'] ?? '');

    // Maliyet kontrolü
    final costGold = mission['cost_gold'] as int? ?? 0;
    if (costGold > 0 && game.state.gold < costGold) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yeterli altının yok! Gereken: $costGold'),
          backgroundColor: GameConstants.danger,
        ),
      );
      return;
    }

    // Görev zaten aktif mi kontrol et
    if (game.state.activeMissions.any((m) => m.missionId == mission['id'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bu görev zaten aktif!'),
          backgroundColor: GameConstants.warmOrange,
        ),
      );
      return;
    }

    // Maliyet varsa düş
    if (costGold > 0) {
      game.state.modifyGold(-costGold);
    }

    // Görevi ekle
    final activeMission = ActiveMission(
      id: 'am_${DateTime.now().millisecondsSinceEpoch}',
      missionId: mission['id'],
      type: missionType,
      title: mission['title'] ?? 'Görev',
      giverId: giver['id'],
      rewardGold: mission['reward_gold'] ?? 0,
      penaltyReputation: mission['penalty_reputation'] ?? 0,
      healthDamage: mission['health_damage'],
      moraleChange: mission['morale_change'],
      riskCaught: mission['risk_caught'],
      costGold: costGold,
      durationWeeks: mission['duration_weeks'],
      remainingWeeks: mission['duration_weeks'] ?? 1,
    );

    game.addMission(activeMission);

    Navigator.pop(context);

    _showCustomPopup(context, 'GÖREV KABUL EDİLDİ', mission['title'] ?? '', true);
  }

  void _showCustomPopup(BuildContext context, String title, String message, bool success) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GameConstants.primaryDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: success ? GameConstants.gold : GameConstants.danger, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(success ? Icons.check_circle : Icons.error, color: success ? GameConstants.gold : GameConstants.danger, size: 40),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: success ? GameConstants.gold : GameConstants.danger)),
              const SizedBox(height: 4),
              Text(message, style: TextStyle(fontSize: 12, color: GameConstants.textLight), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(color: success ? GameConstants.gold : GameConstants.danger, borderRadius: BorderRadius.circular(6)),
                  child: Text('TAMAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MissionType _getMissionType(String type) {
    switch (type) {
      case 'fix_fight': return MissionType.fixFight;
      case 'rent_gladiator': return MissionType.rentGladiator;
      case 'sabotage': return MissionType.sabotage;
      case 'senator_favor': return MissionType.senatorFavor;
      case 'training': return MissionType.training;
      case 'poison': return MissionType.poison;
      case 'bribe': return MissionType.bribe;
      case 'patronage': return MissionType.patronage;
      default: return MissionType.fixFight;
    }
  }
}

// Caesar kartı
class _CaesarCard extends StatelessWidget {
  final Map<String, dynamic> caesar;
  final bool canTalk;
  final int currentReputation;
  final VoidCallback? onTap;

  const _CaesarCard({
    required this.caesar,
    required this.canTalk,
    required this.currentReputation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final requiredRep = caesar['required_reputation'] ?? 500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canTalk
                ? [const Color(0xFF3D2817), const Color(0xFF5C3D1E)]
                : [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canTalk ? GameConstants.gold : GameConstants.textMuted.withAlpha(100),
            width: canTalk ? 2 : 1,
          ),
          boxShadow: canTalk ? [
            BoxShadow(
              color: GameConstants.gold.withAlpha(40),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Arkaplan deseni
            if (canTalk) Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.workspace_premium,
                size: 150,
                color: GameConstants.gold.withAlpha(15),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: canTalk ? GameConstants.gold : GameConstants.textMuted,
                        width: 3,
                      ),
                      boxShadow: canTalk ? [
                        BoxShadow(
                          color: GameConstants.gold.withAlpha(60),
                          blurRadius: 10,
                        ),
                      ] : null,
                    ),
                    child: ClipOval(
                      child: ColorFiltered(
                        colorFilter: canTalk
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                        child: Image.asset(
                          caesar['image'] ?? 'assets/defaultasker.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 40,
                            color: canTalk ? GameConstants.gold : GameConstants.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.workspace_premium, color: GameConstants.gold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              caesar['name'] ?? 'Caesar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: canTalk ? GameConstants.gold : GameConstants.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          caesar['title'] ?? 'Roma İmparatoru',
                          style: TextStyle(
                            fontSize: 12,
                            color: canTalk ? GameConstants.warmOrange : GameConstants.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caesar['description'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: GameConstants.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // İtibar göstergesi
                        if (!canTalk) ...[
                          Row(
                            children: [
                              Icon(Icons.lock, size: 14, color: GameConstants.danger),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gerekli İtibar: $requiredRep',
                                      style: TextStyle(fontSize: 10, color: GameConstants.danger),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (currentReputation / requiredRep).clamp(0.0, 1.0),
                                        backgroundColor: GameConstants.cardBg,
                                        valueColor: AlwaysStoppedAnimation(GameConstants.warmOrange),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: GameConstants.success.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: GameConstants.success),
                                const SizedBox(width: 6),
                                Text(
                                  'Konuşabilirsin',
                                  style: TextStyle(fontSize: 11, color: GameConstants.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (canTalk)
                    Icon(Icons.chevron_right, color: GameConstants.gold, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Karakter kartı
class _CharacterCard extends StatelessWidget {
  final Map<String, dynamic> character;
  final List missions;
  final bool isUnlocked;
  final GladiatorGame game;
  final Function(Map<String, dynamic>) onMissionAccept;

  const _CharacterCard({
    required this.character,
    required this.missions,
    required this.isUnlocked,
    required this.game,
    required this.onMissionAccept,
  });

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      'merchant': GameConstants.gold,
      'noble': const Color(0xFFE91E63),
      'politician': const Color(0xFF3F51B5),
      'rival': GameConstants.bloodRed,
      'trainer': GameConstants.success,
    };

    final typeColor = typeColors[character['type']] ?? GameConstants.bronze;
    final requiredRep = character['required_reputation'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GameConstants.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? typeColor.withAlpha(80) : GameConstants.textMuted.withAlpha(50),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: typeColor.withAlpha(100)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: ColorFiltered(
                colorFilter: isUnlocked
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                child: Image.asset(
                  character['image'] ?? 'assets/defaultasker.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    color: typeColor,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  character['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? GameConstants.textLight : GameConstants.textMuted,
                  ),
                ),
              ),
              if (!isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameConstants.danger.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 10, color: GameConstants.danger),
                      const SizedBox(width: 4),
                      Text(
                        '$requiredRep',
                        style: TextStyle(fontSize: 10, color: GameConstants.danger),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character['title'] ?? '',
                style: TextStyle(fontSize: 11, color: typeColor),
              ),
              const SizedBox(height: 4),
              Text(
                character['description'] ?? '',
                style: TextStyle(fontSize: 10, color: GameConstants.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          iconColor: isUnlocked ? typeColor : GameConstants.textMuted,
          collapsedIconColor: isUnlocked ? typeColor : GameConstants.textMuted,
          children: isUnlocked ? [
            if (missions.isNotEmpty) ...[
              const Divider(height: 1, color: Colors.white10),
              const SizedBox(height: 12),
              Text(
                'MEVCUT GÖREVLER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              ...missions.map((m) => _MissionTile(
                mission: m,
                typeColor: typeColor,
                game: game,
                onAccept: () => onMissionAccept(m),
              )),
            ] else
              Text(
                'Şu an mevcut görev yok.',
                style: TextStyle(
                  fontSize: 12,
                  color: GameConstants.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ] : [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bu karakterle konuşmak için $requiredRep itibar gerekli.',
                style: TextStyle(
                  fontSize: 11,
                  color: GameConstants.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Görev tile
class _MissionTile extends StatelessWidget {
  final Map<String, dynamic> mission;
  final Color typeColor;
  final GladiatorGame game;
  final VoidCallback onAccept;

  const _MissionTile({
    required this.mission,
    required this.typeColor,
    required this.game,
    required this.onAccept,
  });

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'casino': return Icons.casino;
      case 'nightlife': return Icons.nightlife;
      case 'warning': return Icons.warning;
      case 'stars': return Icons.stars;
      case 'fitness_center': return Icons.fitness_center;
      case 'science': return Icons.science;
      case 'gavel': return Icons.gavel;
      case 'volunteer_activism': return Icons.volunteer_activism;
      default: return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = game.state.activeMissions.any((m) => m.missionId == mission['id']);
    final rewardGold = mission['reward_gold'] as int? ?? 0;
    final costGold = mission['cost_gold'] as int? ?? 0;
    final penaltyRep = mission['penalty_reputation'] as int? ?? 0;
    final riskCaught = mission['risk_caught'] as int? ?? 0;

    return GestureDetector(
      onTap: isActive ? null : () => _showMissionDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? GameConstants.success.withAlpha(20)
              : GameConstants.primaryDark.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? GameConstants.success.withAlpha(80) : typeColor.withAlpha(40),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIcon(mission['icon']), color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission['title'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: GameConstants.textLight,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GameConstants.success.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AKTİF',
                            style: TextStyle(fontSize: 9, color: GameConstants.success, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission['description'] ?? '',
                    style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (rewardGold > 0)
                        _buildTag('+$rewardGold', Icons.monetization_on, GameConstants.gold),
                      if (costGold > 0)
                        _buildTag('-$costGold', Icons.monetization_on, GameConstants.danger),
                      if (penaltyRep < 0)
                        _buildTag('$penaltyRep İtibar', Icons.trending_down, GameConstants.danger),
                      if (riskCaught > 0)
                        _buildTag('$riskCaught% Risk', Icons.visibility, GameConstants.warmOrange),
                    ],
                  ),
                ],
              ),
            ),
            if (!isActive)
              Icon(Icons.chevron_right, color: typeColor.withAlpha(150), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  void _showMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.primaryBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: typeColor.withAlpha(100)),
        ),
        title: Row(
          children: [
            Icon(_getIcon(mission['icon']), color: typeColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mission['title'] ?? '',
                style: TextStyle(color: GameConstants.textLight, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mission['description'] ?? '',
              style: TextStyle(color: GameConstants.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildDialogInfo('Ödül', '+${mission['reward_gold'] ?? 0} Altın', GameConstants.gold),
            if ((mission['cost_gold'] ?? 0) > 0)
              _buildDialogInfo('Maliyet', '-${mission['cost_gold']} Altın', GameConstants.danger),
            if ((mission['penalty_reputation'] ?? 0) < 0)
              _buildDialogInfo('Risk', '${mission['penalty_reputation']} İtibar', GameConstants.danger),
            if ((mission['risk_caught'] ?? 0) > 0)
              _buildDialogInfo('Yakalanma', '${mission['risk_caught']}% ihtimal', GameConstants.warmOrange),
            if ((mission['health_damage'] ?? 0) > 0)
              _buildDialogInfo('Sağlık', '-${mission['health_damage']}', GameConstants.bloodRed),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('VAZGEÇ', style: TextStyle(color: GameConstants.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: typeColor),
            onPressed: onAccept,
            child: const Text('KABUL ET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfo(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: GameConstants.textMuted, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// Aktif görev kartı
class _ActiveMissionCard extends StatelessWidget {
  final ActiveMission mission;
  final GladiatorGame game;

  const _ActiveMissionCard({required this.mission, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameConstants.success.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GameConstants.success.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment_turned_in, color: GameConstants.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ödül: +${mission.rewardGold} Altın',
                  style: TextStyle(fontSize: 12, color: GameConstants.gold),
                ),
                if (mission.durationWeeks != null)
                  Text(
                    'Kalan: ${mission.remainingWeeks} hafta',
                    style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GameConstants.warmOrange.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Devam Ediyor',
              style: TextStyle(fontSize: 10, color: GameConstants.warmOrange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

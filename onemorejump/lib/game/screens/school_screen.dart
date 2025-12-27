import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';
import '../models/game_state.dart';

class SchoolScreen extends StatefulWidget {
  const SchoolScreen({super.key});

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  Map<String, dynamic>? schoolData;
  bool isLoading = true;
  int selectedTab = 0; // 0: Eş, 1: Ziyafet, 2: Gladyatörler

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/school_data.json');
      final data = json.decode(jsonString);
      setState(() {
        schoolData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('School data yükleme hatası: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Arka plan
              Positioned.fill(
                child: Image.asset(
                  'assets/okul.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: GameConstants.primaryDark,
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
                        Colors.black.withAlpha(120),
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
                    _buildTopBar(context, game),

                    // Tab seçici
                    _buildTabSelector(),

                    // İçerik
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator(color: GameConstants.gold))
                          : _buildContent(game),
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameConstants.primaryDark.withAlpha(200),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameConstants.gold.withAlpha(60)),
              ),
              child: Icon(Icons.arrow_back, color: GameConstants.textLight, size: 20),
            ),
          ),

          const SizedBox(width: 12),

          // Başlık
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: GameConstants.primaryDark.withAlpha(200),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GameConstants.gold.withAlpha(60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LUDUS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GameConstants.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.paid, color: GameConstants.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${game.state.gold}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: GameConstants.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GameConstants.primaryDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameConstants.gold.withAlpha(40)),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Domina', Icons.favorite),
          _buildTab(1, 'Ziyafet', Icons.restaurant),
          _buildTab(2, 'Gladyatörler', Icons.sports_mma),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? GameConstants.gold.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: GameConstants.gold.withAlpha(80)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? GameConstants.gold : GameConstants.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? GameConstants.gold : GameConstants.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(GladiatorGame game) {
    if (schoolData == null) {
      return Center(child: Text('Veri yüklenemedi', style: TextStyle(color: GameConstants.textMuted)));
    }

    switch (selectedTab) {
      case 0:
        return _buildWifeSection(game);
      case 1:
        return _buildFeastSection(game);
      case 2:
        return _buildGladiatorsSection(game);
      default:
        return const SizedBox();
    }
  }

  // === EŞ (DOMİNA) BÖLÜMÜ ===
  Widget _buildWifeSection(GladiatorGame game) {
    final wife = schoolData!['wife'];
    final dialogues = wife['dialogues'] as List;
    final gifts = wife['gifts'] as List;
    final currentDialogue = dialogues[game.state.dialogueIndex % dialogues.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Eş kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameConstants.primaryDark.withAlpha(230),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameConstants.copper.withAlpha(100)),
            ),
            child: Column(
              children: [
                // Fotoğraf ve bilgi
                Row(
                  children: [
                    // Fotoğraf
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameConstants.copper.withAlpha(80)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.asset(
                          wife['image'] ?? 'assets/karin.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: GameConstants.copper.withAlpha(50),
                            child: Icon(Icons.person, color: GameConstants.copper, size: 50),
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
                          Text(
                            game.state.wifeName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GameConstants.textLight,
                            ),
                          ),
                          Text(
                            wife['title'] ?? 'Domina',
                            style: TextStyle(fontSize: 12, color: GameConstants.copper),
                          ),

                          const SizedBox(height: 12),

                          // Moral barı
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.pink, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: game.state.wifeMorale / 100,
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.pink, Colors.red],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${game.state.wifeMorale}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Çocuk durumu
                          if (game.state.hasChild)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: GameConstants.success.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GameConstants.success.withAlpha(80)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.child_care, color: GameConstants.success, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'VARİS DOĞDU!',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: GameConstants.success,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (game.state.wifeMorale >= 100)
                            GestureDetector(
                              onTap: () => _tryForChild(game),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.pink.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.pink.withAlpha(80)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.child_care, color: Colors.pink, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'VARİS İÇİN HAZIR!',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Diyalog balonu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GameConstants.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GameConstants.copper.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${currentDialogue['text']}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: GameConstants.textLight,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '- ${game.state.wifeName}',
                            style: TextStyle(
                              fontSize: 11,
                              color: GameConstants.copper,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hediyeler başlığı
          Row(
            children: [
              Icon(Icons.card_giftcard, color: GameConstants.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'HEDİYELER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Hediye kartları
          ...gifts.map((gift) => _buildGiftCard(gift, game)),
        ],
      ),
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift, GladiatorGame game) {
    final price = gift['price'] ?? 0;
    final moraleBonus = gift['morale_bonus'] ?? 0;
    final canAfford = game.state.gold >= price;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameConstants.primaryDark.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: canAfford ? GameConstants.copper.withAlpha(60) : GameConstants.cardBorder),
      ),
      child: Row(
        children: [
          // İkon
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.pink.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.card_giftcard, color: Colors.pink, size: 24),
          ),

          const SizedBox(width: 12),

          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift['name'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? GameConstants.textLight : GameConstants.textMuted,
                  ),
                ),
                Text(
                  gift['description'] ?? '',
                  style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                ),
              ],
            ),
          ),

          // Moral bonus
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink, size: 12),
                const SizedBox(width: 2),
                Text(
                  '+$moraleBonus',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.pink),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Satın al butonu
          GestureDetector(
            onTap: canAfford ? () => _giveGift(game, price, moraleBonus, gift['name']) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: canAfford ? GameConstants.gold : GameConstants.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.paid, color: canAfford ? Colors.black : GameConstants.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$price',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.black : GameConstants.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _giveGift(GladiatorGame game, int price, int moraleBonus, String giftName) {
    final success = game.giveGiftToWife(price, moraleBonus);
    if (success) {
      _showPopup(context, giftName, true, 'Hediye verildi! Moral +$moraleBonus');
    }
  }

  void _tryForChild(GladiatorGame game) {
    final success = game.tryForChild();
    if (success) {
      _showPopup(context, 'VARİS!', true, 'Bir varise sahip oldunuz! +50 İtibar');
    }
  }

  // === ZİYAFET BÖLÜMÜ ===
  Widget _buildFeastSection(GladiatorGame game) {
    final feasts = schoolData!['feasts'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Açıklama
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GameConstants.primaryDark.withAlpha(220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameConstants.warmOrange.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: GameConstants.warmOrange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gladyatörlerine ziyafet vererek morallerini yükselt!',
                    style: TextStyle(fontSize: 12, color: GameConstants.textLight),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Gladyatör sayısı ve ortalama moral
          if (game.state.gladiators.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GameConstants.cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('${game.state.gladiators.length}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GameConstants.textLight)),
                      Text('Gladyatör', style: TextStyle(fontSize: 10, color: GameConstants.textMuted)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: GameConstants.cardBorder),
                  Column(
                    children: [
                      Text(
                        '${(game.state.gladiators.map((g) => g.morale).reduce((a, b) => a + b) / game.state.gladiators.length).round()}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GameConstants.gold),
                      ),
                      Text('Ort. Moral', style: TextStyle(fontSize: 10, color: GameConstants.textMuted)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Ziyafet kartları
          ...feasts.map((feast) => _buildFeastCard(feast, game)),
        ],
      ),
    );
  }

  Widget _buildFeastCard(Map<String, dynamic> feast, GladiatorGame game) {
    final price = feast['price'] ?? 0;
    final moraleBonus = feast['morale_bonus'] ?? 0;
    final canAfford = game.state.gold >= price;

    IconData getIcon() {
      switch (feast['icon']) {
        case 'wine':
          return Icons.wine_bar;
        case 'crown':
          return Icons.emoji_events;
        default:
          return Icons.restaurant;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GameConstants.primaryDark.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: canAfford ? GameConstants.warmOrange.withAlpha(80) : GameConstants.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // İkon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: GameConstants.warmOrange.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(getIcon(), color: GameConstants.warmOrange, size: 28),
                ),

                const SizedBox(width: 14),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feast['name'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? GameConstants.textLight : GameConstants.textMuted,
                        ),
                      ),
                      Text(
                        feast['description'] ?? '',
                        style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Alt bilgi ve buton
            Row(
              children: [
                // Moral bonus
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameConstants.gold.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mood, color: GameConstants.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+$moraleBonus Moral (Tüm Gladyatörler)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GameConstants.gold),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Satın al butonu
                GestureDetector(
                  onTap: canAfford ? () => _giveFeast(game, price, moraleBonus, feast['name']) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: canAfford ? GameConstants.warmOrange : GameConstants.cardBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.paid, color: canAfford ? Colors.black : GameConstants.textMuted, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$price',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.black : GameConstants.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _giveFeast(GladiatorGame game, int price, int moraleBonus, String feastName) {
    final success = game.giveFeast(price, moraleBonus);
    if (success) {
      _showPopup(context, feastName, true, 'Ziyafet verildi! Tüm gladyatörlere +$moraleBonus Moral');
    } else {
      _showPopup(context, feastName, false, 'Yeterli altın yok!');
    }
  }

  // === GLADYATÖRLER BÖLÜMÜ ===
  Widget _buildGladiatorsSection(GladiatorGame game) {
    if (game.state.gladiators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_mma, color: GameConstants.textMuted, size: 50),
            const SizedBox(height: 12),
            Text('Henüz gladyatör yok', style: TextStyle(color: GameConstants.textMuted)),
            Text('Pazardan satın alabilirsin', style: TextStyle(color: GameConstants.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: game.state.gladiators.length,
      itemBuilder: (context, index) {
        final gladiator = game.state.gladiators[index];
        return _buildGladiatorCard(gladiator, game);
      },
    );
  }

  Widget _buildGladiatorCard(dynamic gladiator, GladiatorGame game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameConstants.primaryDark.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gladiator.isInjured ? GameConstants.danger.withAlpha(100) : GameConstants.bloodRed.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          // Üst kısım
          Row(
            children: [
              // Avatar
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: GameConstants.bloodRed.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GameConstants.bloodRed.withAlpha(60)),
                ),
                child: Center(
                  child: Text(
                    gladiator.name[0],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GameConstants.bloodRed),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // İsim ve origin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          gladiator.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GameConstants.textLight),
                        ),
                        if (gladiator.isInjured) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.healing, color: GameConstants.danger, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      '${gladiator.origin} | ${gladiator.age} yaş',
                      style: TextStyle(fontSize: 11, color: GameConstants.textMuted),
                    ),
                  ],
                ),
              ),

              // Maaş
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('MAAŞ', style: TextStyle(fontSize: 9, color: GameConstants.textMuted)),
                  Text(
                    '${gladiator.salary}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GameConstants.gold),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Statlar
          Row(
            children: [
              _buildMiniStat('HP', gladiator.health, GameConstants.healthColor),
              _buildMiniStat('GÜÇ', gladiator.strength, GameConstants.strengthColor),
              _buildMiniStat('ZEKA', gladiator.intelligence, GameConstants.intelligenceColor),
              _buildMiniStat('KON', gladiator.stamina, GameConstants.staminaColor),
              _buildMiniStat('MORAL', gladiator.morale, GameConstants.gold),
            ],
          ),

          const SizedBox(height: 12),

          // Aksiyonlar
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'EĞİT',
                  Icons.fitness_center,
                  GameConstants.strengthColor,
                  gladiator.canTrain ? () => _showTrainDialog(gladiator, game) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'TEDAVİ',
                  Icons.healing,
                  GameConstants.healthColor,
                  gladiator.health < 100 ? () => _healGladiator(gladiator, game) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'KOV',
                  Icons.exit_to_app,
                  GameConstants.danger,
                  () => _showFireDialog(gladiator, game),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: GameConstants.textMuted)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$value',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: onTap != null ? color.withAlpha(30) : Colors.black12,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onTap != null ? color.withAlpha(80) : Colors.transparent),
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

  void _showTrainDialog(dynamic gladiator, GladiatorGame game) {
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
                _trainGladiator(gladiator, game, 'strength');
              },
            ),
            ListTile(
              leading: Icon(Icons.psychology, color: GameConstants.intelligenceColor),
              title: Text('Zeka Eğitimi', style: TextStyle(color: GameConstants.textLight)),
              subtitle: Text('+${GameConstants.trainingStatGain} Zeka | ${GameConstants.trainingCostBase} altın', style: TextStyle(color: GameConstants.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _trainGladiator(gladiator, game, 'intelligence');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run, color: GameConstants.staminaColor),
              title: Text('Kondisyon Eğitimi', style: TextStyle(color: GameConstants.textLight)),
              subtitle: Text('+${GameConstants.trainingStatGain} Kondisyon | ${GameConstants.trainingCostBase} altın', style: TextStyle(color: GameConstants.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _trainGladiator(gladiator, game, 'stamina');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _trainGladiator(dynamic gladiator, GladiatorGame game, String stat) {
    final success = game.trainGladiator(gladiator.id, stat);
    _showPopup(context, 'Eğitim', success, success ? 'Eğitim tamamlandı!' : 'Eğitim yapılamadı!');
  }

  void _healGladiator(dynamic gladiator, GladiatorGame game) {
    final success = game.healGladiator(gladiator.id);
    _showPopup(context, 'Tedavi', success, success ? 'Tedavi uygulandı!' : 'Tedavi yapılamadı!');
  }

  void _showFireDialog(dynamic gladiator, GladiatorGame game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.primaryBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('GLADYATÖRÜ KOV', style: TextStyle(color: GameConstants.danger)),
        content: Text(
          '${gladiator.name} kovulacak. Diğer gladyatörlerin morali düşecek.\n\nEmin misin?',
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
              Navigator.pop(ctx);
              game.fireGladiator(gladiator.id);
              _showPopup(context, gladiator.name, false, 'Gladyatör kovuldu!');
            },
            child: const Text('KOV'),
          ),
        ],
      ),
    );
  }

  // === POPUP ===
  void _showPopup(BuildContext context, String title, bool success, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GameConstants.primaryDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: success ? GameConstants.gold : GameConstants.danger,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (success ? GameConstants.gold : GameConstants.danger).withAlpha(50),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? GameConstants.gold : GameConstants.danger,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: success ? GameConstants.gold : GameConstants.danger,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 14, color: GameConstants.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: success ? GameConstants.gold : GameConstants.danger,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'TAMAM',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

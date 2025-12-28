import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';

class GamblingScreen extends StatefulWidget {
  const GamblingScreen({super.key});

  @override
  State<GamblingScreen> createState() => _GamblingScreenState();
}

class _GamblingScreenState extends State<GamblingScreen> {
  int selectedGame = 0; // 0: 21, 1: Zar

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Ana içerik
              selectedGame == 0
                  ? _Blackjack21Game(game: game)
                  : _DiceGame(game: game),

              // Üst bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Geri butonu
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        ),
                      ),

                      const Spacer(),

                      // Altın
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GameConstants.gold.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.paid, color: GameConstants.gold, size: 18),
                            const SizedBox(width: 6),
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
                      ),

                      const Spacer(),

                      // Oyun seçimi
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            _buildGameSwitcher(0, '21'),
                            const SizedBox(width: 4),
                            _buildGameSwitcher(1, 'ZAR'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameSwitcher(int index, String label) {
    final isSelected = selectedGame == index;
    return GestureDetector(
      onTap: () => setState(() => selectedGame = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// ============ 21 (BLACKJACK) OYUNU ============
class _Blackjack21Game extends StatefulWidget {
  final GladiatorGame game;

  const _Blackjack21Game({required this.game});

  @override
  State<_Blackjack21Game> createState() => _Blackjack21GameState();
}

class _Blackjack21GameState extends State<_Blackjack21Game> {
  final _random = Random();
  int betAmount = 50;
  bool isPlaying = false;
  bool gameOver = false;
  bool playerWon = false;

  List<int> playerCards = [];
  List<int> dealerCards = [];
  bool dealerRevealed = false;

  int get playerTotal => _calcTotal(playerCards);
  int get dealerTotal => _calcTotal(dealerCards);

  int _calcTotal(List<int> cards) {
    int total = 0, aces = 0;
    for (int c in cards) {
      if (c == 1) {
        aces++;
        total += 11;
      } else if (c >= 10) {
        total += 10;
      } else {
        total += c;
      }
    }
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    return total;
  }

  int _draw() => _random.nextInt(13) + 1;

  void _start() {
    if (widget.game.state.gold < betAmount) return;
    setState(() {
      isPlaying = true;
      gameOver = false;
      dealerRevealed = false;
      playerCards = [_draw(), _draw()];
      dealerCards = [_draw(), _draw()];
    });
    if (playerTotal == 21) _stand();
  }

  void _hit() {
    setState(() => playerCards.add(_draw()));
    if (playerTotal > 21) {
      _end(false);
    } else if (playerTotal == 21) {
      _stand();
    }
  }

  void _stand() {
    setState(() => dealerRevealed = true);
    while (dealerTotal < 17) {
      dealerCards.add(_draw());
    }
    setState(() {});
    if (dealerTotal > 21) {
      _end(true);
    } else if (playerTotal > dealerTotal) {
      _end(true);
    } else if (playerTotal < dealerTotal) {
      _end(false);
    } else {
      _end(null);
    }
  }

  void _end(bool? won) {
    setState(() {
      gameOver = true;
      playerWon = won == true;
      dealerRevealed = true;
    });
    if (won == true) {
      widget.game.state.modifyGold(betAmount);
    } else if (won == false) {
      widget.game.state.modifyGold(-betAmount);
    }
    widget.game.refreshState();
  }

  String _cardName(int v) {
    if (v == 1) return 'A';
    if (v == 11) return 'J';
    if (v == 12) return 'Q';
    if (v == 13) return 'K';
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan - 21.jpg
        Image.asset(
          'assets/21.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1a472a),
                  const Color(0xFF0d2818),
                ],
              ),
            ),
          ),
        ),

        // Karartma
        Container(color: Colors.black.withAlpha(120)),

        // Oyun içeriği
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              children: [
                const Spacer(),

                if (!isPlaying) ...[
                  // Bahis seçimi
                  Text(
                    'BAHİS SEÇ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [25, 50, 100, 200].map((b) => _betBtn(b)).toList(),
                  ),
                  const SizedBox(height: 24),
                  _actionBtn('OYNA', GameConstants.gold, _start),
                ] else ...[
                  // Krupiye kartları
                  _cardRow('Krupiye', dealerCards, dealerTotal, !dealerRevealed),
                  const SizedBox(height: 20),

                  // Sonuç
                  if (gameOver)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        playerTotal == dealerTotal
                            ? 'BERABERE'
                            : (playerWon ? '+$betAmount ALTIN' : '-$betAmount ALTIN'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: playerWon ? GameConstants.success : GameConstants.danger,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 50),

                  const SizedBox(height: 20),

                  // Oyuncu kartları
                  _cardRow('Sen', playerCards, playerTotal, false),
                  const SizedBox(height: 24),

                  if (gameOver) ...[
                    _actionBtn('YENİ OYUN', const Color(0xFF9C27B0), () {
                      setState(() {
                        isPlaying = false;
                        playerCards = [];
                        dealerCards = [];
                      });
                    }),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _actionBtn('ÇEK', GameConstants.success, _hit),
                        const SizedBox(width: 20),
                        _actionBtn('KAL', GameConstants.danger, _stand),
                      ],
                    ),
                  ],
                ],

                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _betBtn(int amount) {
    final sel = betAmount == amount;
    final can = widget.game.state.gold >= amount;
    return GestureDetector(
      onTap: can ? () => setState(() => betAmount = amount) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF9C27B0) : Colors.black45,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? const Color(0xFF9C27B0) : Colors.white24,
            width: sel ? 2 : 1,
          ),
        ),
        child: Text(
          '$amount',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: sel ? Colors.white : (can ? Colors.white70 : Colors.white30),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _cardRow(String title, List<int> cards, int total, bool hide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              Text(
                hide ? '?' : '$total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: total > 21 ? GameConstants.danger : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cards.length, (i) {
              final hidden = hide && i == 1;
              return Container(
                width: 45,
                height: 65,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: hidden ? const Color(0xFF9C27B0) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: hidden
                      ? const Icon(Icons.question_mark, color: Colors.white, size: 24)
                      : Text(
                          _cardName(cards[i]),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cards[i] == 1 || cards[i] >= 11 ? Colors.red : Colors.black,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============ ZAR OYUNU ============
class _DiceGame extends StatefulWidget {
  final GladiatorGame game;

  const _DiceGame({required this.game});

  @override
  State<_DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<_DiceGame> {
  final _random = Random();
  int betAmount = 50;
  bool isRolling = false;
  bool showResult = false;

  int p1 = 0, p2 = 0, o1 = 0, o2 = 0;
  int get pTotal => p1 + p2;
  int get oTotal => o1 + o2;

  void _roll() async {
    if (widget.game.state.gold < betAmount) return;

    setState(() {
      isRolling = true;
      showResult = false;
    });

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          p1 = _random.nextInt(6) + 1;
          p2 = _random.nextInt(6) + 1;
          o1 = _random.nextInt(6) + 1;
          o2 = _random.nextInt(6) + 1;
        });
      }
    }

    setState(() {
      isRolling = false;
      showResult = true;
    });

    if (pTotal > oTotal) {
      widget.game.state.modifyGold(betAmount);
    } else if (pTotal < oTotal) {
      widget.game.state.modifyGold(-betAmount);
    }
    widget.game.refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan - zar.jpg
        Image.asset(
          'assets/zar.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2d1f3d),
                  const Color(0xFF1a1225),
                ],
              ),
            ),
          ),
        ),

        // Karartma
        Container(color: Colors.black.withAlpha(100)),

        // Oyun içeriği
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              children: [
                const Spacer(),

                // Rakip zarları
                _diceRow('RAKİP', o1, o2, oTotal, GameConstants.danger),

                const SizedBox(height: 30),

                // Sonuç
                if (showResult)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pTotal > oTotal
                          ? '+$betAmount ALTIN'
                          : (pTotal < oTotal ? '-$betAmount ALTIN' : 'BERABERE'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: pTotal > oTotal
                            ? GameConstants.success
                            : (pTotal < oTotal ? GameConstants.danger : Colors.white54),
                      ),
                    ),
                  )
                else
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                    ),
                  ),

                const SizedBox(height: 30),

                // Oyuncu zarları
                _diceRow('SEN', p1, p2, pTotal, GameConstants.success),

                const SizedBox(height: 40),

                // Bahis seçimi
                if (!isRolling) ...[
                  Text(
                    'BAHİS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [25, 50, 100, 200].map((b) => _betBtn(b)).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Zar at butonu
                GestureDetector(
                  onTap: isRolling ? null : _roll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    decoration: BoxDecoration(
                      color: isRolling ? Colors.grey : const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isRolling
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF9C27B0).withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Text(
                      isRolling ? 'ATILIYOR...' : 'ZAR AT',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _betBtn(int amount) {
    final sel = betAmount == amount;
    final can = widget.game.state.gold >= amount;
    return GestureDetector(
      onTap: can ? () => setState(() => betAmount = amount) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF9C27B0) : Colors.black45,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? const Color(0xFF9C27B0) : Colors.white24,
            width: sel ? 2 : 1,
          ),
        ),
        child: Text(
          '$amount',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: sel ? Colors.white : (can ? Colors.white70 : Colors.white30),
          ),
        ),
      ),
    );
  }

  Widget _diceRow(String title, int d1, int d2, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withAlpha(180),
                  letterSpacing: 2,
                ),
              ),
              if (d1 > 0)
                Text(
                  '$total',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _die(d1, color),
              const SizedBox(width: 20),
              _die(d2, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _die(int value, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: value > 0 ? CustomPaint(painter: _DiePainter(value, color)) : null,
    );
  }
}

class _DiePainter extends CustomPainter {
  final int value;
  final Color color;
  _DiePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = size.width * 0.1;
    final positions = <Offset>[];

    switch (value) {
      case 1:
        positions.add(const Offset(0.5, 0.5));
        break;
      case 2:
        positions.addAll([const Offset(0.3, 0.3), const Offset(0.7, 0.7)]);
        break;
      case 3:
        positions.addAll([const Offset(0.3, 0.3), const Offset(0.5, 0.5), const Offset(0.7, 0.7)]);
        break;
      case 4:
        positions.addAll([
          const Offset(0.3, 0.3),
          const Offset(0.7, 0.3),
          const Offset(0.3, 0.7),
          const Offset(0.7, 0.7)
        ]);
        break;
      case 5:
        positions.addAll([
          const Offset(0.3, 0.3),
          const Offset(0.7, 0.3),
          const Offset(0.5, 0.5),
          const Offset(0.3, 0.7),
          const Offset(0.7, 0.7)
        ]);
        break;
      case 6:
        positions.addAll([
          const Offset(0.3, 0.3),
          const Offset(0.7, 0.3),
          const Offset(0.3, 0.5),
          const Offset(0.7, 0.5),
          const Offset(0.3, 0.7),
          const Offset(0.7, 0.7)
        ]);
        break;
    }

    for (final p in positions) {
      canvas.drawCircle(Offset(p.dx * size.width, p.dy * size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';
import '../services/save_service.dart';
import 'tutorial_screen.dart';
import 'home_screen.dart';

class StoryIntroScreen extends StatefulWidget {
  const StoryIntroScreen({super.key});

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> with SingleTickerProviderStateMixin {
  int _currentDialogueIndex = 0;
  bool _showResponses = false;
  bool _isWaitingForResponse = false;
  List<Map<String, dynamic>>? _currentResponseReactions;
  int _currentReactionIndex = 0;
  String? _selectedResponse;
  int _responseRound = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // İlk otomatik diyaloglar
  final List<Map<String, dynamic>> _initialDialogues = [
    {
      'text': 'Uzun yıllar önce, Roma\'nın karanlık sokaklarında bir sır saklanıyordu. Sen, küçük bir çocukken, annen sana gerçeği söyleyemedi.',
      'speaker': 'Dayı',
    },
    {
      'text': 'Sezar... Roma İmparatoru Sezar, senin gerçek baban. Ama o, anneni kandırdı. Ona yalan söyledi, seni terk etti. Annen bunu öğrenince çıldırdı, seni bana bıraktı ve kaçtı.',
      'speaker': 'Dayı',
    },
    {
      'text': 'Sezar, seni öldürmek istiyor. Çünkü sen onun tek varisi olacaksın ve o, tüm gücünü kaybetmek istemiyor. Şimdi burada, bu gladyatör okulunda güçlenmen lazım. Sezar\'dan intikam alman gerekiyor.',
      'speaker': 'Dayı',
    },
    {
      'text': 'Ben sana yol göstereceğim, merak etme. Senin için her şeyi hazırladım. Bu gladyatör okulunda eğitileceksin, güçleneceksin ve sonunda Sezar\'ı yeneceksin.',
      'speaker': 'Dayı',
    },
  ];

  final List<String> _initialResponseOptions = [
    'Siktir git',
    'Sezar\'ı öldüreceğim',
    'Sana inanmıyorum, def ol',
    'Anlat devam et',
  ];

  final List<String> _secondResponseOptions = [
    'Tamam, anladım',
    'Hala sana inanmıyorum',
    'Sezar\'ı öldüreceğim',
    'Daha fazla anlat',
  ];

  final List<String> _thirdResponseOptions = [
    'Peki, ne yapmalıyım?',
    'Bu çok fazla, git',
    'Sezar\'ı öldüreceğim',
    'Kanıtları göster',
  ];

  final Map<String, List<Map<String, dynamic>>> _responseReactions = {
    'Siktir git': [
      {
        'text': 'Anlıyorum, şoktasın. Bu ağır bir gerçek. Ama dinle beni... Annen seni bana bıraktı çünkü Sezar\'ın gerçek yüzünü öğrendi.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Sezar, Roma\'nın en güçlü adamı. Ama o, seni öldürmek istiyor. Eğer burada kalıp güçlenmezsen, o seni bulacak ve öldürecek. Burada güvendesin.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Şimdi senin seçimin var: Ya burada kalıp güçlenirsin ve intikamını alırsın, ya da Sezar\'ın eline düşersin. Ama unutma, o seni arıyor.',
        'speaker': 'Dayı',
      },
    ],
    'Sana inanmıyorum, def ol': [
      {
        'text': 'İnanmak zorunda değilsin, ama gerçek bu. Bak, burada kanıtlar var. Annenin bıraktığı mektup, Sezar\'ın seni arayan adamlarına verdiği emirler...',
        'speaker': 'Dayı',
      },
      {
        'text': 'Eğer bana inanmıyorsan, git. Ama bir gün gerçekle yüzleşeceksin. O zaman beni hatırla. Ben senin yanındayım, her zaman olacağım.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Sezar\'ın gücü çok büyük. Ama sen, onun oğlusun. Sen de o kadar güçlü olabilirsin. Sadece burada kal ve eğitil.',
        'speaker': 'Dayı',
      },
    ],
    'Anlat devam et': [
      {
        'text': 'İyi, dinliyorsun. Sezar, Roma\'nın en acımasız imparatoru. Seni öldürmek istiyor çünkü sen onun tek varisi olacaksın ve o, tahtını kaybetmek istemiyor.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Annen, Sezar\'ın gerçek yüzünü öğrendiğinde, seni bana bıraktı ve kaçtı. O günden beri seni koruyorum. Şimdi sıra sende.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Bu gladyatör okulunda eğitileceksin, güçleneceksin ve sonunda Sezar\'ı yeneceksin. Hazır mısın? Bu yol zorlu olacak, ama ben seninle olacağım.',
        'speaker': 'Dayı',
      },
    ],
    'Hala sana inanmıyorum': [
      {
        'text': 'Anlıyorum, güven zor kazanılır. Ama bak, burada annenin bıraktığı bir mektup var. "Oğlumu koru, Sezar onu öldürmek istiyor. Senin yanında güvende olacak."',
        'speaker': 'Dayı',
      },
      {
        'text': 'Ve işte Sezar\'ın seni arayan adamlarına verdiği emir. "O çocuğu bulun ve öldürün, tahtımı almayacak." Gerçek bu, istersen kanıtları görebilirsin.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Eğer hala inanmıyorsan, bu senin seçimin. Ama bir gün gerçekle karşılaştığında, ben burada olacağım. Seni korumaya devam edeceğim.',
        'speaker': 'Dayı',
      },
    ],
    'Daha fazla anlat': [
      {
        'text': 'Sezar, Roma\'nın en güçlü imparatoru. Ama o, seni öldürmek istiyor çünkü sen onun tek varisi olacaksın. O, tahtını kaybetmek istemiyor.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Annen, Sezar\'ın gerçek yüzünü öğrendiğinde, seni bana bıraktı ve kaçtı. O günden beri seni koruyorum. Şimdi sıra sende.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Bu gladyatör okulunda eğitileceksin, güçleneceksin ve sonunda Sezar\'ı yeneceksin. Her adımda yanında olacağım. Hazır mısın?',
        'speaker': 'Dayı',
      },
    ],
    'Bu çok fazla, git': [
      {
        'text': 'Anlıyorum, bu ağır bir yük. Ama düşün, eğer gitmezsen Sezar seni bulacak ve öldürecek. Burada güvendesin.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Sana zaman veriyorum. Düşün, karar ver. Ama unutma, zaman geçtikçe Sezar\'a daha yakın oluyorsun. Onun gücü her geçen gün artıyor.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Eğer şimdi gitmezsen, bir gün Sezar\'ın askerleri seni bulacak. O zaman kaçış yok. Burada kal ve güçlen.',
        'speaker': 'Dayı',
      },
    ],
    'Kanıtları göster': [
      {
        'text': 'Tabii, işte annenin mektubu. "Oğlumu koru, Sezar onu öldürmek istiyor. Senin yanında güvende olacak. Lütfen onu koru."',
        'speaker': 'Dayı',
      },
      {
        'text': 'Ve işte Sezar\'ın seni arayan askerlerine verdiği emir. "O çocuğu bulun ve öldürün, tahtımı almayacak. Hiçbir şeyden çekinmeyin."',
        'speaker': 'Dayı',
      },
      {
        'text': 'Görüyorsun, gerçek bu. Sezar seni öldürmek istiyor. Ama sen, onun oğlusun. Sen de o kadar güçlü olabilirsin. Sadece burada kal ve eğitil.',
        'speaker': 'Dayı',
      },
    ],
    'Tamam, anladım': [
      {
        'text': 'İyi, anladın. Şimdi bu gladyatör okulunda eğitileceksin. Güçleneceksin ve sonunda Sezar\'ı yeneceksin. Ben seninle olacağım, her adımda yanında olacağım.',
        'speaker': 'Dayı',
      },
      {
        'text': 'Hazır mısın? Bu yol zorlu olacak, ama sen güçlüsün. Sezar\'ın oğlusun, onun kadar güçlü olabilirsin.',
        'speaker': 'Dayı',
      },
    ],
  };

  List<String> get _currentResponseOptions {
    if (_responseRound == 0) {
      return _initialResponseOptions;
    } else if (_responseRound == 1) {
      return _secondResponseOptions;
    } else {
      return _thirdResponseOptions;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentDialogue;
    if (_isWaitingForResponse && _currentResponseReactions != null) {
      currentDialogue = _currentResponseReactions![_currentReactionIndex];
    } else {
      currentDialogue = _initialDialogues[_currentDialogueIndex.clamp(0, _initialDialogues.length - 1)];
    }

    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        return GestureDetector(
          onTap: _isWaitingForResponse ? _advanceDialogue : (_showResponses ? null : _advanceDialogue),
          onTapDown: (details) {
            if (!_showResponses && !_isWaitingForResponse) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.localPosition.dx < screenWidth / 3) {
                _goBackDialogue();
              } else if (details.localPosition.dx > screenWidth * 2 / 3) {
                _advanceDialogue();
              } else {
                _advanceDialogue();
              }
            }
          },
          child: Scaffold(
            backgroundColor: GameConstants.primaryDark,
            body: SafeArea(
              child: Stack(
                children: [
                  // Arka plan resmi
                  Positioned.fill(
                    child: Image.asset(
                      'assets/unnamed.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: GameConstants.primaryDark,
                      ),
                    ),
                  ),

                  // Hafif karartma - metinlerin okunabilirliği için
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

                  // Geri butonu (her zaman görünür, sadece ilk diyalogda ve ilk tepkide gizli)
                  if (_currentDialogueIndex > 0 || (_isWaitingForResponse && _currentReactionIndex > 0) || _showResponses)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: _goBackDialogue,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(200),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: GameConstants.bronze,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: GameConstants.textLight,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                  // Ana içerik
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Karakter portresi - sağa hizalı, ekranın ortasının biraz üstünde
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 200,
                          height: 200,
                          margin: const EdgeInsets.only(right: 16, top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GameConstants.bronze,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameConstants.bronze.withAlpha(50),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/defaultasker.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: GameConstants.primaryBrown,
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: GameConstants.gold.withAlpha(150),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withAlpha(60),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ORTA: Diyalog kutusu - metin boyutuna göre dinamik
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35,
                        ),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: GameConstants.bronze,
                            width: 2,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currentDialogue['text'],
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: GameConstants.textLight,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                  // ALT: Cevaplar veya "Devam etmek için dokunun"
                  if (_showResponses && !_isWaitingForResponse)
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _currentResponseOptions.length,
                        itemBuilder: (context, index) {
                          return _buildResponseButton(
                            _currentResponseOptions[index],
                            index,
                            game,
                          );
                        },
                      ),
                    )
                  else if (!_showResponses)
                    // "Devam etmek için dokunun" butonu - animasyonlu
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: GameConstants.bronze.withOpacity(0.5 + (_pulseAnimation.value - 0.8) * 2.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GameConstants.gold.withOpacity((_pulseAnimation.value - 0.8) * 2.5 * 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 22,
                                  color: GameConstants.gold.withOpacity(0.7 + (_pulseAnimation.value - 0.8) * 2.5 * 0.3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Devam etmek için dokunun',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: GameConstants.textLight,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
                      ]
            ),
          ),
        ));
      },
    );
  }

  void _advanceDialogue() {
    if (_isWaitingForResponse && _currentResponseReactions != null) {
      if (_currentReactionIndex < _currentResponseReactions!.length - 1) {
        setState(() {
          _currentReactionIndex++;
        });
      } else {
        setState(() {
          _isWaitingForResponse = false;
          _showResponses = true;
          _currentResponseReactions = null;
          _currentReactionIndex = 0;
          _responseRound++;
        });
      }
    } else {
      if (_currentDialogueIndex < _initialDialogues.length - 1) {
        setState(() {
          _currentDialogueIndex++;
        });
      } else {
        setState(() {
          _showResponses = true;
        });
      }
    }
  }

  void _goBackDialogue() {
    if (_showResponses) {
      // Cevap seçenekleri gösteriliyorsa, önceki duruma dön
      if (_currentResponseReactions != null && _currentResponseReactions!.isNotEmpty) {
        // Tepkilerden sonra cevap seçeneklerine dönmüşsek, tepkilere geri dön
        setState(() {
          _showResponses = false;
          _isWaitingForResponse = true;
          _currentReactionIndex = _currentResponseReactions!.length - 1;
        });
      } else {
        // İlk cevap seçeneklerine dönmüşsek, son diyaloga geri dön
        setState(() {
          _showResponses = false;
          _currentDialogueIndex = _initialDialogues.length - 1;
        });
      }
    } else if (_isWaitingForResponse && _currentResponseReactions != null) {
      // Tepki dizisinde geri git
      if (_currentReactionIndex > 0) {
        setState(() {
          _currentReactionIndex--;
        });
      } else {
        // İlk tepkiye geri döndü, cevap seçeneklerine geri dön
        setState(() {
          _isWaitingForResponse = false;
          _showResponses = true;
          _currentResponseReactions = null;
          _currentReactionIndex = 0;
          // Cevap turunu azalt (eğer mümkünse)
          if (_responseRound > 0) {
            _responseRound--;
          }
        });
      }
    } else {
      // Normal diyalog geri gitme
      if (_currentDialogueIndex > 0) {
        setState(() {
          _currentDialogueIndex--;
        });
      }
    }
  }

  Widget _buildResponseButton(String text, int index, GladiatorGame game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _handleResponse(text, index, game),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GameConstants.bloodRed,
                GameConstants.buttonPrimary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GameConstants.gold.withAlpha(150),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameConstants.bloodRed.withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GameConstants.textLight,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _handleResponse(String response, int index, GladiatorGame game) async {
    _selectedResponse = response;
    
    if (response == 'Sezar\'ı öldüreceğim' || response == 'Peki, ne yapmalıyım?' || response == 'Tamam, anladım') {
      _startGame(game);
      return;
    }

    final reactions = _responseReactions[response];
    if (reactions != null && reactions.isNotEmpty) {
      setState(() {
        _isWaitingForResponse = true;
        _showResponses = false;
        _currentResponseReactions = reactions;
        _currentReactionIndex = 0;
      });
    } else {
      _startGame(game);
    }
  }

  void _startGame(GladiatorGame game) async {
    game.startGame();
    await SaveService.autoSave(game.state);

    if (mounted) {
      final tutorialSeen = await SaveService.hasTutorialSeen();
      
      if (!tutorialSeen) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: game,
              child: TutorialScreen(
                onComplete: () {
                  Navigator.pop(context);
                  SaveService.setTutorialSeen();
                },
              ),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: game,
              child: const HomeScreen(),
            ),
          ),
        );
      }
    }
  }
}

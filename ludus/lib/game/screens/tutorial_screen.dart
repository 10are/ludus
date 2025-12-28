import 'package:flutter/material.dart';
import '../constants.dart';

/// Tutorial step data
class TutorialStep {
  final String title;
  final String message;
  final Color accentColor;
  final IconData icon;
  final bool showAbove; // true = tooltip above highlight, false = below

  TutorialStep({
    required this.title,
    required this.message,
    required this.accentColor,
    required this.icon,
    this.showAbove = false,
  });
}

/// Tutorial screen that overlays on HomeScreen and highlights elements
class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Tutorial steps
  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Hoş Geldin Lanista!',
      message: 'Ben Doctore, gladyatör eğitmenin. Sana bu okulu yönetmeyi öğreteceğim. Bu ana ekrandan tüm bölümlere erişebilirsin.',
      accentColor: GameConstants.gold,
      icon: Icons.waving_hand,
    ),
    TutorialStep(
      title: 'Durum Çubuğu',
      message: 'Burada hafta sayısı, itibarın ve altın miktarını görürsün. Altın her şey için lazım - iyi yönet!',
      accentColor: GameConstants.gold,
      icon: Icons.info,
      showAbove: false,
    ),
    TutorialStep(
      title: 'Arena',
      message: 'Gladyatörlerini savaştırırsın. Resmi dövüşler itibar, yeraltı daha fazla altın verir ama riskli!',
      accentColor: GameConstants.bloodRed,
      icon: Icons.stadium,
      showAbove: false,
    ),
    TutorialStep(
      title: 'Diplomasi',
      message: 'Senatörler ve lanistalarla ilişkini yönet. İyi ilişkiler özel fırsatlar getirir!',
      accentColor: GameConstants.bronze,
      icon: Icons.handshake,
      showAbove: false,
    ),
    TutorialStep(
      title: 'Pazar',
      message: 'Yeni köleler ve personel al. Doktorlar iyileştirir, eğitmenler bonus verir.',
      accentColor: GameConstants.gold,
      icon: Icons.store,
      showAbove: true,
    ),
    TutorialStep(
      title: 'Kumar',
      message: '21 ve Zar oyunlarıyla şansını dene. Dikkat - tüm altınını kaybedebilirsin!',
      accentColor: const Color(0xFF9C27B0),
      icon: Icons.casino,
      showAbove: true,
    ),
    TutorialStep(
      title: 'Ludus (Okul)',
      message: 'Gladyatörlerini eğit ve tedavi et. Güç, zeka, kondisyon eğitimleri ver!',
      accentColor: GameConstants.copper,
      icon: Icons.school,
      showAbove: true,
    ),
    TutorialStep(
      title: 'Colosseum',
      message: 'Her 5 haftada bir açılır! Kazanırsan büyük ödüller, kaybedersen gladyatörün ölür.',
      accentColor: GameConstants.gold,
      icon: Icons.domain,
      showAbove: false,
    ),
    TutorialStep(
      title: 'Hafta Geçir',
      message: 'Her hafta maaş öde. Ödeyemezsen isyan çıkar! Altınını iyi yönet Lanista!',
      accentColor: GameConstants.warmOrange,
      icon: Icons.skip_next,
      showAbove: true,
    ),
    TutorialStep(
      title: 'Hazırsın!',
      message: 'Şimdi git ve Roma\'nın en güçlü ludusunu kur! Zafer seni bekliyor Lanista!',
      accentColor: GameConstants.gold,
      icon: Icons.emoji_events,
    ),
  ];

  // Highlight positions for each step
  Rect? _getHighlightRect(int step, Size screenSize) {
    final padding = MediaQuery.of(context).padding;
    final safeTop = padding.top;

    switch (step) {
      case 0: // Welcome - no highlight
        return null;
      case 1: // Top bar
        return Rect.fromLTWH(12, safeTop + 8, screenSize.width - 24, 60);
      case 2: // Arena - sol üst
        return Rect.fromLTWH(20, safeTop + 90, 72, 95);
      case 3: // Diplomacy - sağ üst
        return Rect.fromLTWH(screenSize.width - 92, safeTop + 90, 72, 95);
      case 4: // Market - sol alt
        return Rect.fromLTWH(20, screenSize.height - padding.bottom - 195, 72, 95);
      case 5: // Gambling - orta alt
        return Rect.fromLTWH(screenSize.width / 2 - 36, screenSize.height - padding.bottom - 195, 72, 95);
      case 6: // Ludus - sağ alt
        return Rect.fromLTWH(screenSize.width - 92, screenSize.height - padding.bottom - 195, 72, 95);
      case 7: // Colosseum - ortada
        return Rect.fromLTWH(screenSize.width / 2 - 60, screenSize.height / 2 - 80, 120, 140);
      case 8: // Week button - en altta
        return Rect.fromLTWH(screenSize.width / 2 - 90, screenSize.height - padding.bottom - 80, 180, 60);
      case 9: // Final - no highlight
        return null;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final step = _steps[_currentStep];
    final highlightRect = _getHighlightRect(_currentStep, screenSize);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _next,
        child: Stack(
          children: [
            // Background - arena.gif
            Positioned.fill(
              child: Image.asset(
                'assets/arena.gif',
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),

            // Sun effect
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withAlpha(80),
                      const Color(0xFFFF8C00).withAlpha(50),
                      const Color(0xFFFF4500).withAlpha(20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Simulated home screen icons
            _buildSimulatedHomeScreen(screenSize),

            // Dark overlay with cutout for highlight
            if (highlightRect != null)
              _buildCutoutOverlay(highlightRect, screenSize)
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(180),
                ),
              ),

            // Pulsing highlight border
            if (highlightRect != null)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: highlightRect.left - 8,
                    top: highlightRect.top - 8,
                    child: Container(
                      width: highlightRect.width + 16,
                      height: highlightRect.height + 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: step.accentColor.withAlpha((200 * _pulseAnimation.value).toInt()),
                          width: 3 * _pulseAnimation.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: step.accentColor.withAlpha((100 * _pulseAnimation.value).toInt()),
                            blurRadius: 20 * _pulseAnimation.value,
                            spreadRadius: 5 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Dynamic tooltip positioned relative to highlight
            _buildDynamicTooltip(step, highlightRect, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicTooltip(TutorialStep step, Rect? highlightRect, Size screenSize) {
    final padding = MediaQuery.of(context).padding;

    // Calculate position based on highlight
    double tooltipTop;
    double tooltipLeft = 16;
    double tooltipRight = 16;

    if (highlightRect == null) {
      // Center on screen for welcome/final
      tooltipTop = screenSize.height / 2 - 100;
    } else if (step.showAbove) {
      // Show above the highlight
      tooltipTop = highlightRect.top - 180;
      if (tooltipTop < padding.top + 20) {
        tooltipTop = padding.top + 20;
      }
    } else {
      // Show below the highlight
      tooltipTop = highlightRect.bottom + 20;
      if (tooltipTop + 160 > screenSize.height - padding.bottom - 20) {
        tooltipTop = screenSize.height - padding.bottom - 180;
      }
    }

    return Positioned(
      top: tooltipTop,
      left: tooltipLeft,
      right: tooltipRight,
      child: _buildTooltipContent(step),
    );
  }

  Widget _buildTooltipContent(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.primaryDark.withAlpha(250),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: step.accentColor.withAlpha(180),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: step.accentColor.withAlpha(60),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker avatar
          _SpeakingAvatar(accentColor: step.accentColor),

          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with icon
                Row(
                  children: [
                    Icon(step.icon, color: step.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: step.accentColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Message
                Text(
                  step.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: GameConstants.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Tap to continue hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: step.accentColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: step.accentColor.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStep == _steps.length - 1 ? 'BAŞLA' : 'DEVAM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: step.accentColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _currentStep == _steps.length - 1 ? Icons.play_arrow : Icons.touch_app,
                            color: step.accentColor,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCutoutOverlay(Rect highlightRect, Size screenSize) {
    return CustomPaint(
      size: screenSize,
      painter: _CutoutPainter(
        cutoutRect: highlightRect,
        overlayColor: Colors.black.withAlpha(200),
      ),
    );
  }

  Widget _buildSimulatedHomeScreen(Size screenSize) {
    final padding = MediaQuery.of(context).padding;
    final safeTop = padding.top;

    return Stack(
      children: [
        // Top bar simulation
        Positioned(
          top: safeTop + 8,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: GameConstants.primaryDark.withAlpha(200),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameConstants.gold.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: GameConstants.gold.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.settings, color: GameConstants.gold, size: 20),
                ),
                Text('1. HAFTA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameConstants.textLight)),
                Row(
                  children: [
                    Icon(Icons.star, color: GameConstants.gold, size: 16),
                    const SizedBox(width: 4),
                    Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameConstants.gold)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.paid, color: GameConstants.gold, size: 16),
                    const SizedBox(width: 4),
                    Text('500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameConstants.gold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Arena - sol üst
        Positioned(
          top: safeTop + 90,
          left: 20,
          child: _buildSimulatedIcon('Arena', GameConstants.bloodRed, 'assets/arena.png'),
        ),

        // Diplomacy - sağ üst
        Positioned(
          top: safeTop + 90,
          right: 20,
          child: _buildSimulatedIcon('Diplomasi', GameConstants.bronze, 'assets/karin.jpg'),
        ),

        // Market - sol alt
        Positioned(
          bottom: padding.bottom + 100,
          left: 20,
          child: _buildSimulatedIcon('Pazar', GameConstants.gold, 'assets/pazar.png'),
        ),

        // Gambling - orta alt
        Positioned(
          bottom: padding.bottom + 100,
          left: 0,
          right: 0,
          child: Center(
            child: _buildSimulatedIcon('Kumar', const Color(0xFF9C27B0), 'assets/21.jpg'),
          ),
        ),

        // Ludus - sağ alt
        Positioned(
          bottom: padding.bottom + 100,
          right: 20,
          child: _buildSimulatedIcon('Ludus', GameConstants.copper, 'assets/okul.jpg'),
        ),

        // Colosseum - ortada
        Positioned(
          top: 0,
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(
            child: _buildSimulatedColosseum(),
          ),
        ),

        // Week button - en altta
        Positioned(
          bottom: padding.bottom + 20,
          left: 0,
          right: 0,
          child: Center(
            child: _buildSimulatedWeekButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedIcon(String label, Color color, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(150), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(50),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: GameConstants.primaryDark,
                child: Center(
                  child: Text(
                    label[0],
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: GameConstants.textLight,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedColosseum() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameConstants.primaryDark.withAlpha(200),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600, width: 3),
          ),
          child: Icon(Icons.stadium, size: 50, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Text(
          'COLOSSEUM',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 2,
            shadows: [Shadow(color: Colors.black, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withAlpha(150),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Text(
            '5. haftada açılır',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedWeekButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GameConstants.buttonPrimary, GameConstants.warmOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameConstants.gold.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: GameConstants.warmOrange.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.skip_next, size: 28, color: GameConstants.textLight),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HAFTA GEÇİR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GameConstants.textLight,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '-0 altın',
                style: TextStyle(fontSize: 11, color: GameConstants.gold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for cutout overlay
class _CutoutPainter extends CustomPainter {
  final Rect cutoutRect;
  final Color overlayColor;

  _CutoutPainter({
    required this.cutoutRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)));

    final combinedPath = Path.combine(PathOperation.difference, fullPath, cutoutPath);

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter oldDelegate) {
    return cutoutRect != oldDelegate.cutoutRect || overlayColor != oldDelegate.overlayColor;
  }
}

/// Animated speaking avatar - compact version
class _SpeakingAvatar extends StatefulWidget {
  final Color accentColor;

  const _SpeakingAvatar({required this.accentColor});

  @override
  State<_SpeakingAvatar> createState() => _SpeakingAvatarState();
}

class _SpeakingAvatarState extends State<_SpeakingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_controller.value * 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.accentColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withAlpha(80),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/defaultasker.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: GameConstants.primaryDark,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DOCTORE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: widget.accentColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

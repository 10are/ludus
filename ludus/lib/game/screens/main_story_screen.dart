import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gladiator_game.dart';
import '../constants.dart';
import '../models/game_state.dart';

class MainStoryScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final VoidCallback onComplete;

  const MainStoryScreen({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<MainStoryScreen> createState() => _MainStoryScreenState();
}

class _MainStoryScreenState extends State<MainStoryScreen> with TickerProviderStateMixin {
  int _currentDialogueIndex = 0;
  bool _showChoices = false;
  bool _showResult = false;
  String _resultText = '';
  String? _pathChosen;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getDialogues() {
    final game = Provider.of<GladiatorGame>(context, listen: false);
    final path = game.state.mainStory.path;

    // Path-specific dialogues
    if (widget.event['path_specific'] != null) {
      final pathSpecific = widget.event['path_specific'] as Map<String, dynamic>;
      String pathKey = 'none';
      if (path == StoryPath.vengeance) pathKey = 'vengeance';
      if (path == StoryPath.loyalty) pathKey = 'loyalty';

      if (pathSpecific.containsKey(pathKey)) {
        final pathData = pathSpecific[pathKey] as Map<String, dynamic>;
        if (pathData['dialogue'] != null) {
          return List<Map<String, dynamic>>.from(pathData['dialogue']);
        }
      }
    }

    // Normal dialogues
    if (widget.event['dialogue'] != null) {
      return List<Map<String, dynamic>>.from(widget.event['dialogue']);
    }

    return [];
  }

  List<Map<String, dynamic>> _getChoices() {
    final game = Provider.of<GladiatorGame>(context, listen: false);
    final path = game.state.mainStory.path;

    // Path-specific choices
    if (widget.event['path_specific'] != null) {
      final pathSpecific = widget.event['path_specific'] as Map<String, dynamic>;
      String pathKey = 'none';
      if (path == StoryPath.vengeance) pathKey = 'vengeance';
      if (path == StoryPath.loyalty) pathKey = 'loyalty';

      if (pathSpecific.containsKey(pathKey)) {
        final pathData = pathSpecific[pathKey] as Map<String, dynamic>;
        if (pathData['choices'] != null) {
          return List<Map<String, dynamic>>.from(pathData['choices']);
        }
      }
    }

    // Normal choices
    if (widget.event['choices'] != null) {
      return List<Map<String, dynamic>>.from(widget.event['choices']);
    }

    return [];
  }

  void _nextDialogue() {
    final dialogues = _getDialogues();

    if (_currentDialogueIndex < dialogues.length - 1) {
      setState(() {
        _currentDialogueIndex++;
      });
      _fadeController.reset();
      _fadeController.forward();
    } else {
      // Dialogues finished, show choices
      setState(() {
        _showChoices = true;
      });
    }
  }

  void _selectChoice(Map<String, dynamic> choice) {
    final game = Provider.of<GladiatorGame>(context, listen: false);

    // Check requirements
    if (choice['requires'] != null) {
      final requires = choice['requires'] as Map<String, dynamic>;

      if (requires['min_gold'] != null) {
        if (game.state.gold < (requires['min_gold'] as int)) {
          _showNotEnoughGold();
          return;
        }
      }

      if (requires['min_gladiators'] != null) {
        if (game.state.gladiators.length < (requires['min_gladiators'] as int)) {
          _showNotEnoughGladiators();
          return;
        }
      }

      if (requires['min_family_loyalty'] != null) {
        if (game.state.mainStory.familyLoyalty < (requires['min_family_loyalty'] as int)) {
          _showNotEnoughFamilyLoyalty();
          return;
        }
      }
    }

    // Check path requirement
    if (choice['requires_path'] != null) {
      final requiredPath = choice['requires_path'] as String;
      if (requiredPath == 'vengeance' && game.state.mainStory.path != StoryPath.vengeance) {
        return;
      }
      if (requiredPath == 'loyalty' && game.state.mainStory.path != StoryPath.loyalty) {
        return;
      }
    }

    // Apply choice
    final result = game.applyMainStoryChoice(widget.event, choice);

    setState(() {
      _showChoices = false;
      _showResult = true;
      _resultText = result.consequence;
      _pathChosen = result.pathChosen;
    });
  }

  void _showNotEnoughGold() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeterli altının yok!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showNotEnoughGladiators() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeterli gladyatörün yok!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showNotEnoughFamilyLoyalty() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aile sadakati yetersiz!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Mount&Blade tarzı tutarlı renk - tüm diyaloglar için Roma bronz/altın tonu
  Color _getEventTypeColor() {
    final type = widget.event['type'] as String? ?? 'story';
    switch (type) {
      case 'critical':
      case 'finale':
        return GameConstants.gold; // Önemli anlar için altın
      default:
        return GameConstants.bronze; // Diğer tüm diyaloglar için bronz
    }
  }

  String _getSpeakerName(String speaker) {
    switch (speaker) {
      case 'narrator':
        return 'Anlatıcı';
      case 'wife':
        return 'Karın';
      case 'caesar':
        return 'Sezar';
      case 'brutus':
        return 'Brutus';
      case 'cassius':
        return 'Cassius';
      case 'praetorian_commander':
        return 'Quintus Maximus';
      case 'egyptian_merchant':
        return 'Ptolemy';
      case 'fathers_friend':
        return 'Marcus Aurelius';
      case 'spy':
        return 'Corvus';
      case 'doctore':
        return 'Doctore';
      case 'gladiator':
        return 'Gladyatör';
      case 'guard':
        return 'Muhafız';
      case 'servant':
        return 'Uşak';
      case 'stranger':
        return 'Yabancı';
      case 'fathers_letter':
        return 'Babanın Mektubu';
      case 'letter':
        return 'Mektup';
      case 'herald':
        return 'Tellal';
      case 'crowd':
        return 'Kalabalık';
      case 'old_friend':
        return 'Eski Dost';
      case 'senator':
        return 'Senatör';
      case 'tax_collector':
        return 'Vergi Tahsildarı';
      case 'merchant':
        return 'Tüccar';
      case 'patron':
        return 'Patron';
      case 'doctor':
        return 'Doktor';
      case 'midwife':
        return 'Ebe';
      case 'solonius':
        return 'Solonius';
      default:
        return speaker;
    }
  }

  // Mount&Blade tarzı tutarlı renk - konuşmacıya göre sadece altın/bronz tonları
  Color _getSpeakerColor(String speaker) {
    switch (speaker) {
      case 'narrator':
        return GameConstants.textMuted; // Anlatıcı için soluk ton
      case 'caesar':
        return GameConstants.gold; // İmparator için altın
      default:
        return GameConstants.bronze; // Diğer herkes için bronz
    }
  }

  IconData _getSpeakerIcon(String speaker) {
    switch (speaker) {
      case 'narrator':
        return Icons.menu_book;
      case 'wife':
        return Icons.favorite;
      case 'caesar':
        return Icons.account_balance;
      case 'brutus':
      case 'cassius':
        return Icons.gavel;
      case 'praetorian_commander':
        return Icons.shield;
      case 'spy':
        return Icons.visibility;
      case 'guard':
        return Icons.security;
      case 'gladiator':
        return Icons.sports_kabaddi;
      case 'fathers_letter':
      case 'letter':
        return Icons.mail;
      case 'crowd':
        return Icons.groups;
      default:
        return Icons.person;
    }
  }

  // Konuşmacı için resim yolu - Mount&Blade tarzı portre desteği
  String? _getSpeakerImage(String speaker) {
    switch (speaker) {
      case 'wife':
        return 'assets/karin.jpg';
      case 'doctore':
        return 'assets/defaultasker.png';
      default:
        return null; // İkon kullanılacak
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventType = widget.event['type'] as String? ?? 'story';
    final title = widget.event['title'] as String? ?? 'Olay';
    final scene = widget.event['scene'] as String?;
    final typeColor = _getEventTypeColor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              typeColor.withValues(alpha: 0.3),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(title, eventType, typeColor),

              // Scene description
              if (scene != null && !_showResult) _buildSceneBox(scene),

              // Main content
              Expanded(
                child: _showResult
                    ? _buildResultView()
                    : _showChoices
                        ? _buildChoicesView()
                        : _buildDialogueView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String eventType, Color typeColor) {
    final game = Provider.of<GladiatorGame>(context);
    final chapter = game.state.mainStory.chapter;
    final week = game.state.week;

    String chapterText = '';
    switch (chapter) {
      case StoryChapter.prologue:
        chapterText = 'PROLOG';
        break;
      case StoryChapter.chapter1:
        chapterText = 'BÖLÜM I: MİRAS';
        break;
      case StoryChapter.chapter2:
        chapterText = 'BÖLÜM II: YÜKSELİŞ';
        break;
      case StoryChapter.chapter3:
        chapterText = 'BÖLÜM III: GÖLGELER';
        break;
      case StoryChapter.chapter4:
        chapterText = 'BÖLÜM IV: FIRTINA';
        break;
      case StoryChapter.finale:
        chapterText = 'FİNAL: SON PERDE';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chapter info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                chapterText,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Hafta $week',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: typeColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Event type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: typeColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              _getEventTypeText(eventType),
              style: TextStyle(
                color: typeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeText(String type) {
    switch (type) {
      case 'critical':
        return 'KRİTİK KARAR';
      case 'threat':
        return 'TEHDİT';
      case 'family':
        return 'AİLE';
      case 'opportunity':
        return 'FIRSAT';
      case 'story':
        return 'HİKAYE';
      case 'chapter_end':
        return 'BÖLÜM SONU';
      case 'finale':
        return 'FİNAL';
      case 'challenge':
        return 'MEYDAN OKUMA';
      case 'crisis':
        return 'KRİZ';
      case 'gladiator_event':
        return 'GLADYATÖR';
      default:
        return type.toUpperCase();
    }
  }

  Widget _buildSceneBox(String scene) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              scene,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueView() {
    final dialogues = _getDialogues();

    if (dialogues.isEmpty) {
      // No dialogues, show choices directly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showChoices = true;
        });
      });
      return const SizedBox();
    }

    final currentDialogue = dialogues[_currentDialogueIndex];
    final speaker = currentDialogue['speaker'] as String? ?? 'narrator';
    final text = currentDialogue['text'] as String? ?? '';

    return GestureDetector(
      onTap: _nextDialogue,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GameConstants.primaryDark.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getSpeakerColor(speaker).withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getSpeakerColor(speaker).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Speaker header - Mount&Blade tarzı resim veya ikon
                        Row(
                          children: [
                            _getSpeakerImage(speaker) != null
                                ? Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: GameConstants.bronze,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        _getSpeakerImage(speaker)!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: GameConstants.primaryBrown,
                                          child: Icon(
                                            _getSpeakerIcon(speaker),
                                            color: GameConstants.bronze,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getSpeakerColor(speaker).withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getSpeakerIcon(speaker),
                                      color: _getSpeakerColor(speaker),
                                      size: 24,
                                    ),
                                  ),
                            const SizedBox(width: 12),
                            Text(
                              _getSpeakerName(speaker),
                              style: TextStyle(
                                color: _getSpeakerColor(speaker),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dialogue text
                        Text(
                          text,
                          style: TextStyle(
                            color: speaker == 'narrator' ? Colors.white70 : Colors.white,
                            fontSize: 16,
                            height: 1.5,
                            fontStyle: speaker == 'narrator' ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < dialogues.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= _currentDialogueIndex
                            ? GameConstants.gold
                            : Colors.white24,
                      ),
                    ),
                ],
              ),
            ),
            // Tap to continue hint
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Devam etmek için dokun',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesView() {
    final choices = _getChoices();
    final game = Provider.of<GladiatorGame>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Kararını ver',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          ...choices.map((choice) {
            final choiceText = choice['text'] as String? ?? '';
            final effects = choice['effects'] as Map<String, dynamic>? ?? {};
            final requiresPath = choice['requires_path'] as String?;

            // Check if this choice is available based on path
            bool isAvailable = true;
            if (requiresPath != null) {
              if (requiresPath == 'vengeance' && game.state.mainStory.path != StoryPath.vengeance) {
                isAvailable = false;
              }
              if (requiresPath == 'loyalty' && game.state.mainStory.path != StoryPath.loyalty) {
                isAvailable = false;
              }
            }

            // Check gold requirement
            if (choice['requires'] != null) {
              final requires = choice['requires'] as Map<String, dynamic>;
              if (requires['min_gold'] != null) {
                if (game.state.gold < (requires['min_gold'] as int)) {
                  isAvailable = false;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChoiceButton(choice, choiceText, effects, isAvailable),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(
    Map<String, dynamic> choice,
    String text,
    Map<String, dynamic> effects,
    bool isAvailable,
  ) {
    final pathChoice = choice['path'] as String?;
    // Mount&Blade tarzı tutarlı renkler - path seçimleri hariç hep bronz
    Color buttonColor = GameConstants.bronze;

    if (pathChoice == 'vengeance') {
      buttonColor = GameConstants.bloodRed; // İntikam yolu için kan kırmızısı
    } else if (pathChoice == 'loyalty') {
      buttonColor = GameConstants.gold; // Sadakat yolu için altın
    }

    return GestureDetector(
      onTap: isAvailable ? () => _selectChoice(choice) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAvailable
              ? buttonColor.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? buttonColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Path badge if applicable
            if (pathChoice != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pathChoice == 'vengeance' ? 'İNTİKAM YOLU' : 'SADAKAT YOLU',
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Choice text
            Text(
              text,
              style: TextStyle(
                color: isAvailable ? Colors.white : Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Effects preview
            if (effects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _buildEffectChips(effects, isAvailable),
              ),
            ],
            // Unavailable reason
            if (!isAvailable)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Gereksinimler karşılanmıyor',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEffectChips(Map<String, dynamic> effects, bool isAvailable) {
    final chips = <Widget>[];

    if (effects['gold'] != null) {
      final gold = effects['gold'] as int;
      chips.add(_buildEffectChip(
        gold > 0 ? '+$gold' : '$gold',
        Icons.monetization_on,
        gold > 0 ? Colors.amber : Colors.red,
        isAvailable,
      ));
    }

    if (effects['caesar_relation'] != null) {
      final rel = effects['caesar_relation'] as int;
      chips.add(_buildEffectChip(
        rel > 0 ? '+$rel Sezar' : '$rel Sezar',
        Icons.account_balance,
        rel > 0 ? Colors.blue : Colors.red,
        isAvailable,
      ));
    }

    if (effects['security'] != null) {
      final sec = effects['security'] as int;
      chips.add(_buildEffectChip(
        sec > 0 ? '+$sec Güvenlik' : '$sec Güvenlik',
        Icons.shield,
        sec > 0 ? Colors.green : Colors.orange,
        isAvailable,
      ));
    }

    if (effects['conspiracy_heat'] != null) {
      final heat = effects['conspiracy_heat'] as int;
      chips.add(_buildEffectChip(
        heat > 0 ? '+$heat Isı' : '$heat Isı',
        Icons.whatshot,
        heat > 0 ? Colors.orange : Colors.blue,
        isAvailable,
      ));
    }

    if (effects['reputation'] != null) {
      final rep = effects['reputation'] as int;
      chips.add(_buildEffectChip(
        rep > 0 ? '+$rep İtibar' : '$rep İtibar',
        Icons.star,
        rep > 0 ? Colors.amber : Colors.red,
        isAvailable,
      ));
    }

    if (effects['wife_morale'] != null) {
      final morale = effects['wife_morale'] as int;
      chips.add(_buildEffectChip(
        morale > 0 ? '+$morale Eş' : '$morale Eş',
        Icons.favorite,
        morale > 0 ? Colors.pink : Colors.red,
        isAvailable,
      ));
    }

    if (effects['family_loyalty'] != null) {
      final loyalty = effects['family_loyalty'] as int;
      chips.add(_buildEffectChip(
        loyalty > 0 ? '+$loyalty Aile' : '$loyalty Aile',
        Icons.family_restroom,
        loyalty > 0 ? Colors.green : Colors.red,
        isAvailable,
      ));
    }

    if (effects['add_ally'] != null) {
      chips.add(_buildEffectChip(
        '+Müttefik',
        Icons.handshake,
        Colors.green,
        isAvailable,
      ));
    }

    if (effects['add_enemy'] != null) {
      chips.add(_buildEffectChip(
        '+Düşman',
        Icons.dangerous,
        Colors.red,
        isAvailable,
      ));
    }

    return chips;
  }

  Widget _buildEffectChip(String text, IconData icon, Color color, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isAvailable ? color : Colors.grey).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isAvailable ? color : Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isAvailable ? color : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GameConstants.primaryDark.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GameConstants.gold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Path chosen indicator
                  if (_pathChosen != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _pathChosen == 'vengeance'
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.blue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _pathChosen == 'vengeance' ? Colors.red : Colors.blue,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _pathChosen == 'vengeance' ? Icons.whatshot : Icons.shield,
                            color: _pathChosen == 'vengeance' ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _pathChosen == 'vengeance'
                                ? 'İNTİKAM YOLUNU SEÇTİN'
                                : 'SADAKAT YOLUNU SEÇTİN',
                            style: TextStyle(
                              color: _pathChosen == 'vengeance' ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Result text
                  Text(
                    _resultText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Continue button
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'DEVAM ET',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

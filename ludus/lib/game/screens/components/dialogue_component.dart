import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';

/// Diyalog secenegi modeli
class DialogueOption {
  final String text;
  final int morale;
  final VoidCallback? onSelect;

  const DialogueOption({
    required this.text,
    this.morale = 0,
    this.onSelect,
  });
}

/// Diyalog componenti - Roma temasina uygun
class DialogueComponent extends StatefulWidget {
  final String speakerName;
  final String? speakerTitle;
  final String? speakerImage;
  final String dialogueText;
  final List<DialogueOption> options;
  final Color? accentColor;
  final Function(int morale)? onOptionSelected;

  const DialogueComponent({
    super.key,
    required this.speakerName,
    this.speakerTitle,
    this.speakerImage,
    required this.dialogueText,
    required this.options,
    this.accentColor,
    this.onOptionSelected,
  });

  @override
  State<DialogueComponent> createState() => _DialogueComponentState();
}

class _DialogueComponentState extends State<DialogueComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int _displayedChars = 0;
  bool _textComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _animateText();
  }

  void _animateText() async {
    for (int i = 0; i <= widget.dialogueText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() => _displayedChars = i);
      }
    }
    if (mounted) {
      setState(() => _textComplete = true);
    }
  }

  void _skipTextAnimation() {
    setState(() {
      _displayedChars = widget.dialogueText.length;
      _textComplete = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? GameConstants.gold;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameConstants.primaryBrown,
              GameConstants.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withAlpha(180),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(200),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: accentColor.withAlpha(30),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ust kisim - Karakter ve diyalog
            _buildDialogueSection(accentColor),

            // Alt kisim - Secenekler
            if (_textComplete) _buildOptionsSection(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogueSection(Color accentColor) {
    return GestureDetector(
      onTap: _textComplete ? null : _skipTextAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Karakter portresi ve isim - ust kisim
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buyuk portre
                _buildPortrait(accentColor),

                const SizedBox(width: 14),

                // Isim ve unvan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Isim
                      Text(
                        widget.speakerName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (widget.speakerTitle != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withAlpha(60),
                            ),
                          ),
                          child: Text(
                            widget.speakerTitle!,
                            style: TextStyle(
                              fontSize: 11,
                              color: GameConstants.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Diyalog metni
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GameConstants.cardBorder.withAlpha(100),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dialogueText.substring(0, _displayedChars),
                    style: TextStyle(
                      fontSize: 14,
                      color: GameConstants.textLight,
                      height: 1.5,
                    ),
                  ),
                  if (!_textComplete) ...[
                    const SizedBox(height: 6),
                    _buildTypingIndicator(accentColor),
                  ],
                ],
              ),
            ),

            if (!_textComplete) ...[
              const SizedBox(height: 10),
              Text(
                'Devam etmek icin dokun...',
                style: TextStyle(
                  fontSize: 10,
                  color: GameConstants.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(Color accentColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(150 + (i * 30)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildPortrait(Color accentColor) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(60),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: widget.speakerImage != null
            ? Image.asset(
                widget.speakerImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultPortrait(accentColor),
              )
            : _buildDefaultPortrait(accentColor),
      ),
    );
  }

  Widget _buildDefaultPortrait(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameConstants.secondaryBrown,
            GameConstants.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 45,
          color: accentColor.withAlpha(180),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayirici cizgi
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  accentColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Secenekler
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionButton(option, index, accentColor);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionButton(DialogueOption option, int index, Color accentColor) {
    final isDangerous = option.morale < 0;
    final optionColor = isDangerous ? GameConstants.danger : accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onOptionSelected != null) {
              widget.onOptionSelected!(option.morale);
            }
            option.onSelect?.call();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDangerous
                      ? GameConstants.danger.withAlpha(40)
                      : GameConstants.secondaryBrown.withAlpha(150),
                  isDangerous
                      ? GameConstants.danger.withAlpha(20)
                      : GameConstants.primaryBrown.withAlpha(150),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDangerous
                    ? GameConstants.danger.withAlpha(150)
                    : accentColor.withAlpha(100),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Numara
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: optionColor.withAlpha(60),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: optionColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: optionColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Secenek metni
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDangerous
                          ? GameConstants.danger
                          : GameConstants.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Tehlike ikonu
                if (isDangerous)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: GameConstants.danger,
                    size: 20,
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: optionColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-fight dialogue helper
class PreFightDialogueHelper {
  static List<Map<String, dynamic>>? _cachedDialogues;
  static Map<String, dynamic>? _cachedRiggedOption;
  static final Random _random = Random();

  static Future<void> loadDialogues() async {
    if (_cachedDialogues != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/pre_fight_dialogues.json');
      final data = json.decode(jsonString);
      _cachedDialogues = List<Map<String, dynamic>>.from(data['dialogues']);
      _cachedRiggedOption = data['rigged_option'];
    } catch (e) {
      _cachedDialogues = [];
    }
  }

  static Map<String, dynamic> getRandomDialogue() {
    if (_cachedDialogues == null || _cachedDialogues!.isEmpty) {
      return {
        'text': 'Efendim, savasa hazir miyim?',
        'options': [
          {'text': 'Evet, git ve zafer kazan!', 'morale': 2},
          {'text': 'Dikkatli ol.', 'morale': 1},
          {'text': 'Git.', 'morale': 0},
        ]
      };
    }
    return _cachedDialogues![_random.nextInt(_cachedDialogues!.length)];
  }

  static Map<String, dynamic>? getRiggedOption() => _cachedRiggedOption;
}

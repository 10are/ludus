import 'package:flutter/material.dart';
import '../../constants.dart';

/// Mount&Blade tarzı tutarlı Roma temalı diyalog kutusu
/// Tüm diyalog ekranlarında kullanılacak standart bileşen
class RomanDialogueBox extends StatelessWidget {
  final String? speakerName;
  final String? speakerImage;
  final String dialogueText;
  final List<DialogueChoice>? choices;
  final VoidCallback? onTapContinue;
  final bool showContinuePrompt;
  final String? progressText; // "1/5" gibi
  final Widget? customFooter;

  const RomanDialogueBox({
    super.key,
    this.speakerName,
    this.speakerImage,
    required this.dialogueText,
    this.choices,
    this.onTapContinue,
    this.showContinuePrompt = false,
    this.progressText,
    this.customFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GameConstants.bronze,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konuşmacı başlığı
          if (speakerName != null) _buildSpeakerHeader(),

          // Ana diyalog içeriği
          _buildDialogueContent(context),

          // Seçenekler veya devam butonu
          if (choices != null && choices!.isNotEmpty)
            _buildChoices(context)
          else if (showContinuePrompt)
            _buildContinuePrompt()
          else if (customFooter != null)
            customFooter!,
        ],
      ),
    );
  }

  Widget _buildSpeakerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameConstants.primaryBrown.withAlpha(150),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        border: Border(
          bottom: BorderSide(
            color: GameConstants.bronze.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Konuşmacı portresi (küçük)
          if (speakerImage != null)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
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
                  speakerImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: GameConstants.primaryBrown,
                    child: Icon(
                      Icons.person,
                      color: GameConstants.bronze,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

          // Konuşmacı adı
          Expanded(
            child: Text(
              speakerName!,
              style: TextStyle(
                color: GameConstants.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // İlerleme göstergesi
          if (progressText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                progressText!,
                style: TextStyle(
                  color: GameConstants.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDialogueContent(BuildContext context) {
    return GestureDetector(
      onTap: onTapContinue,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: SingleChildScrollView(
          child: Text(
            dialogueText,
            style: TextStyle(
              color: GameConstants.textLight,
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoices(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Ayırıcı çizgi
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  GameConstants.bronze.withAlpha(100),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Seçenekler
          ...choices!.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildChoiceButton(entry.key, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(int index, DialogueChoice choice) {
    final isDisabled = !choice.enabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : choice.onSelect,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.black.withAlpha(100)
                : GameConstants.primaryBrown.withAlpha(180),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDisabled
                  ? GameConstants.textMuted.withAlpha(50)
                  : GameConstants.bronze.withAlpha(150),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Numara badge
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? Colors.black.withAlpha(100)
                      : GameConstants.bronze.withAlpha(60),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDisabled
                        ? GameConstants.textMuted.withAlpha(50)
                        : GameConstants.bronze,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDisabled
                          ? GameConstants.textMuted
                          : GameConstants.bronze,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Seçenek metni
              Expanded(
                child: Text(
                  choice.text,
                  style: TextStyle(
                    color: isDisabled
                        ? GameConstants.textMuted
                        : GameConstants.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Kilit ikonu (devre dışı ise)
              if (isDisabled)
                Icon(
                  Icons.lock,
                  color: GameConstants.textMuted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinuePrompt() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            color: GameConstants.bronze.withAlpha(150),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Devam etmek için dokunun',
            style: TextStyle(
              color: GameConstants.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Diyalog seçeneği modeli
class DialogueChoice {
  final String text;
  final VoidCallback? onSelect;
  final bool enabled;

  const DialogueChoice({
    required this.text,
    this.onSelect,
    this.enabled = true,
  });
}

/// Tam ekran diyalog layout'u - karakter portresi + diyalog kutusu
class RomanDialogueScreen extends StatelessWidget {
  final String? backgroundImage;
  final String? speakerName;
  final String? speakerImage;
  final String dialogueText;
  final List<DialogueChoice>? choices;
  final VoidCallback? onTapContinue;
  final bool showContinuePrompt;
  final String? progressText;
  final Widget? topRightWidget;
  final Widget? topLeftWidget;

  const RomanDialogueScreen({
    super.key,
    this.backgroundImage,
    this.speakerName,
    this.speakerImage,
    required this.dialogueText,
    this.choices,
    this.onTapContinue,
    this.showContinuePrompt = false,
    this.progressText,
    this.topRightWidget,
    this.topLeftWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.primaryDark,
      body: SafeArea(
        child: GestureDetector(
          onTap: (choices == null || choices!.isEmpty) ? onTapContinue : null,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Arka plan
              Positioned.fill(
                child: Image.asset(
                  backgroundImage ?? 'assets/unnamed.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: GameConstants.primaryDark,
                  ),
                ),
              ),

              // Karartma gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(120),
                        Colors.black.withAlpha(200),
                      ],
                    ),
                  ),
                ),
              ),

              // Sol üst widget (geri butonu vb.)
              if (topLeftWidget != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: topLeftWidget!,
                ),

              // Sağ üst widget (hafta bilgisi vb.)
              if (topRightWidget != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: topRightWidget!,
                ),

              // Ana içerik
              Column(
                children: [
                  const SizedBox(height: 60),

                  // Karakter portresi (büyük)
                  if (speakerImage != null) _buildLargePortrait(),

                  const SizedBox(height: 20),

                  // Diyalog kutusu
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: RomanDialogueBox(
                        speakerName: speakerName,
                        dialogueText: dialogueText,
                        choices: choices,
                        onTapContinue: onTapContinue,
                        showContinuePrompt: showContinuePrompt,
                        progressText: progressText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargePortrait() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 160,
        height: 160,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GameConstants.bronze,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: GameConstants.bronze.withAlpha(50),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(150),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                speakerImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: GameConstants.primaryBrown,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: GameConstants.bronze.withAlpha(150),
                  ),
                ),
              ),
              // Alt gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(100),
                      ],
                    ),
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

/// Geri butonu widget'ı (tutarlı stil için)
class RomanBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const RomanBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
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
          size: 20,
        ),
      ),
    );
  }
}

/// Hafta bilgisi badge'i (tutarlı stil için)
class RomanWeekBadge extends StatelessWidget {
  final int week;
  final String? customText;

  const RomanWeekBadge({
    super.key,
    required this.week,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameConstants.gold,
          width: 1,
        ),
      ),
      child: Text(
        customText ?? 'Hafta $week',
        style: TextStyle(
          color: GameConstants.gold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

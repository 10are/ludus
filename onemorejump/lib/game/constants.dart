import 'dart:ui';

class GameConstants {
  // Başlangıç değerleri
  static const int startingGold = 1000;
  static const int startingGladiators = 3;

  // Gladyatör stat limitleri
  static const int maxStat = 100;
  static const int minStat = 1;

  // Eğitim
  static const int trainingCostBase = 50;
  static const int trainingStatGain = 5;

  // Sağlık
  static const int doctorCost = 100;
  static const int doctorHealAmount = 30;

  // Dövüş ödülleri
  static const int undergroundFightReward = 150;
  static const int smallArenaReward = 400;
  static const int bigArenaReward = 1200;

  // === ROMA RENK PALETİ ===

  // Ana arka plan renkleri - Sıcak, toprak tonları
  static const Color primaryDark = Color(0xFF1A1209); // Çok koyu kahve
  static const Color primaryBrown = Color(0xFF2A1D12); // Koyu kahverengi
  static const Color secondaryBrown = Color(0xFF3D2A1C); // Orta kahverengi

  // Vurgu renkleri - Roma altın/turuncu
  static const Color gold = Color(0xFFD4A853); // Roma altını
  static const Color bronze = Color(0xFFCD7F32); // Bronz
  static const Color copper = Color(0xFFB87333); // Bakır
  static const Color warmOrange = Color(0xFFBF5B04); // Sıcak turuncu
  static const Color bloodRed = Color(0xFF6B1010); // Kan kırmızısı

  // Nötr renkler
  static const Color sand = Color(0xFFD9C4A9); // Kum rengi
  static const Color parchment = Color(0xFFF0E2D0); // Parşömen
  static const Color stone = Color(0xFF7A7068); // Taş grisi

  // Metin renkleri
  static const Color textLight = Color(0xFFF0E2D0); // Açık metin
  static const Color textMuted = Color(0xFF9A8B7A); // Soluk metin

  // Stat renkleri
  static const Color healthColor = Color(0xFFAA3333); // Sağlık - kırmızı
  static const Color strengthColor = Color(0xFFCC6600); // Güç - turuncu
  static const Color intelligenceColor = Color(0xFF4A6B8A); // Zeka - mavi
  static const Color staminaColor = Color(0xFF5C7A4A); // Kondisyon - yeşil

  // UI elementleri
  static const Color cardBg = Color(0xFF2A1D12);
  static const Color cardBorder = Color(0xFF4A3528);
  static const Color buttonPrimary = Color(0xFF6B1010);
  static const Color buttonSecondary = Color(0xFF3D2A1C);

  // Durum renkleri
  static const Color success = Color(0xFF5C7A4A);
  static const Color danger = Color(0xFF8B2020);
  static const Color warning = Color(0xFFBF5B04);
}

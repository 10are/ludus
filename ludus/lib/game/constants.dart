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

  // === PROGRESİF ÖLÇEKLEME SİSTEMİ (50 Hafta) ===

  // Final hafta
  static const int finalWeek = 50;

  // Ölçeklenmiş ödül hesaplama (hafta bazlı)
  static int getScaledReward(int baseReward, int week) {
    // Her 10 hafta için %20 artış
    final multiplier = 1.0 + (week ~/ 10) * 0.2;
    return (baseReward * multiplier).round();
  }

  // Ölçeklenmiş düşman gücü hesaplama
  static int getScaledEnemyPower(int basePower, int week) {
    // Her hafta +1.5 güç artışı
    return basePower + ((week - 1) * 1.5).round();
  }

  // Ölçeklenmiş zorluk hesaplama (1-6 arası)
  static int getScaledDifficulty(int baseDifficulty, int week) {
    // Her 10 hafta için +1 zorluk
    final bonus = week ~/ 10;
    return (baseDifficulty + bonus).clamp(1, 6);
  }

  // Ölçeklenmiş fiyat hesaplama (köle/personel için)
  static int getScaledPrice(int basePrice, int week) {
    // Her 10 hafta için %25 artış
    final multiplier = 1.0 + (week ~/ 10) * 0.25;
    return (basePrice * multiplier).round();
  }

  // Ölçeklenmiş stat hesaplama (köleler için)
  static int getScaledStat(int baseStat, int week, {int maxBonus = 30}) {
    // Her 5 hafta için +5 stat, maksimum +maxBonus
    final bonus = ((week ~/ 5) * 5).clamp(0, maxBonus);
    return (baseStat + bonus).clamp(minStat, maxStat);
  }

  // Hafta bazlı köle sayısı (markette)
  static int getSlavesPerWeek(int week) {
    if (week <= 10) return 3; // İlk 10 hafta: 3 köle
    if (week <= 25) return 4; // 11-25: 4 köle
    if (week <= 40) return 5; // 26-40: 5 köle
    return 6; // 41-50: 6 köle
  }

  // Hafta bazlı personel sayısı
  static int getStaffPerWeek(int week) {
    if (week <= 10) return 1;
    if (week <= 25) return 2;
    return 3;
  }

  // Hafta bazlı yeraltı dövüş sayısı
  static int getUndergroundFightsPerWeek(int week) {
    if (week <= 10) return 2;
    if (week <= 25) return 3;
    if (week <= 40) return 4;
    return 5;
  }

  // Hafta bazlı küçük arena dövüş sayısı
  static int getSmallArenaFightsPerWeek(int week) {
    if (week < 5) return 0; // İlk 5 hafta kilitli
    if (week <= 15) return 1;
    if (week <= 30) return 2;
    if (week <= 45) return 3;
    return 4;
  }

  // Hafta bazlı büyük arena dövüş sayısı
  static int getBigArenaFightsPerWeek(int week) {
    if (week < 15) return 0; // İlk 15 hafta kilitli
    if (week <= 30) return 1;
    if (week <= 45) return 2;
    return 3;
  }

  // Hafta bazlı gerekli itibar
  static int getRequiredReputation(int week, String fightType) {
    switch (fightType) {
      case 'underground':
        return 0; // Her zaman erişilebilir
      case 'smallArena':
        return 10 + (week ~/ 5) * 10; // 10, 20, 30...
      case 'bigArena':
        return 50 + (week ~/ 5) * 20; // 50, 70, 90...
      default:
        return 0;
    }
  }
}

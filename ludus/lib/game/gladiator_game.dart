import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_state.dart';
import 'models/gladiator.dart';
import 'constants.dart';

class GladiatorGame extends ChangeNotifier {
  GameState state = GameState();
  final Random _random = Random();

  // State yenile (UI güncellemesi için)
  void refreshState() {
    notifyListeners();
  }

  // Oyunu başlat
  void startGame() {
    state.reset();
    notifyListeners();
  }

  // === İNTERAKTİF HİKAYE SİSTEMİ ===

  // Cache for loaded stories
  List<Map<String, dynamic>>? _cachedStories;

  // JSON'dan story'leri yükle (async)
  Future<List<Map<String, dynamic>>> loadStories() async {
    if (_cachedStories != null) return _cachedStories!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/weekly_stories.json');
      final data = json.decode(jsonString);
      _cachedStories = List<Map<String, dynamic>>.from(data['weekly_stories']);
      return _cachedStories!;
    } catch (e) {
      debugPrint('Story yükleme hatası: $e');
      return [];
    }
  }

  // Mevcut hafta için story var mı kontrol et (JSON'daki week alanına göre)
  Future<Map<String, dynamic>?> getCurrentWeekStory() async {
    final stories = await loadStories();

    for (final story in stories) {
      final storyWeek = story['week'] as int;
      final storyId = story['id'] as String;

      // Bu haftanın story'si mi ve henüz görülmemiş mi?
      if (storyWeek == state.week && !state.seenStories.contains(storyId)) {
        return story;
      }
    }
    return null;
  }

  // Story'nin diyaloglarını al (koşullara göre)
  List<Map<String, dynamic>> getStoryDialogues(Map<String, dynamic> story) {
    // Eğer conditions varsa, oyuncunun seçimlerine göre doğru diyalogları getir
    if (story.containsKey('conditions') && story['conditions'] != null) {
      final conditions = story['conditions'] as List;

      for (final condition in conditions) {
        final variable = condition['variable'] as String;
        final requiredValue = condition['value'] as bool;

        // Oyuncunun bu değişken için seçimi var mı?
        if (state.storyChoices.containsKey(variable)) {
          final playerChoice = state.storyChoices[variable];
          if (playerChoice == requiredValue) {
            return List<Map<String, dynamic>>.from(condition['dialogues']);
          }
        }
      }

      // Eğer eşleşen koşul yoksa, ilk koşulun diyaloglarını döndür
      if (conditions.isNotEmpty) {
        return List<Map<String, dynamic>>.from(conditions[0]['dialogues']);
      }
    }

    // Normal diyaloglar (koşulsuz)
    if (story.containsKey('dialogues') && story['dialogues'] != null) {
      return List<Map<String, dynamic>>.from(story['dialogues']);
    }

    return [];
  }

  // Story görüldü olarak işaretle
  void markStoryAsSeen(String storyId) {
    state.seenStories.add(storyId);
    notifyListeners();
  }

  // Oyuncunun seçimini kaydet
  void setStoryChoice(String variable, bool value) {
    state.storyChoices[variable] = value;
    notifyListeners();
  }

  // Belirli bir story değişkeninin değerini al
  bool? getStoryChoice(String variable) {
    return state.storyChoices[variable];
  }

  // === HAFTALIK EVENT SİSTEMİ ===

  // Cache for loaded events
  List<Map<String, dynamic>>? _cachedEvents;

  // JSON'dan event'leri yükle
  Future<List<Map<String, dynamic>>> loadEvents() async {
    if (_cachedEvents != null) return _cachedEvents!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/weekly_events.json');
      final data = json.decode(jsonString);
      _cachedEvents = List<Map<String, dynamic>>.from(data['weekly_events']);
      return _cachedEvents!;
    } catch (e) {
      debugPrint('Event yükleme hatası: $e');
      return [];
    }
  }

  // Mevcut hafta için uygun event getir (rastgele seçim)
  Future<Map<String, dynamic>?> getRandomWeeklyEvent() async {
    final events = await loadEvents();
    final eligibleEvents = <Map<String, dynamic>>[];

    for (final event in events) {
      if (_isEventEligible(event)) {
        eligibleEvents.add(event);
      }
    }

    if (eligibleEvents.isEmpty) return null;

    // Şansa göre seçim yap
    final shuffled = List<Map<String, dynamic>>.from(eligibleEvents)..shuffle(_random);

    for (final event in shuffled) {
      final chance = event['chance'] as int? ?? 100;
      if (_random.nextInt(100) < chance) {
        return event;
      }
    }

    // Hiçbiri şansı tutmadıysa ilk uygun eventi döndür
    return eligibleEvents.isNotEmpty ? eligibleEvents[_random.nextInt(eligibleEvents.length)] : null;
  }

  // Event uygun mu kontrol et
  bool _isEventEligible(Map<String, dynamic> event) {
    final eventId = event['id'] as String;

    // Zaten görülmüş mü?
    if (state.seenEvents.contains(eventId)) return false;

    // Hafta aralığı kontrolü
    final weekMin = event['week_min'] as int? ?? 1;
    final weekMax = event['week_max'] as int? ?? 999;
    if (state.week < weekMin || state.week > weekMax) return false;

    // Eş gereksinimi
    if (event['requires_wife'] == true && !state.hasWife) return false;

    // Çocuk yok gereksinimi
    if (event['requires_no_child'] == true && state.hasChild) return false;

    // Minimum eş morali
    if (event['min_wife_morale'] != null) {
      if (state.wifeMorale < (event['min_wife_morale'] as int)) return false;
    }

    // Gladyatör gereksinimi
    if (event['requires_gladiator'] == true && state.gladiators.isEmpty) return false;

    // Minimum gladyatör galibiyeti
    if (event['min_gladiator_wins'] != null) {
      final minWins = event['min_gladiator_wins'] as int;
      final hasEligibleGladiator = state.gladiators.any((g) => g.wins >= minWins);
      if (!hasEligibleGladiator) return false;
    }

    return true;
  }

  // Event için konuşmacı gladyatörü seç
  Gladiator? getEventGladiator(Map<String, dynamic> event) {
    if (event['speaker_from_gladiator'] != true) return null;
    if (state.gladiators.isEmpty) return null;

    // Minimum galibiyet gereksinimi varsa ona göre seç
    if (event['min_gladiator_wins'] != null) {
      final minWins = event['min_gladiator_wins'] as int;
      final eligible = state.gladiators.where((g) => g.wins >= minWins).toList();
      if (eligible.isNotEmpty) {
        return eligible[_random.nextInt(eligible.length)];
      }
    }

    // Rastgele bir gladyatör seç
    return state.gladiators[_random.nextInt(state.gladiators.length)];
  }

  // Event seçimi sonucunu uygula
  EventResult applyEventChoice(Map<String, dynamic> event, Map<String, dynamic> option, Gladiator? targetGladiator) {
    final effects = option['effects'] as Map<String, dynamic>? ?? {};
    final resultMessage = option['result_message'] as String? ?? 'Seçim yapıldı.';

    // Altın etkisi
    if (effects['gold'] != null) {
      state.modifyGold(effects['gold'] as int);
    }

    // Eş morali etkisi
    if (effects['wife_morale'] != null) {
      state.modifyWifeMorale(effects['wife_morale'] as int);
    }

    // İtibar etkisi
    if (effects['reputation'] != null) {
      state.modifyReputation(effects['reputation'] as int);
    }

    // Gladyatör moral etkisi
    if (effects['gladiator_morale'] != null && targetGladiator != null) {
      targetGladiator.changeMorale(effects['gladiator_morale'] as int);
    }

    // Gladyatör sağlık etkisi
    if (effects['gladiator_health'] != null && targetGladiator != null) {
      targetGladiator.takeDamage(-(effects['gladiator_health'] as int));
    }

    // Gladyatörü kaldır (özgürlük)
    if (effects['remove_gladiator'] == true && targetGladiator != null) {
      state.gladiators.removeWhere((g) => g.id == targetGladiator.id);
    }

    // Çocuk tetikle
    Child? newChild;
    if (effects['trigger_child'] == true) {
      // Rastgele isim ve cinsiyet
      final isMale = _random.nextBool();
      final names = isMale
          ? ['Marcus', 'Lucius', 'Gaius', 'Titus', 'Quintus', 'Decimus']
          : ['Julia', 'Livia', 'Cornelia', 'Aurelia', 'Claudia', 'Octavia'];
      final name = names[_random.nextInt(names.length)];
      newChild = state.addChild(name, isMale);
    }

    // Eventi görüldü olarak işaretle
    markEventAsSeen(event['id'] as String);

    notifyListeners();

    return EventResult(
      message: resultMessage,
      child: newChild,
    );
  }

  // Event görüldü olarak işaretle
  void markEventAsSeen(String eventId) {
    state.seenEvents.add(eventId);
  }

  // Kayıttan yükle
  void loadFromState(GameState loadedState) {
    state = loadedState;
    notifyListeners();
  }

  // Ana menüye dön
  void returnToMenu() {
    state.phase = GamePhase.menu;
    notifyListeners();
  }

  // === EĞİTİM SİSTEMİ ===
  bool trainGladiator(String gladiatorId, String stat) {
    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);

    if (!gladiator.canTrain) return false;
    if (state.gold < GameConstants.trainingCostBase) return false;

    state.modifyGold(-GameConstants.trainingCostBase);

    int gainAmount = GameConstants.trainingStatGain;
    // Eğitmen varsa bonus
    final hasTrainer = state.staff.any((s) => s.role == StaffRole.trainer);
    if (hasTrainer) gainAmount += 2;

    // Beslenme bonusu (yemek +2, su +1)
    gainAmount += gladiator.nutritionBonus;

    gladiator.trainStat(stat, gainAmount);

    notifyListeners();
    return true;
  }

  // === BESLENME SİSTEMİ ===
  bool buyFood(String gladiatorId, int price) {
    if (state.gold < price) return false;

    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);
    if (gladiator.hasFood) return false; // Zaten alınmış

    state.modifyGold(-price);
    gladiator.hasFood = true;

    notifyListeners();
    return true;
  }

  bool buyWater(String gladiatorId, int price) {
    if (state.gold < price) return false;

    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);
    if (gladiator.hasWater) return false; // Zaten alınmış

    state.modifyGold(-price);
    gladiator.hasWater = true;

    notifyListeners();
    return true;
  }

  // === DOKTOR - İYİLEŞTİRME ===
  bool healGladiator(String gladiatorId) {
    if (state.gold < GameConstants.doctorCost) return false;

    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);

    state.modifyGold(-GameConstants.doctorCost);

    int healAmount = GameConstants.doctorHealAmount;
    final hasDoctor = state.staff.any((s) => s.role == StaffRole.doctor);
    if (hasDoctor) healAmount += 15;

    gladiator.heal(healAmount);

    notifyListeners();
    return true;
  }

  // === ÖZEL İLAÇ İLE İYİLEŞTİRME ===
  bool healGladiatorWithMedicine(String gladiatorId, int price, int healAmount) {
    if (state.gold < price) return false;

    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);

    state.modifyGold(-price);

    // Doktor varsa bonus
    final hasDoctor = state.staff.any((s) => s.role == StaffRole.doctor);
    final totalHeal = hasDoctor ? healAmount + 15 : healAmount;

    gladiator.heal(totalHeal);

    notifyListeners();
    return true;
  }

  // === DÖVÜŞ SİSTEMİ ===
  FightResult fight(String gladiatorId, FightOpportunity fight) {
    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);

    if (!gladiator.canFight) {
      return FightResult(
        won: false,
        message: '${gladiator.name} dövüşemez durumda!',
        damageReceived: 0,
        reward: 0,
      );
    }

    // Dövüş simülasyonu
    final gladiatorRoll = gladiator.overallPower + _random.nextInt(30);
    final enemyRoll = fight.enemyPower + _random.nextInt(30);

    final won = gladiatorRoll > enemyRoll;
    final damage = won ? 10 + _random.nextInt(15) : 20 + _random.nextInt(25);

    gladiator.recordFight(won, damage);

    String message;
    int reward = 0;

    if (won) {
      reward = fight.reward;
      state.modifyGold(reward);
      state.reputation += fight.difficulty * 5;
      fight.isAvailable = false;
      message = '${gladiator.name} zaferle döndü! +$reward altın';
    } else {
      message = '${gladiator.name} yenildi... Hasar: $damage';
    }

    notifyListeners();

    return FightResult(
      won: won,
      message: message,
      damageReceived: damage,
      reward: reward,
    );
  }

  // === DİPLOMASİ SİSTEMİ ===
  BluffResult negotiate(String rivalId, int betAmount) {
    if (state.gold < betAmount) {
      return BluffResult(
        success: false,
        message: 'Yeterli altının yok!',
        goldChange: 0,
      );
    }

    final rival = state.rivals.firstWhere((r) => r.id == rivalId);

    // Zar at (2d6)
    final playerRoll = _random.nextInt(6) + 1 + _random.nextInt(6) + 1;
    final rivalRoll = _random.nextInt(6) + 1 + _random.nextInt(6) + 1;

    // Bonuslar
    int rivalBonus = 0;
    switch (rival.personality) {
      case 'aggressive':
        rivalBonus = 2;
        break;
      case 'cautious':
        rivalBonus = -1;
        break;
      case 'cunning':
        rivalBonus = 1;
        break;
      case 'proud':
        rivalBonus = 0;
        break;
    }

    final reputationBonus = state.reputation ~/ 50;
    final relationshipBonus = rival.relationship ~/ 20;

    final playerTotal = playerRoll + reputationBonus + relationshipBonus;
    final rivalTotal = rivalRoll + rivalBonus;

    final success = playerTotal > rivalTotal;
    int goldChange;
    String message;

    if (success) {
      goldChange = betAmount;
      state.modifyGold(betAmount);
      state.reputation += 5;
      rival.relationship += 10;
      message = 'Pazarlık başarılı! ${rival.name} ikna oldu.';
    } else {
      goldChange = -betAmount;
      state.modifyGold(-betAmount);
      rival.relationship -= 5;
      message = '${rival.name} teklifini reddetti.';
    }

    notifyListeners();

    return BluffResult(
      success: success,
      message: message,
      goldChange: goldChange,
      playerRoll: playerRoll,
      rivalRoll: rivalRoll,
    );
  }

  // === MAAŞ SİSTEMİ ===
  SalaryResult paySalaries() {
    final totalSalary = state.totalWeeklySalary;

    if (state.gold >= totalSalary) {
      // Tam maaş öde
      state.modifyGold(-totalSalary);
      for (final g in state.gladiators) {
        g.changeMorale(5);
      }
      state.advanceWeek();
      _checkForWeeklyStory();
      notifyListeners();
      return SalaryResult(
        paid: true,
        totalPaid: totalSalary,
        message: 'Maaşlar ödendi. Herkes memnun.',
        rebellionRisk: false,
      );
    } else if (state.gold >= totalSalary ~/ 2) {
      // Yarım maaş
      state.modifyGold(-state.gold);
      for (final g in state.gladiators) {
        g.changeMorale(-10);
      }
      state.advanceWeek();
      _checkForWeeklyStory();
      notifyListeners();
      return SalaryResult(
        paid: true,
        totalPaid: state.gold,
        message: 'Kısmi ödeme yapıldı. Moral düştü.',
        rebellionRisk: false,
      );
    } else {
      // Maaş ödenemedi - isyan riski
      for (final g in state.gladiators) {
        g.changeMorale(-25);
      }

      // İsyan kontrolü
      final rebellionChance = state.gladiators.where((g) => g.morale < 20).length;
      final rebellion = _random.nextInt(10) < rebellionChance;

      if (rebellion) {
        // İsyan! Bir gladyatör kaçar
        if (state.gladiators.isNotEmpty) {
          final escapee = state.gladiators.firstWhere(
            (g) => g.morale < 20,
            orElse: () => state.gladiators.first,
          );
          state.gladiators.remove(escapee);
        }
        state.advanceWeek();
        _checkForWeeklyStory();
        notifyListeners();
        return SalaryResult(
          paid: false,
          totalPaid: 0,
          message: 'İSYAN! Bir gladyatör kaçtı!',
          rebellionRisk: true,
        );
      }

      state.advanceWeek();
      _checkForWeeklyStory();
      notifyListeners();
      return SalaryResult(
        paid: false,
        totalPaid: 0,
        message: 'Maaşlar ödenmedi. İsyan tehlikesi var!',
        rebellionRisk: true,
      );
    }
  }

  // === GLADYATÖR MAAŞI AYARLA ===
  void setGladiatorSalary(String gladiatorId, int newSalary) {
    final gladiator = state.gladiators.firstWhere((g) => g.id == gladiatorId);
    gladiator.setSalary(newSalary);
    notifyListeners();
  }

  // === PERSONEL İŞE AL ===
  bool hireStaff(Staff newStaff) {
    // İşe alma ücreti (maaşın 5 katı)
    final hireCost = newStaff.salary * 5;
    if (state.gold < hireCost) return false;

    state.modifyGold(-hireCost);
    state.staff.add(newStaff);
    notifyListeners();
    return true;
  }

  // === PERSONEL İŞE AL (FİYATLI) ===
  bool hireStaffWithPrice(Staff newStaff, int price) {
    if (state.gold < price) return false;

    state.modifyGold(-price);
    state.staff.add(newStaff);
    notifyListeners();
    return true;
  }

  // === PERSONEL KOVMA ===
  void fireStaff(String staffId) {
    state.staff.removeWhere((s) => s.id == staffId);
    notifyListeners();
  }

  // === GLADYATÖR SATIN AL ===
  bool buyGladiator(Gladiator gladiator, int price) {
    if (state.gold < price) return false;

    state.modifyGold(-price);
    state.gladiators.add(gladiator);
    notifyListeners();
    return true;
  }

  // === GLADYATÖR SAT / KOV ===
  void sellGladiator(String gladiatorId, int price) {
    state.gladiators.removeWhere((g) => g.id == gladiatorId);
    state.modifyGold(price);
    notifyListeners();
  }

  // === GLADYATÖR KOV (Diğerlerinin morali düşer) ===
  void fireGladiator(String gladiatorId) {
    state.gladiators.removeWhere((g) => g.id == gladiatorId);

    // Diğer gladyatörlerin morali düşer (zar mekaniği)
    for (final g in state.gladiators) {
      final moraleLoss = 5 + _random.nextInt(10); // 5-15 arası kayıp
      g.changeMorale(-moraleLoss);
    }

    notifyListeners();
  }

  // === OYUN BİTTİ Mİ? ===
  void checkGameOver() {
    final allDead = state.gladiators.every((g) => g.health <= 0);
    final noGladiators = state.gladiators.isEmpty;

    if (allDead || noGladiators) {
      state.phase = GamePhase.gameOver;
      notifyListeners();
    }
  }

  // === ZİYAFET VER (Tüm gladyatörlerin morali artar) ===
  bool giveFeast(int price, int moraleBonus) {
    if (state.gold < price) return false;

    state.modifyGold(-price);

    for (final g in state.gladiators) {
      g.changeMorale(moraleBonus);
    }

    notifyListeners();
    return true;
  }

  // === EŞE HEDİYE VER ===
  bool giveGiftToWife(int price, int moraleBonus) {
    if (state.gold < price) return false;

    state.modifyGold(-price);
    state.modifyWifeMorale(moraleBonus);

    notifyListeners();
    return true;
  }

  // === ÇOCUK SAHİBİ OLMAYI DENE ===
  Child? tryForChild() {
    if (state.wifeMorale >= 80 && state.hasWife) {
      // Rastgele isim ve cinsiyet
      final isMale = _random.nextBool();
      final names = isMale
          ? ['Marcus', 'Lucius', 'Gaius', 'Titus', 'Quintus', 'Decimus']
          : ['Julia', 'Livia', 'Cornelia', 'Aurelia', 'Claudia', 'Octavia'];
      final name = names[_random.nextInt(names.length)];
      final child = state.addChild(name, isMale);
      if (child != null) {
        state.reputation += 50; // Varis = itibar
        notifyListeners();
      }
      return child;
    }
    return null;
  }

  // === DİYALOG İNDEKSİNİ İLERLET ===
  void advanceDialogue(int totalDialogues) {
    state.dialogueIndex = (state.dialogueIndex + 1) % totalDialogues;
    notifyListeners();
  }

  // === GÖREV SİSTEMİ ===
  void addMission(ActiveMission mission) {
    state.activeMissions.add(mission);
    notifyListeners();
  }

  void removeMission(String missionId) {
    state.activeMissions.removeWhere((m) => m.id == missionId);
    notifyListeners();
  }

  // Görev tamamla
  void completeMission(String missionId) {
    final missionIndex = state.activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex != -1) {
      final mission = state.activeMissions[missionIndex];
      mission.isCompleted = true;
      state.modifyGold(mission.rewardGold);
      state.activeMissions.removeAt(missionIndex);
      notifyListeners();
    }
  }

  // Görev başarısız
  void failMission(String missionId) {
    final missionIndex = state.activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex != -1) {
      final mission = state.activeMissions[missionIndex];
      mission.isFailed = true;
      state.modifyReputation(mission.penaltyReputation);
      state.activeMissions.removeAt(missionIndex);
      notifyListeners();
    }
  }

  // Şikeli dövüş kontrolü - gladyatör kaybederse görev tamamlanır
  ActiveMission? getFixFightMission() {
    try {
      return state.activeMissions.firstWhere(
        (m) => m.type == MissionType.fixFight && !m.isCompleted && !m.isFailed,
      );
    } catch (_) {
      return null;
    }
  }

  // Haftalık görev güncellemesi
  void updateMissionsOnWeekEnd() {
    final toRemove = <String>[];

    for (final mission in state.activeMissions) {
      if (mission.durationWeeks != null) {
        mission.remainingWeeks--;
        if (mission.remainingWeeks <= 0) {
          // Süre doldu - başarısız
          mission.isFailed = true;
          state.modifyReputation(mission.penaltyReputation);
          toRemove.add(mission.id);
        }
      }
    }

    for (final id in toRemove) {
      state.activeMissions.removeWhere((m) => m.id == id);
    }

    notifyListeners();
  }

  // Hafta geçişinde story kontrolü (artık JSON'dan hafta bazlı kontrol ediliyor)
  // Bu metod sadece bir placeholder - asıl kontrol getCurrentWeekStory() ile yapılıyor
  void _checkForWeeklyStory() {
    // Story kontrolü artık home_screen'de getCurrentWeekStory() ile yapılıyor
    // Bu metod geriye dönük uyumluluk için bırakıldı
  }

  // === ANA HİKAYE SİSTEMİ ===

  // Cache for main story data
  Map<String, dynamic>? _cachedMainStory;

  // Ana hikaye JSON'ını yükle
  Future<Map<String, dynamic>> loadMainStory() async {
    if (_cachedMainStory != null) return _cachedMainStory!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/main_story.json');
      _cachedMainStory = json.decode(jsonString);
      return _cachedMainStory!;
    } catch (e) {
      debugPrint('Ana hikaye yükleme hatası: $e');
      return {};
    }
  }

  // Mevcut hafta için ana hikaye eventi al
  Future<Map<String, dynamic>?> getCurrentMainStoryEvent() async {
    final mainStory = await loadMainStory();
    if (mainStory.isEmpty) return null;

    final week = state.week;
    final path = state.mainStory.path;
    final chapter = state.mainStory.chapter;

    // Önce bekleyen eventleri kontrol et
    final pendingEvent = _checkPendingEvents();
    if (pendingEvent != null) return pendingEvent;

    // Bölüme göre event listesini belirle
    List<Map<String, dynamic>> events = [];

    if (chapter == StoryChapter.prologue) {
      events = List<Map<String, dynamic>>.from(mainStory['prologue_events'] ?? []);
    } else if (chapter == StoryChapter.chapter1) {
      events = List<Map<String, dynamic>>.from(mainStory['chapter1_events'] ?? []);
    } else if (chapter == StoryChapter.chapter2) {
      events = List<Map<String, dynamic>>.from(mainStory['chapter2_events'] ?? []);
    } else if (chapter == StoryChapter.chapter3) {
      events = List<Map<String, dynamic>>.from(mainStory['chapter3_events'] ?? []);
    } else if (chapter == StoryChapter.chapter4) {
      events = List<Map<String, dynamic>>.from(mainStory['chapter4_events'] ?? []);
    }

    // Bu haftaya ait event bul
    for (final event in events) {
      final eventWeek = event['week'] as int?;
      final eventId = event['id'] as String;

      // Zaten görülmüş mü?
      if (state.mainStory.seenMainEvents.contains(eventId)) continue;

      // Hafta eşleşiyor mu?
      if (eventWeek != week) continue;

      // Path gereksinimi var mı?
      if (event['requires_path'] != null) {
        final requiredPath = event['requires_path'] as String;
        if (requiredPath == 'vengeance' && path != StoryPath.vengeance) continue;
        if (requiredPath == 'loyalty' && path != StoryPath.loyalty) continue;
      }

      // Diğer gereksinimleri kontrol et
      if (!_checkMainEventRequirements(event)) continue;

      return event;
    }

    // Random event şansı (%30)
    if (_random.nextInt(100) < 30) {
      return _getRandomMainEvent(mainStory);
    }

    return null;
  }

  // Bekleyen eventleri kontrol et
  Map<String, dynamic>? _checkPendingEvents() {
    for (final pending in state.mainStory.pendingEvents) {
      if (pending.triggered) continue;
      if (pending.triggerWeek <= state.week) {
        pending.triggered = true;
        // Event ID'ye göre eventi bul ve döndür
        // Bu basit implementasyon - daha sonra geliştirilecek
      }
    }
    return null;
  }

  // Random main event al
  Future<Map<String, dynamic>?> _getRandomMainEvent(Map<String, dynamic> mainStory) async {
    final randomEvents = List<Map<String, dynamic>>.from(mainStory['random_events'] ?? []);
    final eligibleEvents = <Map<String, dynamic>>[];

    for (final event in randomEvents) {
      if (_isRandomMainEventEligible(event)) {
        eligibleEvents.add(event);
      }
    }

    if (eligibleEvents.isEmpty) return null;

    // Şansa göre seçim
    eligibleEvents.shuffle(_random);
    for (final event in eligibleEvents) {
      final chance = event['chance'] as int? ?? 50;
      if (_random.nextInt(100) < chance) {
        return event;
      }
    }

    return null;
  }

  // Random event uygun mu kontrol et
  bool _isRandomMainEventEligible(Map<String, dynamic> event) {
    final eventId = event['id'] as String;

    // Zaten görülmüş mü?
    if (state.mainStory.seenMainEvents.contains(eventId)) return false;

    // Hafta aralığı
    final weekMin = event['week_min'] as int? ?? 1;
    final weekMax = event['week_max'] as int? ?? 999;
    if (state.week < weekMin || state.week > weekMax) return false;

    // Gladyatör gereksinimi
    if (event['requires_gladiator'] == true && state.gladiators.isEmpty) return false;

    return true;
  }

  // Main event gereksinimlerini kontrol et
  bool _checkMainEventRequirements(Map<String, dynamic> event) {
    // Eş gereksinimi
    if (event['requires_wife'] == true && !state.hasWife) return false;

    // Çocuk gereksinimi
    if (event['requires_child'] == true && !state.hasChild) return false;

    // Müttefik gereksinimi
    if (event['requires_ally'] != null) {
      final requiredAlly = event['requires_ally'] as String;
      if (!state.mainStory.allies.contains(requiredAlly)) return false;
    }

    // Önceki event gereksinimi
    if (event['requires_event'] != null) {
      final requiredEvent = event['requires_event'] as String;
      if (!state.mainStory.seenMainEvents.contains(requiredEvent)) return false;
    }

    return true;
  }

  // Ana hikaye seçimini uygula
  MainStoryResult applyMainStoryChoice(Map<String, dynamic> event, Map<String, dynamic> choice) {
    final eventId = event['id'] as String;
    final choiceId = choice['id'] as String;
    final effects = choice['effects'] as Map<String, dynamic>? ?? {};
    final consequence = choice['consequence'] as String? ?? '';

    // Path seçimi
    if (choice['path'] != null) {
      final pathStr = choice['path'] as String;
      if (pathStr == 'vengeance') {
        state.mainStory.path = StoryPath.vengeance;
      } else if (pathStr == 'loyalty') {
        state.mainStory.path = StoryPath.loyalty;
      }
    }

    // Sezar ilişkisi
    if (effects['caesar_relation'] != null) {
      state.mainStory.modifyCaesarRelation(effects['caesar_relation'] as int);
    }

    // Güvenlik
    if (effects['security'] != null) {
      state.mainStory.modifySecurity(effects['security'] as int);
    }

    // Komplo ısısı
    if (effects['conspiracy_heat'] != null) {
      state.mainStory.modifyConspiracyHeat(effects['conspiracy_heat'] as int);
    }

    // Aile sadakati
    if (effects['family_loyalty'] != null) {
      state.mainStory.modifyFamilyLoyalty(effects['family_loyalty'] as int);
    }

    // Eş morali
    if (effects['wife_morale'] != null) {
      state.modifyWifeMorale(effects['wife_morale'] as int);
    }

    // Altın
    if (effects['gold'] != null) {
      state.modifyGold(effects['gold'] as int);
    }

    // İtibar
    if (effects['reputation'] != null) {
      state.modifyReputation(effects['reputation'] as int);
    }

    // Müttefik ekle
    if (effects['add_ally'] != null) {
      state.mainStory.allies.add(effects['add_ally'] as String);
    }

    // Müttefik çıkar
    if (effects['remove_ally'] != null) {
      state.mainStory.allies.remove(effects['remove_ally'] as String);
    }

    // Düşman ekle
    if (effects['add_enemy'] != null) {
      state.mainStory.enemies.add(effects['add_enemy'] as String);
    }

    // Gladyatör morali
    if (effects['gladiator_morale'] != null && state.gladiators.isNotEmpty) {
      for (final g in state.gladiators) {
        g.changeMorale(effects['gladiator_morale'] as int);
      }
    }

    // Gladyatör hasar
    if (effects['gladiator_damage'] != null && state.gladiators.isNotEmpty) {
      for (final g in state.gladiators) {
        g.takeDamage(effects['gladiator_damage'] as int);
      }
    }

    // Tüm gladyatörlere güç bonusu
    if (effects['gladiator_strength_all'] != null) {
      for (final g in state.gladiators) {
        g.trainStat('strength', effects['gladiator_strength_all'] as int);
      }
    }

    // Tüm gladyatörlere sağlık bonusu
    if (effects['gladiator_health_all'] != null) {
      for (final g in state.gladiators) {
        g.heal(effects['gladiator_health_all'] as int);
      }
    }

    // Kritik karar kaydet
    state.mainStory.keyDecisions[eventId] = choiceId;

    // Event görüldü olarak işaretle
    state.mainStory.seenMainEvents.add(eventId);

    // Bölüm güncellemesi
    state.mainStory.updateChapter(state.week);

    // Gecikmiş event tetikle
    if (choice['triggers_delayed_event'] != null) {
      final delayed = choice['triggers_delayed_event'] as Map<String, dynamic>;
      final delayedEventId = delayed['event_id'] as String;
      final delayWeeks = delayed['delay_weeks'] as int;

      state.mainStory.pendingEvents.add(PendingStoryEvent(
        id: '${eventId}_delayed_$delayedEventId',
        eventId: delayedEventId,
        triggerWeek: state.week + delayWeeks,
      ));
    }

    // Tehdit ekle
    if (effects['add_threat'] != null) {
      _addThreatFromId(effects['add_threat'] as String);
    }

    notifyListeners();

    return MainStoryResult(
      consequence: consequence,
      pathChosen: choice['path'] as String?,
      allyGained: effects['add_ally'] as String?,
      enemyGained: effects['add_enemy'] as String?,
    );
  }

  // Tehdit ID'den tehdit ekle
  Future<void> _addThreatFromId(String threatId) async {
    final mainStory = await loadMainStory();
    final threats = List<Map<String, dynamic>>.from(mainStory['threats'] ?? []);

    for (final threat in threats) {
      if (threat['id'] == threatId) {
        final newThreat = ActiveThreat(
          id: '${threatId}_${DateTime.now().millisecondsSinceEpoch}',
          type: threat['type'] as String,
          source: threat['source'] as String? ?? 'unknown',
          description: threat['description'] as String? ?? '',
          severity: threat['severity'] as int? ?? 5,
          turnsRemaining: threat['delay'] as int? ?? 1,
          effects: Map<String, dynamic>.from(threat['effects'] ?? {}),
        );
        state.mainStory.activeThreats.add(newThreat);
        break;
      }
    }
  }

  // Aktif tehditleri işle (her hafta sonunda)
  ThreatProcessResult processActiveThreats() {
    final results = <ThreatResult>[];
    final threatsToRemove = <String>[];

    for (final threat in state.mainStory.activeThreats) {
      threat.turnsRemaining--;

      if (threat.turnsRemaining <= 0) {
        // Tehdit aktif! Dice roll yap
        final defended = threat.rollDefense(
          state.mainStory.security,
          _random.nextInt(20), // Şans faktörü
        );

        if (defended) {
          results.add(ThreatResult(
            threat: threat,
            defended: true,
            message: 'Tehdit savuşturuldu: ${threat.description}',
          ));
        } else {
          // Tehdit başarılı - etkileri uygula
          _applyThreatEffects(threat);
          results.add(ThreatResult(
            threat: threat,
            defended: false,
            message: 'Tehdit başarılı: ${threat.description}',
            effects: threat.effects,
          ));
        }

        threatsToRemove.add(threat.id);
      }
    }

    // İşlenmiş tehditleri kaldır
    for (final id in threatsToRemove) {
      state.mainStory.activeThreats.removeWhere((t) => t.id == id);
    }

    notifyListeners();

    return ThreatProcessResult(results: results);
  }

  // Tehdit etkilerini uygula
  void _applyThreatEffects(ActiveThreat threat) {
    final effects = threat.effects;

    if (effects['gold'] != null) {
      state.modifyGold(effects['gold'] as int);
    }

    if (effects['reputation'] != null) {
      state.modifyReputation(effects['reputation'] as int);
    }

    if (effects['gladiator_damage'] != null) {
      if (state.gladiators.isNotEmpty) {
        final target = state.gladiators[_random.nextInt(state.gladiators.length)];
        target.takeDamage(effects['gladiator_damage'] as int);
      }
    }

    if (effects['gladiator_damage_all'] != null) {
      for (final g in state.gladiators) {
        g.takeDamage(effects['gladiator_damage_all'] as int);
      }
    }

    if (effects['gladiator_damage_random'] != null) {
      if (state.gladiators.isNotEmpty) {
        final target = state.gladiators[_random.nextInt(state.gladiators.length)];
        target.takeDamage(effects['gladiator_damage_random'] as int);
      }
    }

    if (effects['wife_kidnapped'] == true) {
      state.mainStory.wifeAlive = false; // Geçici olarak "kayıp"
    }

    if (effects['child_kidnapped'] == true) {
      state.mainStory.childrenSafe = false;
    }

    if (effects['lose_gladiators'] != null) {
      final count = effects['lose_gladiators'] as int;
      for (int i = 0; i < count && state.gladiators.isNotEmpty; i++) {
        state.gladiators.removeAt(_random.nextInt(state.gladiators.length));
      }
    }

    if (effects['health'] != null) {
      // Oyuncunun sağlığı için özel bir sistem eklenebilir
      // Şimdilik güvenliği düşürüyoruz
      state.mainStory.modifySecurity(effects['health'] as int);
    }
  }

  // Tehdit savunma seçenekleri için dice roll
  ThreatDefenseResult rollThreatDefense(ActiveThreat threat, Map<String, dynamic> defenseOption) {
    final securityBonus = defenseOption['security_bonus'] as int? ?? 0;
    final totalSecurity = state.mainStory.security + securityBonus;

    final defended = threat.rollDefense(totalSecurity, _random.nextInt(20));

    String message;
    Map<String, dynamic>? appliedEffects;

    if (defended) {
      message = defenseOption['success_text'] as String? ?? 'Başarılı!';

      // Başarı tetikleyicisi
      if (defenseOption['success_triggers'] != null) {
        // Event tetikle
      }
    } else {
      message = defenseOption['failure_text'] as String? ?? 'Başarısız!';
      appliedEffects = defenseOption['failure_effects'] as Map<String, dynamic>?;

      // Başarısızlık etkilerini uygula
      if (appliedEffects != null) {
        if (appliedEffects['gold'] != null) {
          state.modifyGold(appliedEffects['gold'] as int);
        }
        if (appliedEffects['gladiator_damage'] != null) {
          if (state.gladiators.isNotEmpty) {
            for (final g in state.gladiators) {
              g.takeDamage(appliedEffects['gladiator_damage'] as int);
            }
          }
        }
        if (appliedEffects['health'] != null) {
          state.mainStory.modifySecurity(appliedEffects['health'] as int);
        }
        if (appliedEffects['week_skip'] != null) {
          // Hafta atlama işlemi
        }
      }
    }

    notifyListeners();

    return ThreatDefenseResult(
      defended: defended,
      message: message,
      appliedEffects: appliedEffects,
    );
  }

  // Final kontrolü
  Future<Map<String, dynamic>?> checkForFinale() async {
    if (state.week < 50) return null;

    final mainStory = await loadMainStory();
    final finaleEvent = (mainStory['chapter4_events'] as List?)
        ?.firstWhere((e) => e['type'] == 'finale', orElse: () => null);

    if (finaleEvent == null) return null;

    // Ending belirle
    final endings = finaleEvent['endings'] as Map<String, dynamic>?;
    if (endings == null) return null;

    for (final entry in endings.entries) {
      final endingId = entry.key;
      final ending = entry.value as Map<String, dynamic>;
      final requirements = ending['requirements'] as Map<String, dynamic>?;

      if (requirements != null && _checkEndingRequirements(requirements)) {
        return {
          'ending_id': endingId,
          'ending': ending,
          'event': finaleEvent,
        };
      }
    }

    return null;
  }

  // Ending gereksinimlerini kontrol et
  bool _checkEndingRequirements(Map<String, dynamic> requirements) {
    // Path kontrolü
    if (requirements['path'] != null) {
      final requiredPath = requirements['path'] as String;
      if (requiredPath == 'vengeance' && state.mainStory.path != StoryPath.vengeance) return false;
      if (requiredPath == 'loyalty' && state.mainStory.path != StoryPath.loyalty) return false;
    }

    // Sezar ilişkisi
    if (requirements['min_caesar_relation'] != null) {
      if (state.mainStory.caesarRelation < (requirements['min_caesar_relation'] as int)) return false;
    }
    if (requirements['max_caesar_relation'] != null) {
      if (state.mainStory.caesarRelation > (requirements['max_caesar_relation'] as int)) return false;
    }

    // Güvenlik
    if (requirements['min_security'] != null) {
      if (state.mainStory.security < (requirements['min_security'] as int)) return false;
    }

    // Komplo ısısı
    if (requirements['min_conspiracy_heat'] != null) {
      if (state.mainStory.conspiracyHeat < (requirements['min_conspiracy_heat'] as int)) return false;
    }
    if (requirements['max_conspiracy_heat'] != null) {
      if (state.mainStory.conspiracyHeat > (requirements['max_conspiracy_heat'] as int)) return false;
    }

    // Müttefik kontrolü
    if (requirements['allies_contain'] != null) {
      final requiredAllies = List<String>.from(requirements['allies_contain']);
      for (final ally in requiredAllies) {
        if (!state.mainStory.allies.contains(ally)) return false;
      }
    }

    // Müttefik yok kontrolü
    if (requirements['no_allies'] == true) {
      if (state.mainStory.allies.isNotEmpty) return false;
    }

    // Aile durumu
    if (requirements['family_alive'] == false) {
      if (state.mainStory.wifeAlive && state.mainStory.childrenSafe) return false;
    }

    // Final bonus kontrolü
    if (requirements['min_final_bonus'] != null) {
      // Final bonus'u hesapla (key decisions'a göre)
      final finalBonus = _calculateFinalBonus();
      if (finalBonus < (requirements['min_final_bonus'] as int)) return false;
    }

    // Path değişikliği kontrolü
    if (requirements['path_changes'] == true) {
      // Path değişikliği yapılıp yapılmadığını kontrol et
      if (!state.mainStory.keyDecisions.values.any((v) =>
          v == 'betray_conspiracy' || v == 'join_conspiracy_late')) {
        return false;
      }
    }

    return true;
  }

  // Final bonus hesapla
  int _calculateFinalBonus() {
    int bonus = 0;

    // Key decisions'dan bonus
    for (final decision in state.mainStory.keyDecisions.values) {
      if (decision.contains('prepare') || decision.contains('train')) {
        bonus += 10;
      }
    }

    // Güvenlikten bonus
    bonus += state.mainStory.security ~/ 10;

    // Müttefiklerden bonus
    bonus += state.mainStory.allies.length * 5;

    return bonus;
  }

  // Sezar erişim seviyesi metni
  String getCaesarAccessText() {
    final level = state.mainStory.getCaesarAccessLevel(state.reputation);
    switch (level) {
      case 'unknown':
        return 'Sezar seni tanımıyor';
      case 'known':
        return 'Sezar adını duymuş';
      case 'messenger':
        return 'Sezar\'a mesaj gönderebilirsin';
      case 'audience':
        return 'Sezar\'ın huzuruna çıkabilirsin';
      case 'trusted':
        return 'Sezar sana güveniyor';
      case 'inner_circle':
        return 'Sezar\'ın iç çemberindesin';
      default:
        return 'Bilinmiyor';
    }
  }
}

// Dövüş sonucu
class FightResult {
  final bool won;
  final String message;
  final int damageReceived;
  final int reward;

  FightResult({
    required this.won,
    required this.message,
    required this.damageReceived,
    required this.reward,
  });
}

// Pazarlık sonucu
class BluffResult {
  final bool success;
  final String message;
  final int goldChange;
  final int playerRoll;
  final int rivalRoll;

  BluffResult({
    required this.success,
    required this.message,
    required this.goldChange,
    this.playerRoll = 0,
    this.rivalRoll = 0,
  });
}

// Maaş ödeme sonucu
class SalaryResult {
  final bool paid;
  final int totalPaid;
  final String message;
  final bool rebellionRisk;

  SalaryResult({
    required this.paid,
    required this.totalPaid,
    required this.message,
    required this.rebellionRisk,
  });
}

// Event sonucu
class EventResult {
  final String message;
  final Child? child;

  EventResult({
    required this.message,
    this.child,
  });
}

// Ana hikaye sonucu
class MainStoryResult {
  final String consequence;
  final String? pathChosen;
  final String? allyGained;
  final String? enemyGained;

  MainStoryResult({
    required this.consequence,
    this.pathChosen,
    this.allyGained,
    this.enemyGained,
  });
}

// Tehdit sonucu
class ThreatResult {
  final ActiveThreat threat;
  final bool defended;
  final String message;
  final Map<String, dynamic>? effects;

  ThreatResult({
    required this.threat,
    required this.defended,
    required this.message,
    this.effects,
  });
}

// Tehdit işleme sonucu
class ThreatProcessResult {
  final List<ThreatResult> results;

  ThreatProcessResult({required this.results});

  bool get hasThreats => results.isNotEmpty;
  bool get anySucceeded => results.any((r) => !r.defended);
}

// Tehdit savunma sonucu
class ThreatDefenseResult {
  final bool defended;
  final String message;
  final Map<String, dynamic>? appliedEffects;

  ThreatDefenseResult({
    required this.defended,
    required this.message,
    this.appliedEffects,
  });
}

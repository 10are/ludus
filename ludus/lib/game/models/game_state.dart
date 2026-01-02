import 'gladiator.dart';
import '../constants.dart';

enum GamePhase { menu, playing, gameOver }

// Dövüş türleri
enum FightType { underground, smallArena, bigArena }

// Dövüş fırsatı
class FightOpportunity {
  final String id;
  final String title;
  final String description;
  final FightType type;
  final int reward;
  final int difficulty;
  final int enemyPower;
  final int requiredReputation; // Gerekli itibar
  bool isAvailable;

  FightOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.reward,
    required this.difficulty,
    required this.enemyPower,
    this.requiredReputation = 0,
    this.isAvailable = true,
  });
}

// Rakip türleri
enum RivalType { lanista, politician, military }

// Rakip ev sahibi
class Rival {
  final String id;
  final String name;
  final String title; // Lanista, Senator, Legatus
  final RivalType type;
  int wealth;
  int influence;
  int relationship; // -100 to 100
  final String personality;
  final String description;
  final String? imagePath;

  Rival({
    required this.id,
    required this.name,
    required this.title,
    required this.type,
    required this.wealth,
    required this.influence,
    this.relationship = 0,
    required this.personality,
    required this.description,
    this.imagePath,
  });
}

// Personel rolleri
enum StaffRole { doctor, trainer, servant }

// Görev türleri
enum MissionType { fixFight, rentGladiator, sabotage, senatorFavor, training, poison, bribe, patronage }

// Ana hikaye yolu
enum StoryPath { none, vengeance, loyalty }

// Ana hikaye bölümü
enum StoryChapter {
  prologue,    // Hafta 1-3: Giriş
  chapter1,    // Hafta 4-10: Miras
  chapter2,    // Hafta 11-25: Yükseliş
  chapter3,    // Hafta 26-40: Gölgeler
  chapter4,    // Hafta 41-50: Fırtına
  finale       // Hafta 50+: Son Perde
}

// Ana hikaye durumu
class MainStory {
  StoryPath path;
  StoryChapter chapter;
  int chapterProgress; // Bölüm içi ilerleme (0-100)
  int caesarRelation; // Sezar ile ilişki (-100 to +100)
  int security; // Güvenlik seviyesi (0-100) - komplo koruması
  int conspiracyHeat; // Komplo ısısı (0-100) - yakalanma riski (sadece vengeance)

  // Kritik kararlar
  Map<String, String> keyDecisions;

  // Müttefikler
  Set<String> allies;
  Set<String> enemies;

  // Aile durumu
  bool wifeAlive;
  bool wifeLoyalty; // true = sana sadık, false = casusluk yapıyor
  bool childrenSafe;
  int familyLoyalty; // 0-100

  // Görülen ana hikaye olayları
  Set<String> seenMainEvents;

  // Bekleyen olaylar (gelecek haftalarda tetiklenecek)
  List<PendingStoryEvent> pendingEvents;

  // Aktif tehditler
  List<ActiveThreat> activeThreats;

  MainStory({
    this.path = StoryPath.none,
    this.chapter = StoryChapter.prologue,
    this.chapterProgress = 0,
    this.caesarRelation = 0,
    this.security = 50,
    this.conspiracyHeat = 0,
    Map<String, String>? keyDecisions,
    Set<String>? allies,
    Set<String>? enemies,
    this.wifeAlive = true,
    this.wifeLoyalty = true,
    this.childrenSafe = true,
    this.familyLoyalty = 70,
    Set<String>? seenMainEvents,
    List<PendingStoryEvent>? pendingEvents,
    List<ActiveThreat>? activeThreats,
  }) : keyDecisions = keyDecisions ?? {},
       allies = allies ?? {},
       enemies = enemies ?? {},
       seenMainEvents = seenMainEvents ?? {},
       pendingEvents = pendingEvents ?? [],
       activeThreats = activeThreats ?? [];

  // Güvenlik modifiye et
  void modifySecurity(int amount) {
    security = (security + amount).clamp(0, 100);
  }

  // Komplo ısısı modifiye et
  void modifyConspiracyHeat(int amount) {
    conspiracyHeat = (conspiracyHeat + amount).clamp(0, 100);
  }

  // Sezar ilişkisi modifiye et
  void modifyCaesarRelation(int amount) {
    caesarRelation = (caesarRelation + amount).clamp(-100, 100);
  }

  // Aile sadakati modifiye et
  void modifyFamilyLoyalty(int amount) {
    familyLoyalty = (familyLoyalty + amount).clamp(0, 100);
  }

  // Bölümü güncelle (haftaya göre)
  void updateChapter(int week) {
    if (week <= 3) {
      chapter = StoryChapter.prologue;
    } else if (week <= 10) {
      chapter = StoryChapter.chapter1;
    } else if (week <= 25) {
      chapter = StoryChapter.chapter2;
    } else if (week <= 40) {
      chapter = StoryChapter.chapter3;
    } else if (week <= 50) {
      chapter = StoryChapter.chapter4;
    } else {
      chapter = StoryChapter.finale;
    }
  }

  // Sezar ile iletişim seviyesi (itibara göre)
  String getCaesarAccessLevel(int reputation) {
    if (reputation < 100) return 'unknown'; // Tanınmıyor
    if (reputation < 300) return 'known'; // Biliniyor ama iletişim yok
    if (reputation < 500) return 'messenger'; // Haberci ile iletişim
    if (reputation < 800) return 'audience'; // Yılda 1 huzur
    if (reputation < 1200) return 'trusted'; // Doğrudan iletişim
    return 'inner_circle'; // İç çember
  }

  // Reset
  void reset() {
    path = StoryPath.none;
    chapter = StoryChapter.prologue;
    chapterProgress = 0;
    caesarRelation = 0;
    security = 50;
    conspiracyHeat = 0;
    keyDecisions.clear();
    allies.clear();
    enemies.clear();
    wifeAlive = true;
    wifeLoyalty = true;
    childrenSafe = true;
    familyLoyalty = 70;
    seenMainEvents.clear();
    pendingEvents.clear();
    activeThreats.clear();
  }
}

// Bekleyen hikaye olayı (gelecekte tetiklenecek)
class PendingStoryEvent {
  final String id;
  final String eventId; // main_story.json'daki event ID
  final int triggerWeek; // Tetiklenme haftası
  final String? condition; // Opsiyonel koşul
  bool triggered;

  PendingStoryEvent({
    required this.id,
    required this.eventId,
    required this.triggerWeek,
    this.condition,
    this.triggered = false,
  });
}

// Aktif tehdit (komplo, suikast, sabotaj vs)
class ActiveThreat {
  final String id;
  final String type; // 'assassination', 'sabotage', 'kidnap', 'betrayal', 'raid'
  final String source; // Tehdidin kaynağı
  final String description;
  int severity; // 1-10 şiddet
  int turnsRemaining; // Kalan hafta (0 = bu hafta)
  final Map<String, dynamic> effects; // Başarısız olursa etkiler

  ActiveThreat({
    required this.id,
    required this.type,
    required this.source,
    required this.description,
    required this.severity,
    required this.turnsRemaining,
    required this.effects,
  });

  // Tehdit dice roll hesaplama
  // security: Oyuncunun güvenlik puanı
  // Döner: true = tehdit savuşturuldu, false = tehdit başarılı
  bool rollDefense(int security, int luck) {
    // Base şans: %50
    // Her güvenlik puanı +0.5% şans
    // Her şiddet seviyesi -5% şans
    // Şans bonusu: luck/10 %
    final baseChance = 50;
    final securityBonus = (security * 0.5).round();
    final severityPenalty = severity * 5;
    final luckBonus = (luck / 10).round();

    final successChance = (baseChance + securityBonus - severityPenalty + luckBonus).clamp(5, 95);

    final roll = DateTime.now().millisecondsSinceEpoch % 100;
    return roll < successChance;
  }
}

// Çocuk sınıfı
class Child {
  final String id;
  final String name;
  final bool isMale; // true = erkek, false = kız
  int birthWeek; // Doğduğu hafta

  Child({
    required this.id,
    required this.name,
    required this.isMale,
    required this.birthWeek,
  });

  // Çocuğun yaşı (hafta olarak)
  int ageInWeeks(int currentWeek) => currentWeek - birthWeek;
}

// Aktif görev
class ActiveMission {
  final String id;
  final String missionId;
  final MissionType type;
  final String title;
  final String giverId;
  final String? targetGladiatorId;
  final int rewardGold;
  final int penaltyReputation;
  final int? healthDamage;
  final int? moraleChange;
  final int? riskCaught;
  final int? costGold;
  final int? durationWeeks;
  int remainingWeeks;
  bool isCompleted;
  bool isFailed;

  ActiveMission({
    required this.id,
    required this.missionId,
    required this.type,
    required this.title,
    required this.giverId,
    this.targetGladiatorId,
    this.rewardGold = 0,
    this.penaltyReputation = 0,
    this.healthDamage,
    this.moraleChange,
    this.riskCaught,
    this.costGold,
    this.durationWeeks,
    this.remainingWeeks = 1,
    this.isCompleted = false,
    this.isFailed = false,
  });
}

// Ev personeli
class Staff {
  final String id;
  final String name;
  final StaffRole role;
  int salary;
  int skill;
  int bonus; // Doktor: tedavi bonusu, Eğitmen: eğitim bonusu
  final String description;
  final String? imagePath;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.salary,
    required this.skill,
    this.bonus = 0,
    required this.description,
    this.imagePath,
  });
}

class GameState {
  GamePhase phase;
  int gold;
  int week;
  int reputation;

  List<Gladiator> gladiators;
  List<FightOpportunity> fights;
  List<Rival> rivals;
  List<Staff> staff;
  List<ActiveMission> activeMissions;

  // Ev / Okul
  bool hasWife;
  String wifeName;
  int wifeMorale; // Eşin morali (0-100)
  List<Child> children; // Çocuklar listesi
  int dialogueIndex; // Hangi diyalogda (haftalık)

  // Haftalık hikayeler
  Set<String> seenStories; // Görülen story ID'leri
  Set<String> seenEvents; // Görülen event ID'leri

  // İnteraktif hikaye seçimleri (oyuncunun kararları)
  Map<String, bool> storyChoices; // Örn: {"helped_stranger": true, "trusted_uncle": false}

  // Ana hikaye
  MainStory mainStory;

  GameState({
    this.phase = GamePhase.menu,
    this.gold = GameConstants.startingGold,
    this.week = 1,
    this.reputation = 0,
    List<Gladiator>? gladiators,
    List<FightOpportunity>? fights,
    List<Rival>? rivals,
    List<Staff>? staff,
    List<ActiveMission>? activeMissions,
    this.hasWife = true,
    this.wifeName = 'Lucretia',
    this.wifeMorale = 50,
    List<Child>? children,
    this.dialogueIndex = 0,
    Set<String>? seenStories,
    Set<String>? seenEvents,
    Map<String, bool>? storyChoices,
    MainStory? mainStory,
  })  : gladiators = gladiators ?? createStartingGladiators(),
        fights = fights ?? _createWeeklyFights(week),
        rivals = rivals ?? _createRivals(),
        staff = staff ?? _createInitialStaff(),
        activeMissions = activeMissions ?? [],
        children = children ?? [],
        seenStories = seenStories ?? {},
        seenEvents = seenEvents ?? {},
        storyChoices = storyChoices ?? {},
        mainStory = mainStory ?? MainStory();

  // Savaşabilir gladyatörler
  List<Gladiator> get availableForFight => gladiators.where((g) => g.canFight).toList();

  // Eğitilebilir gladyatörler
  List<Gladiator> get availableForTraining => gladiators.where((g) => g.canTrain).toList();

  // Toplam haftalık maaş
  int get totalWeeklySalary {
    int total = 0;
    for (final g in gladiators) {
      total += g.salary;
    }
    for (final s in staff) {
      total += s.salary;
    }
    return total;
  }

  // Altın ekle/çıkar
  void modifyGold(int amount) {
    gold = (gold + amount).clamp(0, 999999);
  }

  // İtibar ekle/çıkar
  void modifyReputation(int amount) {
    reputation = (reputation + amount).clamp(0, 999999);
  }

  // Hafta geçir
  void advanceWeek() {
    week++;

    // Gladyatörler dinlensin
    for (final glad in gladiators) {
      glad.weeklyRest();
      glad.resetNutrition(); // Beslenme durumu resetle
    }

    // Yeni dövüşler oluştur
    _regenerateFights();
  }

  void _regenerateFights() {
    fights = _createWeeklyFights(week);
  }

  // Hafta bazlı dinamik dövüş oluşturma
  static List<FightOpportunity> _createWeeklyFights(int week) {
    final fights = <FightOpportunity>[];

    // Yeraltı dövüşleri
    final undergroundCount = GameConstants.getUndergroundFightsPerWeek(week);
    for (int i = 0; i < undergroundCount; i++) {
      final basePower = 20 + (i * 10);
      final baseReward = 150 + (i * 50);
      fights.add(FightOpportunity(
        id: 'fight_underground_${week}_$i',
        title: _getUndergroundFightName(i),
        description: _getUndergroundFightDesc(i),
        type: FightType.underground,
        reward: GameConstants.getScaledReward(baseReward, week),
        difficulty: GameConstants.getScaledDifficulty(1 + (i ~/ 2), week),
        enemyPower: GameConstants.getScaledEnemyPower(basePower, week),
        requiredReputation: 0,
      ));
    }

    // Küçük arena dövüşleri (5. haftadan sonra)
    if (week >= 5) {
      final smallArenaCount = GameConstants.getSmallArenaFightsPerWeek(week);
      for (int i = 0; i < smallArenaCount; i++) {
        final basePower = 35 + (i * 15);
        final baseReward = 400 + (i * 100);
        fights.add(FightOpportunity(
          id: 'fight_small_${week}_$i',
          title: _getSmallArenaFightName(i),
          description: _getSmallArenaFightDesc(i),
          type: FightType.smallArena,
          reward: GameConstants.getScaledReward(baseReward, week),
          difficulty: GameConstants.getScaledDifficulty(2 + (i ~/ 2), week),
          enemyPower: GameConstants.getScaledEnemyPower(basePower, week),
          requiredReputation: GameConstants.getRequiredReputation(week, 'smallArena'),
        ));
      }
    }

    // Büyük arena dövüşleri (15. haftadan sonra)
    if (week >= 15) {
      final bigArenaCount = GameConstants.getBigArenaFightsPerWeek(week);
      for (int i = 0; i < bigArenaCount; i++) {
        final basePower = 55 + (i * 20);
        final baseReward = 1000 + (i * 400);
        fights.add(FightOpportunity(
          id: 'fight_big_${week}_$i',
          title: _getBigArenaFightName(i),
          description: _getBigArenaFightDesc(i),
          type: FightType.bigArena,
          reward: GameConstants.getScaledReward(baseReward, week),
          difficulty: GameConstants.getScaledDifficulty(4 + i, week),
          enemyPower: GameConstants.getScaledEnemyPower(basePower, week),
          requiredReputation: GameConstants.getRequiredReputation(week, 'bigArena'),
        ));
      }
    }

    // 50. Hafta: Colosseum'da Büyük Final Dövüşü (Caesar önünde)
    if (week == GameConstants.finalWeek) {
      fights.add(FightOpportunity(
        id: 'fight_finale_caesar',
        title: 'COLOSSEUM FİNALİ',
        description: 'İmparator Caesar\'ın huzurunda son büyük dövüş. Tüm Roma izliyor!',
        type: FightType.bigArena,
        reward: 5000,
        difficulty: 6,
        enemyPower: 120, // Çok güçlü rakip
        requiredReputation: 200,
      ));
    }

    return fights;
  }

  // Yeraltı dövüşü isimleri
  static String _getUndergroundFightName(int index) {
    const names = [
      'Karanlık Mahzen',
      'Gece Arenası',
      'Kanlı Bodrum',
      'Gizli Ring',
      'Yeraltı Kumarhanesi',
    ];
    return names[index.clamp(0, names.length - 1)];
  }

  static String _getUndergroundFightDesc(int index) {
    const descs = [
      'Yasadışı yeraltı dövüşü',
      'Gizli kumarhane dövüşü',
      'Ölümüne dövüş',
      'Karanlık sokaklarda gizli maç',
      'Zenginlerin gizli eğlencesi',
    ];
    return descs[index.clamp(0, descs.length - 1)];
  }

  // Küçük arena isimleri
  static String _getSmallArenaFightName(int index) {
    const names = [
      'Yerel Arena',
      'Capua Arenası',
      'Neapolis Oyunları',
      'Pompeii Festivali',
    ];
    return names[index.clamp(0, names.length - 1)];
  }

  static String _getSmallArenaFightDesc(int index) {
    const descs = [
      'Kasaba arenasında halka açık dövüş',
      'Capua\'da gösteri',
      'Neapolis şehrinde turnuva',
      'Pompeii\'nin büyük oyunları',
    ];
    return descs[index.clamp(0, descs.length - 1)];
  }

  // Büyük arena isimleri
  static String _getBigArenaFightName(int index) {
    const names = [
      'Colosseum',
      'İmparator Önünde',
      'Şampiyonlar Ligi',
    ];
    return names[index.clamp(0, names.length - 1)];
  }

  static String _getBigArenaFightDesc(int index) {
    const descs = [
      'Roma\'nın kalbinde büyük gösteri',
      'İmparatorun huzurunda dövüş',
      'En iyi gladyatörler arasında turnuva',
    ];
    return descs[index.clamp(0, descs.length - 1)];
  }

  // Eş morali değiştir
  void modifyWifeMorale(int amount) {
    wifeMorale = (wifeMorale + amount).clamp(0, 100);
  }

  // Çocuk var mı?
  bool get hasChild => children.isNotEmpty;

  // Çocuk sahibi ol (moral 80+ olmalı)
  Child? addChild(String name, bool isMale) {
    if (wifeMorale >= 80 && hasWife) {
      final child = Child(
        id: 'child_${children.length + 1}',
        name: name,
        isMale: isMale,
        birthWeek: week,
      );
      children.add(child);
      return child;
    }
    return null;
  }

  // Oyunu sıfırla
  void reset() {
    phase = GamePhase.playing;
    gold = GameConstants.startingGold;
    week = 1;
    reputation = 0;
    gladiators = createStartingGladiators();
    fights = _createWeeklyFights(1);
    rivals = _createRivals();
    staff = _createInitialStaff();
    activeMissions = [];
    hasWife = true;
    wifeName = 'Lucretia';
    wifeMorale = 50;
    children = [];
    dialogueIndex = 0;
    seenStories = {};
    seenEvents = {};
    storyChoices = {};
    mainStory.reset();
  }
}

// Rakipler
List<Rival> _createRivals() {
  return [
    Rival(
      id: 'rival_1',
      name: 'Quintus Batiatus',
      title: 'Lanista',
      type: RivalType.lanista,
      wealth: 2000,
      influence: 40,
      relationship: -10,
      personality: 'cunning',
      description: 'Capua\'nın en kurnaz ludus sahibi',
    ),
    Rival(
      id: 'rival_2',
      name: 'Solonius',
      title: 'Lanista',
      type: RivalType.lanista,
      wealth: 1500,
      influence: 35,
      relationship: -20,
      personality: 'aggressive',
      description: 'Acımasız ve hırslı bir rakip',
    ),
    Rival(
      id: 'rival_3',
      name: 'Senator Albinius',
      title: 'Senator',
      type: RivalType.politician,
      wealth: 5000,
      influence: 80,
      relationship: 0,
      personality: 'cautious',
      description: 'Roma senatosunun güçlü isimlerinden',
    ),
    Rival(
      id: 'rival_4',
      name: 'Legatus Glaber',
      title: 'Legatus',
      type: RivalType.military,
      wealth: 3000,
      influence: 70,
      relationship: 5,
      personality: 'proud',
      description: 'Roma lejyonlarının komutanı',
    ),
  ];
}

// Başlangıç personeli
List<Staff> _createInitialStaff() {
  return [
    Staff(
      id: 'staff_1',
      name: 'Doctore',
      role: StaffRole.trainer,
      salary: 30,
      skill: 40,
      bonus: 2,
      description: 'Gladyatör eğitmeni',
    ),
  ];
}

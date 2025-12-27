import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/gladiator.dart';
import '../models/game_state.dart';

/// JSON dosyalarından oyun verilerini yükleyen servis
class DataService {
  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString);
  }

  /// Başlangıç gladyatörlerini yükle
  static Future<List<Gladiator>> loadStartingGladiators() async {
    final data = await _loadJson('assets/data/gladiators.json');
    final List<dynamic> gladiators = data['starting_gladiators'];

    return gladiators.map((g) => Gladiator(
      id: g['id'],
      name: g['name'],
      origin: g['origin'],
      age: g['age'],
      health: g['health'],
      strength: g['strength'],
      intelligence: g['intelligence'],
      stamina: g['stamina'],
      salary: g['salary'],
      morale: g['morale'],
      imagePath: g['image'],
    )).toList();
  }

  /// Pazardaki köleleri yükle
  static Future<List<Gladiator>> loadMarketSlaves() async {
    final data = await _loadJson('assets/data/gladiators.json');
    final List<dynamic> slaves = data['market_slaves'];

    return slaves.map((g) => Gladiator(
      id: g['id'],
      name: g['name'],
      origin: g['origin'],
      age: g['age'],
      health: g['health'],
      strength: g['strength'],
      intelligence: g['intelligence'],
      stamina: g['stamina'],
      salary: 0, // Başlangıçta maaş yok
      morale: 50,
      imagePath: g['image'],
      price: g['price'],
    )).toList();
  }

  /// Rakipleri yükle (Lanistalar, Politikacılar, Askeri)
  static Future<List<Rival>> loadRivals() async {
    final data = await _loadJson('assets/data/rivals.json');
    final List<Rival> rivals = [];

    // Lanistalar
    for (var r in data['lanistas']) {
      rivals.add(Rival(
        id: r['id'],
        name: r['name'],
        title: r['title'],
        type: RivalType.lanista,
        wealth: r['wealth'],
        influence: r['influence'],
        relationship: r['relationship'],
        personality: r['personality'],
        description: r['description'],
        imagePath: r['image'],
      ));
    }

    // Politikacılar
    for (var r in data['politicians']) {
      rivals.add(Rival(
        id: r['id'],
        name: r['name'],
        title: r['title'],
        type: RivalType.politician,
        wealth: r['wealth'],
        influence: r['influence'],
        relationship: r['relationship'],
        personality: r['personality'],
        description: r['description'],
        imagePath: r['image'],
      ));
    }

    // Askeri
    for (var r in data['military']) {
      rivals.add(Rival(
        id: r['id'],
        name: r['name'],
        title: r['title'],
        type: RivalType.military,
        wealth: r['wealth'],
        influence: r['influence'],
        relationship: r['relationship'],
        personality: r['personality'],
        description: r['description'],
        imagePath: r['image'],
      ));
    }

    return rivals;
  }

  /// Personeli yükle (Doktorlar, Eğitmenler)
  static Future<List<Staff>> loadAvailableStaff() async {
    final data = await _loadJson('assets/data/staff.json');
    final List<Staff> staff = [];

    for (var s in data['available_staff']) {
      staff.add(Staff(
        id: s['id'],
        name: s['name'],
        role: s['role'] == 'doctor' ? StaffRole.doctor : StaffRole.trainer,
        skill: s['skill'],
        salary: s['salary'],
        bonus: s['bonus'],
        description: s['description'],
        imagePath: s['image'],
      ));
    }

    return staff;
  }

  /// Ev kölelerini yükle
  static Future<List<Staff>> loadHouseSlaves() async {
    final data = await _loadJson('assets/data/staff.json');
    final List<Staff> slaves = [];

    for (var s in data['house_slaves']) {
      slaves.add(Staff(
        id: s['id'],
        name: s['name'],
        role: StaffRole.servant,
        skill: s['skill'],
        salary: s['salary'],
        bonus: 0,
        description: s['description'],
        imagePath: s['image'],
      ));
    }

    return slaves;
  }

  /// Dövüş fırsatlarını yükle
  static Future<List<FightOpportunity>> loadFights() async {
    final data = await _loadJson('assets/data/fights.json');
    final List<FightOpportunity> fights = [];

    // Underground fights
    for (var f in data['underground_fights']) {
      fights.add(FightOpportunity(
        id: f['id'],
        title: f['title'],
        description: f['description'],
        type: FightType.underground,
        reward: f['reward'],
        difficulty: f['difficulty'],
        enemyPower: f['enemy_power'],
      ));
    }

    // Small arena fights
    for (var f in data['small_arena_fights']) {
      fights.add(FightOpportunity(
        id: f['id'],
        title: f['title'],
        description: f['description'],
        type: FightType.smallArena,
        reward: f['reward'],
        difficulty: f['difficulty'],
        enemyPower: f['enemy_power'],
      ));
    }

    // Big arena fights
    for (var f in data['big_arena_fights']) {
      fights.add(FightOpportunity(
        id: f['id'],
        title: f['title'],
        description: f['description'],
        type: FightType.bigArena,
        reward: f['reward'],
        difficulty: f['difficulty'],
        enemyPower: f['enemy_power'],
        requiredReputation: f['required_reputation'] ?? 0,
      ));
    }

    return fights;
  }

  /// Tüm verileri yükle
  static Future<GameData> loadAllGameData() async {
    final results = await Future.wait([
      loadStartingGladiators(),
      loadMarketSlaves(),
      loadRivals(),
      loadAvailableStaff(),
      loadHouseSlaves(),
      loadFights(),
    ]);

    return GameData(
      startingGladiators: results[0] as List<Gladiator>,
      marketSlaves: results[1] as List<Gladiator>,
      rivals: results[2] as List<Rival>,
      availableStaff: results[3] as List<Staff>,
      houseSlaves: results[4] as List<Staff>,
      fights: results[5] as List<FightOpportunity>,
    );
  }
}

/// Tüm oyun verilerini tutan sınıf
class GameData {
  final List<Gladiator> startingGladiators;
  final List<Gladiator> marketSlaves;
  final List<Rival> rivals;
  final List<Staff> availableStaff;
  final List<Staff> houseSlaves;
  final List<FightOpportunity> fights;

  GameData({
    required this.startingGladiators,
    required this.marketSlaves,
    required this.rivals,
    required this.availableStaff,
    required this.houseSlaves,
    required this.fights,
  });
}

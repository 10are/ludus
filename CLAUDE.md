# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ludus Simülatör is a Flutter-based gladiator school management game. Players manage a Roman ludus (gladiator training school), including buying/training gladiators, fighting in arenas, diplomacy with rivals, and managing household economics.

## Build & Run Commands

```bash
# Navigate to Flutter project
cd ludus

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for release
flutter build apk          # Android
flutter build ios          # iOS

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Generate app icons (uses flutter_launcher_icons)
flutter pub run flutter_launcher_icons
```

## Architecture

### State Management
- Uses **Provider** with `ChangeNotifier` pattern
- `GladiatorGame` (lib/game/gladiator_game.dart) is the main game controller/state manager
- `GameState` (lib/game/models/game_state.dart) holds all game data
- `main.dart` wraps the app in `ChangeNotifierProvider<GladiatorGame>`

### App Structure
```
lib/
├── main.dart                    # Entry point, GameRouter for phase-based navigation
└── game/
    ├── gladiator_game.dart      # Main game logic (training, fighting, diplomacy, salaries)
    ├── constants.dart           # Game constants and Roman-themed color palette
    ├── models/
    │   ├── gladiator.dart       # Gladiator class with stats, combat, morale systems
    │   └── game_state.dart      # GameState, enums, data classes (Rival, Staff, FightOpportunity, etc.)
    ├── screens/                 # UI screens (HomeScreen, FightScreen, MarketScreen, etc.)
    │   └── components/          # Reusable UI components
    └── services/
        ├── data_service.dart    # JSON data loader for game content
        └── audio_service.dart   # Background music and sound effects
```

### Navigation
- Phase-based routing in `GameRouter` using `GamePhase` enum (menu, playing, gameOver)
- Screens navigate using `Navigator.push()` within the playing phase

### Data System
- Game content loaded from JSON files in `assets/data/`
- `DataService` handles async loading of gladiators, rivals, staff, fights from JSON
- Static data: gladiators.json, rivals.json, staff.json, fights.json, fight_commentary.json, etc.

### Key Game Mechanics
- **Gladiator stats**: health, strength, intelligence, stamina (affects overallPower for combat)
- **Combat**: dice-roll based with power modifiers; results affect health, morale, reputation
- **Economy**: gold management, weekly salaries, rebellion risk if unpaid
- **Morale system**: affects gladiator performance and rebellion risk
- **Mission system**: timed objectives with rewards/penalties

## UI Theming
- Roman-inspired color palette defined in `GameConstants` (warm browns, gold accents, blood red)
- Portrait-only orientation enforced in main.dart
- Immersive sticky system UI mode

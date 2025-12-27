import 'dart:ui';

class GameConstants {
  // Screen & World
  static const double worldWidth = 400;
  static const double worldHeight = 800;

  // Player
  static const double playerWidth = 30;
  static const double playerHeight = 40;
  static const double gravity = 900;
  static const double maxJumpPower = 750;
  static const double minJumpPower = 250;
  static const double chargeRate = 550; // Power per second
  static const double horizontalSpeed = 200;
  static const double maxFallSpeed = 800;

  // Platforms
  static const double platformHeight = 15;
  static const double minPlatformWidth = 60;
  static const double maxPlatformWidth = 120;
  static const double minPlatformGap = 80;
  static const double maxPlatformGap = 150;
  static const double platformSpawnBuffer = 300;

  // Platform types probability (must sum to 1.0)
  static const double normalPlatformChance = 0.7;
  static const double slipperyPlatformChance = 0.15;
  static const double bouncyPlatformChance = 0.15;

  // Slippery platform
  static const double slipperyFriction = 0.02;
  static const double slipperySlideSpeed = 150;

  // Bouncy platform
  static const double bouncyMultiplier = 1.4;

  // Camera
  static const double cameraFollowSpeed = 5.0;
  static const double cameraDeadzone = 200;

  // Colors
  static const Color backgroundColor = Color(0xFF1a1a2e);
  static const Color playerColor = Color(0xFFe94560);
  static const Color normalPlatformColor = Color(0xFF16213e);
  static const Color slipperyPlatformColor = Color(0xFF4fc3f7);
  static const Color bouncyPlatformColor = Color(0xFF66bb6a);
  static const Color chargeBarBackground = Color(0xFF333333);
  static const Color chargeBarFill = Color(0xFFff6b6b);
  static const Color textColor = Color(0xFFffffff);
  static const Color hudBackground = Color(0x88000000);

  // Game feel
  static const double deathFallDistance = 0; // Die immediately when leaving camera view
  static const double startPlatformWidth = 150;
  static const double startPlatformY = 700; // Near bottom of screen

  // Difficulty scaling
  static const double difficultyIncreasePerMeter = 0.001;
  static const double maxDifficultyMultiplier = 2.0;
  static const double minPlatformWidthAtMaxDifficulty = 40;
  static const double maxPlatformGapAtMaxDifficulty = 200;
}

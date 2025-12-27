import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'components/player.dart';
import 'components/platform_manager.dart';

enum GameState { menu, playing, gameOver }

class OneMoreJumpGame extends FlameGame
    with HasCollisionDetection, PanDetector, TapDetector {
  late Player player;
  late PlatformManager platformManager;

  GameState gameState = GameState.menu;
  int currentScore = 0;
  int highScore = 0;
  double _startY = 0;

  // Touch controls
  Vector2 _touchStartPos = Vector2.zero();
  bool _isCharging = false;

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await _loadHighScore();

    // Setup camera to fit world width
    camera.viewfinder.anchor = Anchor.center;

    // Create platform manager first (so platforms exist before player)
    platformManager = PlatformManager();
    add(platformManager);

    // Create player - position slightly above platform so collision triggers
    player = Player(
      position: Vector2(
        GameConstants.worldWidth / 2,
        GameConstants.startPlatformY - 5,
      ),
    );
    world.add(player);

    _startY = player.position.y;

    // Position camera
    camera.viewfinder.position = Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.startPlatformY - GameConstants.cameraDeadzone,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Scale camera to fit world width while maintaining aspect ratio
    final scale = size.x / GameConstants.worldWidth;
    camera.viewfinder.zoom = scale;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == GameState.playing) {
      _updateScore();
      _updateCamera();
    }
  }

  void _updateScore() {
    final heightClimbed = _startY - player.highestY;
    currentScore = (heightClimbed / 10).floor().clamp(0, double.infinity).toInt();
  }

  void _updateCamera() {
    final targetY = player.position.y - GameConstants.cameraDeadzone;

    // Only move camera up, never down
    if (targetY < camera.viewfinder.position.y) {
      camera.viewfinder.position = Vector2(
        GameConstants.worldWidth / 2,
        targetY,
      );
    }
  }

  // Touch controls
  @override
  void onTapDown(TapDownInfo info) {
    if (gameState == GameState.menu) {
      startGame();
      return;
    }

    if (gameState == GameState.playing) {
      _isCharging = true;
      _touchStartPos = info.eventPosition.global.clone();
      // Force player to be on ground at start
      if (!player.isOnGround && player.velocity.y == 0) {
        player.isOnGround = true;
      }
      player.startCharging();
    }
  }

  @override
  void onTapUp(TapUpInfo info) {
    if (_isCharging && gameState == GameState.playing) {
      player.jump();
      _isCharging = false;
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (gameState == GameState.playing) {
      _isCharging = true;
      _touchStartPos = info.eventPosition.global.clone();
      // Force player to be on ground at start
      if (!player.isOnGround && player.velocity.y == 0) {
        player.isOnGround = true;
      }
      player.startCharging();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_isCharging && gameState == GameState.playing) {
      final currentPos = info.eventPosition.global;
      final dx = currentPos.x - _touchStartPos.x;
      final dy = currentPos.y - _touchStartPos.y;

      // Set aim direction based on drag
      player.setAimDirection(dx, dy);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_isCharging && gameState == GameState.playing) {
      player.jump();
      _isCharging = false;
    }
  }

  void startGame() {
    gameState = GameState.playing;
    currentScore = 0;
    _startY = player.position.y;

    // Reset camera
    camera.viewfinder.position = Vector2(
      GameConstants.worldWidth / 2,
      player.position.y - GameConstants.cameraDeadzone,
    );

    overlays.remove('MainMenu');
    overlays.add('HUD');
  }

  void gameOver() {
    if (gameState != GameState.playing) return;

    gameState = GameState.gameOver;
    _isCharging = false;

    // Update high score
    if (currentScore > highScore) {
      highScore = currentScore;
      _saveHighScore();
    }

    overlays.remove('HUD');
    overlays.add('GameOver');
  }

  void restart() {
    // Reset player
    player.reset(Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.startPlatformY,
    ));

    // Reset platforms
    platformManager.reset();

    // Reset camera
    camera.viewfinder.position = Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.startPlatformY - GameConstants.cameraDeadzone,
    );

    // Reset score
    currentScore = 0;
    _startY = GameConstants.startPlatformY;

    // Change state
    gameState = GameState.playing;

    overlays.remove('GameOver');
    overlays.add('HUD');
  }

  void returnToMenu() {
    // Reset player
    player.reset(Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.startPlatformY,
    ));

    // Reset platforms
    platformManager.reset();

    // Reset camera
    camera.viewfinder.position = Vector2(
      GameConstants.worldWidth / 2,
      GameConstants.startPlatformY - GameConstants.cameraDeadzone,
    );

    gameState = GameState.menu;

    overlays.remove('GameOver');
    overlays.remove('HUD');
    overlays.add('MainMenu');
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
  }

  double get chargePercent {
    if (player.state == PlayerState.charging) {
      return player.jumpPower / GameConstants.maxJumpPower;
    }
    return 0;
  }
}

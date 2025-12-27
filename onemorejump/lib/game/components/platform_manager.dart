import 'dart:math';
import 'package:flame/components.dart';
import '../constants.dart';
import '../one_more_jump_game.dart';
import 'platform.dart';

class PlatformManager extends Component with HasGameReference<OneMoreJumpGame> {
  final List<Platform> platforms = [];
  final Random _random = Random();
  double _highestPlatformY = GameConstants.startPlatformY;
  double _lowestVisibleY = 0;

  @override
  Future<void> onLoad() async {
    // Create starting platform
    _createStartPlatform();

    // Generate initial platforms
    _generateInitialPlatforms();
  }

  void _createStartPlatform() {
    final startPlatform = Platform(
      position: Vector2(
        GameConstants.worldWidth / 2,
        GameConstants.startPlatformY,
      ),
      width: GameConstants.startPlatformWidth,
      type: PlatformType.normal,
    );
    platforms.add(startPlatform);
    game.world.add(startPlatform);
  }

  void _generateInitialPlatforms() {
    // Generate platforms above the start
    while (_highestPlatformY > -GameConstants.worldHeight) {
      _spawnNextPlatform();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final cameraY = game.camera.viewfinder.position.y;
    final screenTop = cameraY - game.size.y / 2;
    final screenBottom = cameraY + game.size.y / 2;

    // Spawn new platforms above camera
    while (_highestPlatformY > screenTop - GameConstants.platformSpawnBuffer) {
      _spawnNextPlatform();
    }

    // Remove platforms below camera
    _lowestVisibleY = screenBottom + GameConstants.deathFallDistance;
    _removeOffscreenPlatforms();
  }

  void _spawnNextPlatform() {
    final difficulty = _calculateDifficulty();

    // Calculate gap based on difficulty
    final minGap = GameConstants.minPlatformGap;
    final maxGap = GameConstants.maxPlatformGap +
        (GameConstants.maxPlatformGapAtMaxDifficulty -
                GameConstants.maxPlatformGap) *
            difficulty;
    final gap = minGap + _random.nextDouble() * (maxGap - minGap);

    // Calculate width based on difficulty
    final minWidth = GameConstants.minPlatformWidth -
        (GameConstants.minPlatformWidth -
                GameConstants.minPlatformWidthAtMaxDifficulty) *
            difficulty;
    final maxWidth = GameConstants.maxPlatformWidth -
        (GameConstants.maxPlatformWidth - GameConstants.minPlatformWidth) *
            difficulty *
            0.5;
    final width = minWidth + _random.nextDouble() * (maxWidth - minWidth);

    // Random horizontal position
    final margin = width / 2 + 10;
    final x = margin + _random.nextDouble() * (GameConstants.worldWidth - margin * 2);

    // New platform position
    final y = _highestPlatformY - gap;

    // Determine platform type
    final type = _randomPlatformType();

    final platform = Platform(
      position: Vector2(x, y),
      width: width,
      type: type,
    );

    platforms.add(platform);
    game.world.add(platform);
    _highestPlatformY = y;
  }

  double _calculateDifficulty() {
    final heightClimbed = GameConstants.startPlatformY - _highestPlatformY;
    final difficulty = heightClimbed * GameConstants.difficultyIncreasePerMeter;
    return difficulty.clamp(0.0, GameConstants.maxDifficultyMultiplier);
  }

  PlatformType _randomPlatformType() {
    final roll = _random.nextDouble();

    if (roll < GameConstants.normalPlatformChance) {
      return PlatformType.normal;
    } else if (roll <
        GameConstants.normalPlatformChance +
            GameConstants.slipperyPlatformChance) {
      return PlatformType.slippery;
    } else {
      return PlatformType.bouncy;
    }
  }

  void _removeOffscreenPlatforms() {
    final toRemove = <Platform>[];

    for (final platform in platforms) {
      if (platform.position.y > _lowestVisibleY) {
        toRemove.add(platform);
      }
    }

    for (final platform in toRemove) {
      platforms.remove(platform);
      platform.removeFromParent();
    }
  }

  void reset() {
    // Remove all platforms
    for (final platform in platforms) {
      platform.removeFromParent();
    }
    platforms.clear();

    // Reset state
    _highestPlatformY = GameConstants.startPlatformY;

    // Recreate starting platform and initial platforms
    _createStartPlatform();
    _generateInitialPlatforms();
  }
}

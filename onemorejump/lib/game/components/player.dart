import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../one_more_jump_game.dart';
import 'platform.dart';

enum PlayerState { idle, charging, jumping, falling }
enum PlayerMood { normal, happy, scared, ouch }

class Player extends PositionComponent
    with HasGameReference<OneMoreJumpGame>, CollisionCallbacks {
  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.bottomCenter,
        );

  PlayerState state = PlayerState.idle;
  PlayerMood mood = PlayerMood.normal;
  Vector2 velocity = Vector2.zero();
  double jumpPower = 0;
  double aimAngle = -90; // degrees, -90 = straight up
  bool isOnGround = false;
  Platform? currentPlatform;
  double highestY = 0;
  double _moodTimer = 0;
  double _squashStretch = 1.0;

  late final RectangleHitbox hitbox;

  @override
  Future<void> onLoad() async {
    hitbox = RectangleHitbox();
    add(hitbox);
    highestY = position.y;
  }

  @override
  void render(Canvas canvas) {
    // Apply squash/stretch effect
    canvas.save();
    canvas.translate(size.x / 2, size.y);
    canvas.scale(1 / _squashStretch, _squashStretch);
    canvas.translate(-size.x / 2, -size.y);

    final paint = Paint()..color = GameConstants.playerColor;

    // Body
    final bodyRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
      paint,
    );

    // Draw face based on mood
    _drawFace(canvas);

    canvas.restore();

    // Draw aim arrow when charging (outside squash transform)
    if (state == PlayerState.charging) {
      _drawAimArrow(canvas);
    }
  }

  void _drawFace(Canvas canvas) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    switch (mood) {
      case PlayerMood.normal:
        _drawNormalFace(canvas, eyePaint, pupilPaint);
        break;
      case PlayerMood.happy:
        _drawHappyFace(canvas, eyePaint, pupilPaint);
        break;
      case PlayerMood.scared:
        _drawScaredFace(canvas, eyePaint, pupilPaint);
        break;
      case PlayerMood.ouch:
        _drawOuchFace(canvas, eyePaint, pupilPaint);
        break;
    }
  }

  void _drawNormalFace(Canvas canvas, Paint eyePaint, Paint pupilPaint) {
    // Eyes look in movement/aim direction
    double lookX = 0;
    double lookY = 0;

    if (state == PlayerState.charging) {
      lookX = cos(aimAngle * pi / 180) * 3;
      lookY = sin(aimAngle * pi / 180) * 2;
    } else if (velocity.x.abs() > 10) {
      lookX = velocity.x.sign * 3;
    }

    // Left eye
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.25), 6, eyePaint);
    canvas.drawCircle(
      Offset(size.x * 0.3 + lookX, size.y * 0.25 + lookY),
      3,
      pupilPaint,
    );

    // Right eye
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.25), 6, eyePaint);
    canvas.drawCircle(
      Offset(size.x * 0.7 + lookX, size.y * 0.25 + lookY),
      3,
      pupilPaint,
    );

    // Small smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final mouthPath = Path()
      ..moveTo(size.x * 0.35, size.y * 0.55)
      ..quadraticBezierTo(size.x * 0.5, size.y * 0.65, size.x * 0.65, size.y * 0.55);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawHappyFace(Canvas canvas, Paint eyePaint, Paint pupilPaint) {
    // Happy closed eyes (arcs)
    final eyeArcPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Left eye arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.x * 0.3, size.y * 0.25), width: 12, height: 8),
      pi, pi, false, eyeArcPaint,
    );

    // Right eye arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(size.x * 0.7, size.y * 0.25), width: 12, height: 8),
      pi, pi, false, eyeArcPaint,
    );

    // Big smile
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final mouthPath = Path()
      ..moveTo(size.x * 0.25, size.y * 0.5)
      ..quadraticBezierTo(size.x * 0.5, size.y * 0.75, size.x * 0.75, size.y * 0.5);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawScaredFace(Canvas canvas, Paint eyePaint, Paint pupilPaint) {
    // Big scared eyes
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.25), 8, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.25), 4, pupilPaint);

    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.25), 8, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.25), 4, pupilPaint);

    // O mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.58), width: 10, height: 12),
      mouthPaint,
    );
  }

  void _drawOuchFace(Canvas canvas, Paint eyePaint, Paint pupilPaint) {
    // X eyes
    final xPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Left X
    canvas.drawLine(Offset(size.x * 0.22, size.y * 0.18), Offset(size.x * 0.38, size.y * 0.32), xPaint);
    canvas.drawLine(Offset(size.x * 0.38, size.y * 0.18), Offset(size.x * 0.22, size.y * 0.32), xPaint);

    // Right X
    canvas.drawLine(Offset(size.x * 0.62, size.y * 0.18), Offset(size.x * 0.78, size.y * 0.32), xPaint);
    canvas.drawLine(Offset(size.x * 0.78, size.y * 0.18), Offset(size.x * 0.62, size.y * 0.32), xPaint);

    // Wavy mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final mouthPath = Path()
      ..moveTo(size.x * 0.25, size.y * 0.55)
      ..lineTo(size.x * 0.35, size.y * 0.6)
      ..lineTo(size.x * 0.5, size.y * 0.5)
      ..lineTo(size.x * 0.65, size.y * 0.6)
      ..lineTo(size.x * 0.75, size.y * 0.55);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawAimArrow(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y * 0.5;
    final angleRad = aimAngle * pi / 180;
    final powerRatio = jumpPower / GameConstants.maxJumpPower;

    const maxArrowLength = 80.0;
    const minArrowLength = 25.0;

    // Background arrow (gray, full length)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bgEndX = centerX + cos(angleRad) * maxArrowLength;
    final bgEndY = centerY + sin(angleRad) * maxArrowLength;

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(bgEndX, bgEndY),
      bgPaint,
    );

    // Filled arrow (colored, based on power)
    final filledLength = minArrowLength + powerRatio * (maxArrowLength - minArrowLength);

    // Color gradient based on power
    final Color fillColor;
    if (powerRatio < 0.5) {
      fillColor = Color.lerp(Colors.green, Colors.yellow, powerRatio * 2)!;
    } else {
      fillColor = Color.lerp(Colors.yellow, Colors.red, (powerRatio - 0.5) * 2)!;
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillEndX = centerX + cos(angleRad) * filledLength;
    final fillEndY = centerY + sin(angleRad) * filledLength;

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(fillEndX, fillEndY),
      fillPaint,
    );

    // Arrowhead
    final headPaint = Paint()
      ..color = fillColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headLength = 14.0;
    final headAngle = 30 * pi / 180;

    final head1X = fillEndX - cos(angleRad - headAngle) * headLength;
    final head1Y = fillEndY - sin(angleRad - headAngle) * headLength;
    final head2X = fillEndX - cos(angleRad + headAngle) * headLength;
    final head2Y = fillEndY - sin(angleRad + headAngle) * headLength;

    canvas.drawLine(Offset(fillEndX, fillEndY), Offset(head1X, head1Y), headPaint);
    canvas.drawLine(Offset(fillEndX, fillEndY), Offset(head2X, head2Y), headPaint);

    // Glow effect at high power
    if (powerRatio > 0.7) {
      final glowPaint = Paint()
        ..color = fillColor.withValues(alpha: 0.4)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(fillEndX, fillEndY),
        glowPaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update mood timer
    if (_moodTimer > 0) {
      _moodTimer -= dt;
      if (_moodTimer <= 0) {
        mood = PlayerMood.normal;
      }
    }

    // Update squash/stretch
    _updateSquashStretch(dt);

    switch (state) {
      case PlayerState.idle:
        _handleIdle(dt);
        break;
      case PlayerState.charging:
        _handleCharging(dt);
        break;
      case PlayerState.jumping:
      case PlayerState.falling:
        _handleAirborne(dt);
        break;
    }

    // Track highest point
    if (position.y < highestY) {
      highestY = position.y;
    }

    // Check for death (fell too far below camera)
    final cameraBottom = game.camera.viewfinder.position.y +
        game.size.y / 2 +
        GameConstants.deathFallDistance;
    if (position.y > cameraBottom) {
      game.gameOver();
    }

    // Check wall collision and bounce
    _handleWallBounce();

    // Update mood based on state
    _updateMoodFromState();
  }

  void _updateSquashStretch(double dt) {
    // Lerp back to normal
    _squashStretch += (1.0 - _squashStretch) * 10 * dt;
    _squashStretch = _squashStretch.clamp(0.7, 1.3);
  }

  void _handleWallBounce() {
    const bounceMultiplier = 0.6;
    const minBounceSpeed = 100.0;

    // Left wall
    if (position.x <= size.x / 2) {
      position.x = size.x / 2;
      if (velocity.x < -minBounceSpeed) {
        velocity.x = -velocity.x * bounceMultiplier;
        _onWallHit();
      } else {
        velocity.x = 0;
      }
    }

    // Right wall
    if (position.x >= GameConstants.worldWidth - size.x / 2) {
      position.x = GameConstants.worldWidth - size.x / 2;
      if (velocity.x > minBounceSpeed) {
        velocity.x = -velocity.x * bounceMultiplier;
        _onWallHit();
      } else {
        velocity.x = 0;
      }
    }
  }

  void _onWallHit() {
    mood = PlayerMood.ouch;
    _moodTimer = 0.5;
    _squashStretch = 1.3; // Horizontal squash
  }

  void _updateMoodFromState() {
    if (_moodTimer > 0) return; // Don't override temporary moods

    if (state == PlayerState.falling && velocity.y > 400) {
      mood = PlayerMood.scared;
    } else if (state == PlayerState.idle && isOnGround) {
      mood = PlayerMood.normal;
    }
  }

  void _handleIdle(double dt) {
    if (currentPlatform?.type == PlatformType.slippery) {
      velocity.x *= (1 - GameConstants.slipperyFriction);
      position.x += velocity.x * dt;
    } else {
      velocity.x = 0;
    }
  }

  bool _chargingUp = true;

  void _handleCharging(double dt) {
    if (_chargingUp) {
      jumpPower += GameConstants.chargeRate * dt;
      if (jumpPower >= GameConstants.maxJumpPower) {
        jumpPower = GameConstants.maxJumpPower;
        _chargingUp = false;
      }
    } else {
      jumpPower -= GameConstants.chargeRate * dt;
      if (jumpPower <= GameConstants.minJumpPower) {
        jumpPower = GameConstants.minJumpPower;
        _chargingUp = true;
      }
    }

    if (currentPlatform?.type == PlatformType.slippery) {
      velocity.x *= (1 - GameConstants.slipperyFriction);
      position.x += velocity.x * dt;
    }
  }

  void _handleAirborne(double dt) {
    velocity.y += GameConstants.gravity * dt;
    velocity.y = velocity.y.clamp(-GameConstants.maxJumpPower * 2,
        GameConstants.maxFallSpeed);

    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    state = velocity.y < 0 ? PlayerState.jumping : PlayerState.falling;
  }

  void startCharging() {
    if (isOnGround) {
      state = PlayerState.charging;
      jumpPower = GameConstants.minJumpPower;
      _chargingUp = true;
      aimAngle = -90;
    }
  }

  void jump() {
    if (state == PlayerState.charging) {
      final angleRad = aimAngle * pi / 180;
      velocity.x = cos(angleRad) * jumpPower;
      velocity.y = sin(angleRad) * jumpPower;

      if (currentPlatform?.type == PlatformType.bouncy) {
        velocity.x *= GameConstants.bouncyMultiplier;
        velocity.y *= GameConstants.bouncyMultiplier;
      }

      state = PlayerState.jumping;
      isOnGround = false;
      currentPlatform = null;
      jumpPower = 0;

      // Jump squash effect
      _squashStretch = 0.75;
      mood = PlayerMood.happy;
      _moodTimer = 0.3;
    }
  }

  void setAimDirection(double dx, double dy) {
    if (state == PlayerState.charging) {
      final sensitivity = 2.0;
      final angleChange = dx * sensitivity;
      aimAngle = (-90 + angleChange).clamp(-160, -20);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Platform && velocity.y > 0) {
      final platformTop = other.position.y;
      final playerBottom = position.y;

      if (playerBottom <= platformTop + 20) {
        _landOnPlatform(other);
      }
    }
  }

  void _landOnPlatform(Platform platform) {
    position.y = platform.position.y;
    velocity.y = 0;
    velocity.x = 0;
    isOnGround = true;
    currentPlatform = platform;
    state = PlayerState.idle;
    aimAngle = -90;

    // Landing squash effect
    _squashStretch = 1.25;
    mood = PlayerMood.normal;
  }

  void reset(Vector2 startPosition) {
    position = startPosition.clone();
    velocity = Vector2.zero();
    state = PlayerState.idle;
    isOnGround = true;
    jumpPower = 0;
    aimAngle = -90;
    highestY = startPosition.y;
    currentPlatform = null;
    mood = PlayerMood.normal;
    _moodTimer = 0;
    _squashStretch = 1.0;
  }
}

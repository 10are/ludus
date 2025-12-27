import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

enum PlatformType { normal, slippery, bouncy }

class Platform extends PositionComponent {
  final PlatformType type;

  Platform({
    required Vector2 position,
    required double width,
    this.type = PlatformType.normal,
  }) : super(
          position: position,
          size: Vector2(width, GameConstants.platformHeight),
          anchor: Anchor.topCenter,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _getColor();

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Base platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // Type indicators
    switch (type) {
      case PlatformType.slippery:
        _drawSlipperyEffect(canvas);
        break;
      case PlatformType.bouncy:
        _drawBouncyEffect(canvas);
        break;
      case PlatformType.normal:
        break;
    }
  }

  Color _getColor() {
    switch (type) {
      case PlatformType.normal:
        return GameConstants.normalPlatformColor;
      case PlatformType.slippery:
        return GameConstants.slipperyPlatformColor;
      case PlatformType.bouncy:
        return GameConstants.bouncyPlatformColor;
    }
  }

  void _drawSlipperyEffect(Canvas canvas) {
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw shine lines
    for (int i = 0; i < 3; i++) {
      final x = size.x * (0.2 + i * 0.3);
      canvas.drawLine(
        Offset(x, 3),
        Offset(x + 10, 3),
        shinePaint,
      );
    }
  }

  void _drawBouncyEffect(Canvas canvas) {
    final springPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw spring coils
    final path = Path();
    final coilWidth = size.x / 8;
    for (int i = 0; i < 4; i++) {
      final x = size.x * (0.15 + i * 0.2);
      path.moveTo(x, size.y - 3);
      path.quadraticBezierTo(
        x + coilWidth / 2,
        size.y - 8,
        x + coilWidth,
        size.y - 3,
      );
    }
    canvas.drawPath(path, springPaint);
  }
}

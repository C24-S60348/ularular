import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'board_component.dart';

class PlayerComponent extends PositionComponent with HasGameRef {
  final String playerName;
  final Color color;
  int currentPosition;
  Vector2? targetPosition;

  PlayerComponent({
    required this.playerName,
    required this.color,
    required int initialPosition,
  }) : currentPosition = initialPosition {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updatePosition();
  }

  void _updatePosition() {
    final boardComponent = parent?.children.whereType<BoardComponent>().firstOrNull;
    if (boardComponent != null) {
      final pos = boardComponent.getPositionForCell(currentPosition);
      if (pos != null) {
        // Center in cell (cellSize is now 50, so use 25 for center)
        position = pos + Vector2(BoardComponent.cellSize / 2, BoardComponent.cellSize / 2);
      }
    }
  }

  void moveToPosition(int newPosition) {
    if (newPosition == currentPosition) return;

    currentPosition = newPosition;
    _updatePosition();
    
    // Animate movement
    final boardComponent = parent?.children.whereType<BoardComponent>().firstOrNull;
    if (boardComponent != null) {
      final targetPos = boardComponent.getPositionForCell(newPosition);
      if (targetPos != null) {
        targetPosition = targetPos + Vector2(BoardComponent.cellSize / 2, BoardComponent.cellSize / 2);
        // Animate to target position
        position = targetPosition!;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw player circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.x, position.y),
      12,
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(position.x, position.y),
      12,
      borderPaint,
    );

    // Draw player initial
    final textPainter = TextPainter(
      text: TextSpan(
        text: playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.x - textPainter.width / 2,
        position.y - textPainter.height / 2,
      ),
    );
  }
}


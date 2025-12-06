import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BoardComponent extends Component with HasGameRef {
  static const int maxBox = 28;
  static const int rows = 4;
  static const int cols = 7;
  static const double cellSize = 50.0;
  
  double offsetX = 20.0;
  double offsetY = 20.0;

  final List<Vector2> cellPositions = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _calculateOffsets();
    _generateCellPositions();
  }

  void _calculateOffsets() {
    // Calculate board dimensions
    final boardWidth = cols * cellSize;
    final boardHeight = rows * cellSize;
    
    // Get viewport size
    final viewportSize = gameRef.size;
    
    // Center the board
    offsetX = (viewportSize.x - boardWidth) / 2;
    offsetY = (viewportSize.y - boardHeight) / 2;
    
    // Ensure minimum padding
    if (offsetX < 20) offsetX = 20;
    if (offsetY < 20) offsetY = 20;
  }

  void _generateCellPositions() {
    // Generate positions in zigzag pattern (horizontal layout)
    // Pattern: 1-7 (left to right), then 14-8 (right to left), 
    // then 15-21 (left to right), then 28-22 (right to left)

    cellPositions.clear();
    
    // Start position (before 1) - positioned at bottom left
    cellPositions.add(Vector2(offsetX - 10, offsetY + 3 * cellSize));

    // Generate cells in zigzag pattern
    for (int r = rows - 1; r >= 0; r--) {
      final leftToRight = r % 2 == 0;
      for (int c = 0; c < cols; c++) {
        final num = r * cols + (leftToRight ? c + 1 : cols - c);
        if (num <= maxBox) {
          final x = leftToRight
              ? offsetX + c * cellSize
              : offsetX + (cols - 1 - c) * cellSize;
          final y = offsetY + (rows - 1 - r) * cellSize;
          cellPositions.add(Vector2(x, y));
        }
      }
    }
  }

  Vector2? getPositionForCell(int cellNumber) {
    if (cellNumber < 0 || cellNumber >= cellPositions.length) {
      return null;
    }
    return cellPositions[cellNumber];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw cells
    for (int i = 0; i < cellPositions.length; i++) {
      final pos = cellPositions[i];
      
      // Draw cell background
      final paint = Paint()
        ..color = i == 0 
            ? Colors.grey.shade300 
            : (i % 2 == 0 ? Colors.green.shade50 : Colors.blue.shade50)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromLTWH(pos.x, pos.y, cellSize, cellSize),
        paint,
      );

      // Draw cell border
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawRect(
        Rect.fromLTWH(pos.x, pos.y, cellSize, cellSize),
        borderPaint,
      );

      // Draw cell number
      if (i > 0 && i <= maxBox) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: const TextStyle(
              color: Colors.black,
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
            pos.x + (cellSize - textPainter.width) / 2,
            pos.y + (cellSize - textPainter.height) / 2,
          ),
        );
      }
    }

    // Draw snakes and ladders (sample positions)
    _drawSnakesAndLadders(canvas);
  }

  void _drawSnakesAndLadders(Canvas canvas) {
    final snakePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final ladderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Sample snakes and ladders (from game.js)
    // Snakes: 15->5, 23->14
    // Ladders: 3->11, 8->16

    // Ladder from 3 to 11
    final pos3 = getPositionForCell(3);
    final pos11 = getPositionForCell(11);
    if (pos3 != null && pos11 != null) {
      _drawLadder(canvas, pos3, pos11, ladderPaint);
    }

    // Ladder from 8 to 16
    final pos8 = getPositionForCell(8);
    final pos16 = getPositionForCell(16);
    if (pos8 != null && pos16 != null) {
      _drawLadder(canvas, pos8, pos16, ladderPaint);
    }

    // Snake from 15 to 5
    final pos15 = getPositionForCell(15);
    final pos5 = getPositionForCell(5);
    if (pos15 != null && pos5 != null) {
      _drawSnake(canvas, pos15, pos5, snakePaint);
    }

    // Snake from 23 to 14
    final pos23 = getPositionForCell(23);
    final pos14 = getPositionForCell(14);
    if (pos23 != null && pos14 != null) {
      _drawSnake(canvas, pos23, pos14, snakePaint);
    }
  }

  void _drawLadder(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    final startCenter = Vector2(start.x + cellSize / 2, start.y + cellSize / 2);
    final endCenter = Vector2(end.x + cellSize / 2, end.y + cellSize / 2);

    // Draw ladder sides
    canvas.drawLine(
      Offset(startCenter.x - 5, startCenter.y),
      Offset(endCenter.x - 5, endCenter.y),
      paint,
    );
    canvas.drawLine(
      Offset(startCenter.x + 5, startCenter.y),
      Offset(endCenter.x + 5, endCenter.y),
      paint,
    );

    // Draw ladder rungs
    final steps = 5;
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final x = startCenter.x + (endCenter.x - startCenter.x) * t;
      final y = startCenter.y + (endCenter.y - startCenter.y) * t;
      canvas.drawLine(
        Offset(x - 5, y),
        Offset(x + 5, y),
        paint,
      );
    }
  }

  void _drawSnake(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    final startCenter = Vector2(start.x + cellSize / 2, start.y + cellSize / 2);
    final endCenter = Vector2(end.x + cellSize / 2, end.y + cellSize / 2);

    // Draw curved snake path
    final path = Path();
    path.moveTo(startCenter.x, startCenter.y);
    
    // Create a curved path
    final controlPoint1 = Vector2(
      startCenter.x + (endCenter.x - startCenter.x) * 0.3,
      startCenter.y,
    );
    final controlPoint2 = Vector2(
      endCenter.x - (endCenter.x - startCenter.x) * 0.3,
      endCenter.y,
    );
    
    path.cubicTo(
      controlPoint1.x,
      controlPoint1.y,
      controlPoint2.x,
      controlPoint2.y,
      endCenter.x,
      endCenter.y,
    );

    canvas.drawPath(path, paint);
  }
}


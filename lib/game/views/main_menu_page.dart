import 'package:flutter/material.dart';
import 'create_join_page.dart';
import 'about_us_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  Widget _buildSnakeLogo() {
    return CustomPaint(
      size: const Size(300, 300),
      painter: SnakeLogoPainter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Column(
          children: [
            // Logo at top
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildSnakeLogo(),
                ),
              ),
            ),
            Text(
              'Ular-Ular',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Buttons at bottom
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // PLAY button at bottom center
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateJoinPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  // About Us button at bottom right
                  Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0,
                        right: 8.0,
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutUsPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'About Us',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SnakeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw snake body (curved path)
    final snakePath = Path();
    
    // Create a snake-like S-curve
    final startX = size.width * 0.2;
    final startY = size.height * 0.3;
    final midX1 = size.width * 0.4;
    final midY1 = size.height * 0.2;
    final midX2 = size.width * 0.6;
    final midY2 = size.height * 0.8;
    final endX = size.width * 0.8;
    final endY = size.height * 0.7;
    
    snakePath.moveTo(startX, startY);
    snakePath.cubicTo(
      midX1, midY1,
      midX2, midY2,
      endX, endY,
    );
    
    // Draw snake body with gradient-like effect
    final snakePaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(snakePath, snakePaint);
    
    // Draw snake segments (circles along the path)
    final segmentPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;
    
    final segmentRadius = 15.0;
    final segments = [
      Offset(startX, startY),
      Offset(midX1, midY1),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(midX2, midY2),
      Offset(endX, endY),
    ];
    
    for (final segment in segments) {
      canvas.drawCircle(segment, segmentRadius, segmentPaint);
    }
    
    // Draw snake head (larger circle at the end)
    final headPaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(endX, endY), segmentRadius * 1.5, headPaint);
    
    // Draw eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(endX - 8, endY - 8),
      4,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(endX + 8, endY - 8),
      4,
      eyePaint,
    );
    
    // Draw eye pupils
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(endX - 8, endY - 8),
      2,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(endX + 8, endY - 8),
      2,
      pupilPaint,
    );
    
    // Draw tongue
    final tonguePath = Path();
    tonguePath.moveTo(endX, endY + segmentRadius * 1.5);
    tonguePath.lineTo(endX - 5, endY + segmentRadius * 1.5 + 10);
    tonguePath.moveTo(endX, endY + segmentRadius * 1.5);
    tonguePath.lineTo(endX + 5, endY + segmentRadius * 1.5 + 10);
    
    final tonguePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(tonguePath, tonguePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


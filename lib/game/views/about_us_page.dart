import 'package:flutter/material.dart';
import '../utils/ui_widgets.dart';
import '../utils/animated_widgets.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1280,
      height: 600,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/about us page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Back button at top left
            buildBackButton(context),
            // Floating Speccy at top right
            Positioned(
              top: 20,
              right: 130,
              child: buildFloatingWidget(
                minAngle: -5,
                maxAngle: 5,
                duration: const Duration(milliseconds: 2000),
                child: Image.asset(
                  'assets/images/speccy.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Floating Mercutti at bottom left
            Positioned(
              top: 160,
              left: 130,
              child: buildFloatingWidget(
                minAngle: -5,
                maxAngle: 5,
                duration: const Duration(milliseconds: 2500),
                child: Image.asset(
                  'assets/images/mercutti.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      );
  }
}


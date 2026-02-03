import 'package:flutter/material.dart';
import 'game_mode_selection_page.dart';
import 'about_us_page.dart';
import '../utils/animated_widgets.dart';
import '../utils/ui_widgets.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1280,
      height: 600,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundsplashscreen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Logo at center-top
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: buildPulsingWidget(
                  maxScale: 1.05,
                  minScale: 0.95,
                  duration: const Duration(milliseconds: 2000),
                  child: Image.asset(
                    'assets/images/logo splashscreen.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            //Ular Ular text at center-top
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: buildPulsingWidget(
                  maxScale: 1.0,
                  minScale: 0.98,
                  duration: const Duration(milliseconds: 2000),
                  child: Image.asset(
                    'assets/images/snake snake text malay.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // PLAY button at center-bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: buildPulsingWidget(
                  maxScale: 1.15,
                  minScale: 0.9,
                  duration: const Duration(milliseconds: 2000),
                  child: buildClickableImageButton(
                    imagePath: 'assets/images/play text malay.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        createSlideRoute(const GameModeSelectionPage()),
                      );
                    },
                    height: 80,
                  ),
                ),
              ),
            ),
            // About Us button at bottom right
            Positioned(
              bottom: 20,
              right: 20,
              child: buildClickableImageButton(
                imagePath: 'assets/images/about us malay.png',
                onTap: () {
                  Navigator.push(
                    context,
                    createSlideRoute(const AboutUsPage()),
                  );
                },
                height: 50,
              ),
            ),
          ],
        ),
      );
  }
}

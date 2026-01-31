import 'package:flutter/material.dart';
import 'create_join_page.dart';
import 'about_us_page.dart';
import '../utils/animated_widgets.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: buildPulsingWidget(
                  maxScale: 1.1,
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateJoinPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/play button.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // About Us button at bottom right
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsPage(),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/about us button.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

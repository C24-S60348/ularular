import 'package:flutter/material.dart';
import 'create_join_page.dart';

class GameModeSelectionPage extends StatelessWidget {
  const GameModeSelectionPage({super.key});

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
            // Back button at top left
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/images/back button.png',
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Center content with buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Create Game Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateJoinPage(initialTab: 0),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/create game button.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Join Game Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateJoinPage(initialTab: 1),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/join game button.png',
                      height: 100,
                      fit: BoxFit.contain,
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

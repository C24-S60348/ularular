import 'package:flutter/material.dart';
import 'color_selection_page.dart';
import '../utils/ui_widgets.dart';

class GameModeSelectionPage extends StatelessWidget {
  const GameModeSelectionPage({super.key});

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
            // Back button at top left
            buildBackButton(context),
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
                        createSlideRoute(
                          const ColorSelectionPage(
                            isCreatingRoom: true,
                          ),
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
                        createSlideRoute(
                          const ColorSelectionPage(
                            isCreatingRoom: false,
                          ),
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
      );
  }
}

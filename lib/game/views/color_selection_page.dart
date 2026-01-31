import 'package:flutter/material.dart';
import 'create_room_form_page.dart';
import 'join_room_form_page.dart';
import '../utils/ui_widgets.dart';

class ColorSelectionPage extends StatelessWidget {
  final bool isCreatingRoom;
  
  const ColorSelectionPage({
    super.key,
    required this.isCreatingRoom,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> playerColors = [
      'player red.png',
      'player blue.png',
      'player green.png',
      'player yellow.png',
      'player purple.png',
      'player orange.png',
      'player pink.png',
      'player brown.png',
      'player grey.png',
    ];

    return Container(
      width: 1280,
      height: 600,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundpilihwarna.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Back button at top left
            buildBackButton(context),
            // 3x3 Grid of player colors
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                constraints: const BoxConstraints(
                  maxWidth: 350,
                  maxHeight: 350,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: playerColors.length,
                  itemBuilder: (context, index) {
                    final colorImage = playerColors[index];
                    return GestureDetector(
                      onTap: () {
                        // Extract color name (e.g., "red" from "player red.png")
                        final colorName = colorImage
                            .replaceAll('player ', '')
                            .replaceAll('.png', '');
                        
                        // Navigate to appropriate form page
                        if (isCreatingRoom) {
                          Navigator.push(
                            context,
                            createSlideRoute(
                              CreateRoomFormPage(
                                selectedColor: colorName,
                                colorImage: colorImage,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            createSlideRoute(
                              JoinRoomFormPage(
                                selectedColor: colorName,
                                colorImage: colorImage,
                              ),
                            ),
                          );
                        }
                      },
                      child: Image.asset(
                        'assets/images/$colorImage',
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
  }
}

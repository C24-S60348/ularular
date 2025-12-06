# Snakes and Ladders Game - Flutter Implementation

## Asset Setup Instructions

### Color Assets
You mentioned having 9 color assets with gradients. To use them:

1. **Place your color assets** in `assets/images/colors/` directory:
   - `color1.png`
   - `color2.png`
   - `color3.png`
   - `color4.png`
   - `color5.png`
   - `color6.png`
   - `color7.png`
   - `color8.png`
   - `color9.png`

2. **Update `pubspec.yaml`** to include the colors directory:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/colors/
```

3. **Update the color selector** in `create_join_page.dart`:
   - Replace the `_getColorFromName()` method to load images instead of using colors
   - Update `_buildColorSelector()` to display images using `Image.asset()`

Example:
```dart
Widget _buildColorSelector(String selectedColor, Function(String) onChanged) {
  return Container(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors[index];
        final isSelected = selectedColor == color;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/colors/$color.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    ),
  );
}
```

4. **Update player color rendering** in `game_board_page.dart` and `snakes_ladders_game.dart`:
   - Instead of using `_getColorFromName()` which returns a Color, load the image asset
   - For Flame components, you may need to use `SpriteComponent` with the image

## Game Structure

- **Main Menu** (`main_menu_page.dart`): Entry point with logo and PLAY button
- **About Us** (`about_us_page.dart`): Information about the game
- **Create/Join** (`create_join_page.dart`): Tabs for creating or joining a game
- **Game Board** (`game_board_page.dart`): Main game screen with Flame board
- **Question Page** (`question_page.dart`): Question answering interface

## API Endpoints

The game connects to: `https://afwanhaziq.vps.webdock.cloud/api/ular`

Endpoints used:
- `GET /createroom` - Create a new game room
- `GET /joinroom` - Join an existing game room
- `GET /state` - Get current game state (polled every second)
- `GET /startgame` - Start the game
- `GET /rolldice` - Roll the dice
- `GET /submitanswer` - Submit answer to question

## Running the Game

To run the game separately, use:
```dart
import 'package:celik_tafsir/game/main_game.dart';

void main() {
  mainGame();
}
```

Or integrate it into your existing app by navigating to `MainMenuPage`.

## Screen Orientation

The game is designed for horizontal (landscape) orientation. The main menu and other UI pages work in portrait, but the game board works best in landscape.

## Notes

- The board layout follows the zigzag pattern: 1-7 (left to right), 14-8 (right to left), 15-21 (left to right), 28-22 (right to left)
- Player movement is animated when positions update
- Dice rolling shows animation and result
- Questions appear automatically when landing on ladder/snake positions
- Game state is polled every second to keep all players synchronized


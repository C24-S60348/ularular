import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../models/game_models.dart';
import 'board_component.dart';
import 'player_component.dart';

class SnakesLaddersGame extends FlameGame with HasGameRef {
  final String gameCode;
  final String playerName;
  GameState gameState;
  final int? diceResult;
  final bool isRollingDice;

  SnakesLaddersGame({
    required this.gameCode,
    required this.playerName,
    required this.gameState,
    this.diceResult,
    this.isRollingDice = false,
  });

  BoardComponent? board;
  final Map<String, PlayerComponent> players = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set camera to follow the board
    camera.viewfinder.anchor = Anchor.topLeft;
    
    // Create board
    board = BoardComponent();
    await add(board!);
    
    // Add players
    _updatePlayers();
  }

  void _updatePlayers() {
    if (board == null) return;
    
    // Remove players that are no longer in the game
    final currentPlayerNames = gameState.players.map((p) => p.player).toSet();
    players.removeWhere((name, player) {
      if (!currentPlayerNames.contains(name)) {
        remove(player);
        return true;
      }
      return false;
    });

    // Add or update players
    for (final playerData in gameState.players) {
      if (players.containsKey(playerData.player)) {
        // Update existing player position
        players[playerData.player]!.moveToPosition(playerData.pos);
      } else {
        // Add new player
        final playerComponent = PlayerComponent(
          playerName: playerData.player,
          color: _getColorFromName(playerData.color),
          initialPosition: playerData.pos,
        );
        players[playerData.player] = playerComponent;
        add(playerComponent);
      }
    }
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'color1': Colors.red,
      'color2': Colors.blue,
      'color3': Colors.green,
      'color4': Colors.yellow,
      'color5': Colors.purple,
      'color6': Colors.orange,
      'color7': Colors.pink,
      'color8': Colors.teal,
      'color9': Colors.brown,
    };
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }

  void updateGameState(GameState newState) {
    gameState = newState;
    _updatePlayers();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}


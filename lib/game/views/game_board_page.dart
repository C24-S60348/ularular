import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'dart:async';
import '../services/game_api_service.dart';
import '../models/game_models.dart';
import '../components/snakes_ladders_game.dart';
import 'question_page.dart';
import 'about_us_page.dart';

class GameBoardPage extends StatefulWidget {
  final String gameCode;
  final String playerName;

  const GameBoardPage({
    super.key,
    required this.gameCode,
    required this.playerName,
  });

  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  final GameApiService _apiService = GameApiService();
  Timer? _pollTimer;
  GameState? _currentState;
  bool _isRollingDice = false;
  int? _diceResult;
  SnakesLaddersGame? _gameInstance;
  String? _lastAnsweredQuestionId; // Track last answered question to prevent re-showing
  String? _currentQuestionId; // Track currently shown question to prevent duplicate navigation
  bool _isShowingQuestion = false; // Flag to prevent duplicate navigation

  @override
  void initState() {
    super.initState();
    // Force landscape orientation for game board
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    // Keep landscape orientation (already set in main.dart)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _refreshGameState();
    });
    _refreshGameState();
  }

  Future<void> _refreshGameState() async {
      try {
      final state = await _apiService.getState(widget.gameCode);
      if (mounted) {
        setState(() {
          _currentState = state;
        });

        // Update game instance if it exists
        if (_gameInstance != null) {
          _gameInstance!.updateGameState(state);
        }

        // Check if game ended, navigate to about us
        if (state.ended == true || state.state == 'ended') {
          _pollTimer?.cancel();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutUsPage(),
              ),
            );
          }
        }

        // Check if there's a question, navigate to question page
        // Only show if it's a new question (not the one we just answered or currently showing)
        if (state.question.isNotEmpty && 
            state.questionid.isNotEmpty &&
            state.questionid != _lastAnsweredQuestionId &&
            state.questionid != _currentQuestionId &&
            !_isShowingQuestion) {
          // Mark as showing immediately to prevent duplicate navigation
          _currentQuestionId = state.questionid;
          _isShowingQuestion = true;
          _pollTimer?.cancel();
          
          if (mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionPage(
                  gameCode: widget.gameCode,
                  playerName: widget.playerName,
                  question: state.question.first,
                ),
              ),
            );
            // Mark this question as answered and resume polling
            if (mounted) {
              _isShowingQuestion = false;
              if (result == true) {
                _lastAnsweredQuestionId = state.questionid;
              }
              // Clear current question ID so we can show new questions
              _currentQuestionId = null;
              // Refresh state immediately to get updated game state
              await _refreshGameState();
              _startPolling();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startGame() async {
    try {
      final state = await _apiService.startGame(widget.gameCode);
      if (mounted) {
        setState(() {
          _currentState = state;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting game: $e')),
        );
      }
    }
  }

  Future<void> _rollDice() async {
    if (_isRollingDice) return;

    setState(() {
      _isRollingDice = true;
      _diceResult = null;
    });

    try {
      final state = await _apiService.rollDice(
        code: widget.gameCode,
        player: widget.playerName,
      );

      if (mounted) {
        setState(() {
          _currentState = state;
          _isRollingDice = false;
          _diceResult = state.dice;
        });

        // Refresh state immediately without delay
        await _refreshGameState();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRollingDice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game: ${widget.gameCode}'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _currentState == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Game info section
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      Text(
                        'Code: ${_currentState!.code}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentState!.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Player states
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: _currentState!.players.map((player) {
                          final isCurrentPlayer = player.player == widget.playerName;
                          final isTurn = player.player == _currentState!.turn;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isTurn
                                  ? Colors.green.shade200
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: isCurrentPlayer
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getColorFromName(player.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${player.player} - ${player.pos}',
                                  style: TextStyle(
                                    fontWeight: isCurrentPlayer
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (_currentState!.state == 'waiting')
                                  const Text(
                                    ' (waiting)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      // Start game button if waiting
                      if (_currentState!.state == 'waiting')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Start Game'),
                          ),
                        ),
                    ],
                  ),
                ),
                // Game board
                Expanded(
                  child: Stack(
                    children: [
                      _currentState == null
                          ? const Center(child: CircularProgressIndicator())
                          : GameWidget<SnakesLaddersGame>.controlled(
                              gameFactory: () {
                                _gameInstance = SnakesLaddersGame(
                                  gameCode: widget.gameCode,
                                  playerName: widget.playerName,
                                  gameState: _currentState!,
                                  diceResult: _diceResult,
                                  isRollingDice: _isRollingDice,
                                );
                                return _gameInstance!;
                              },
                            ),
                      // Dice display
                      if (_diceResult != null)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Dice',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_diceResult',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Roll dice button
                if (_currentState!.state == 'playing' &&
                    _currentState!.turn == widget.playerName &&
                    _currentState!.question.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade50,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRollingDice ? null : _rollDice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isRollingDice
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Rolling...'),
                                ],
                              )
                            : const Text(
                                'Roll Dice',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Color _getColorFromName(String colorName) {
    // Temporary colors - TODO: Replace with actual asset images
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
}

